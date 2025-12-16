import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../domain/entities/user.dart';

/// Repository d'authentification avec Backend API
/// Implémente le pattern Repository pour l'architecture Offline-First
class AuthRepository {
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  final ApiClient _apiClient;

  AuthRepository({
    SecureStorageService? secureStorage,
    LocalStorageService? localStorage,
    ApiClient? apiClient,
  }) : _secureStorage = secureStorage ?? SecureStorageService(),
       _localStorage = localStorage ?? LocalStorageService(),
       _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // AUTHENTIFICATION
  // ============================================================

  /// Connexion avec email et mot de passe
  Future<Either<AuthFailure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data;

      // Le backend retourne le numéro de téléphone pour l'OTP
      final user = User(
        id: data['userId'] ?? '',
        email: email,
        phone: data['phone'],
        firstName: '',
        lastName: '',
        role: UserRole
            .patient, // Login only returns minimal info initially, verifyOtp gives full info
        isVerified: false,
        createdAt: DateTime.now(),
      );

      return Right(user);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur login: $e');
      }
      return Left(AuthFailure.serverError(e.toString()));
    }
  }

  /// Inscription d'un nouvel utilisateur
  Future<Either<AuthFailure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    UserRole role = UserRole.patient,
    String? specialty,
    String? location,
    int? consultationPrice,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.register,
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'role': role == UserRole.doctor ? 'DOCTOR' : 'PATIENT',
          if (specialty != null) 'specialty': specialty,
          if (location != null) 'location': location,
          if (consultationPrice != null) 'consultationPrice': consultationPrice,
        },
      );

      final data = response.data;
      final userData = data['user'];

      final user = User(
        id: userData['id'],
        email: userData['email'],
        phone: userData['phone'],
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        role: UserRole.patient, // Default for register
        isVerified: userData['isVerified'] ?? false,
        createdAt: DateTime.parse(userData['createdAt']),
      );

      return Right(user);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur inscription: $e');
      }
      return Left(AuthFailure.serverError(e.toString()));
    }
  }

  /// Envoyer le code OTP par SMS (via le backend)
  Future<Either<AuthFailure, bool>> sendOtp(String phone) async {
    try {
      await _apiClient.post(ApiConfig.resendOtp, data: {'phone': phone});

      if (kDebugMode) {
        debugPrint('📱 OTP envoyé à $phone (vérifiez les logs du backend)');
      }

      return const Right(true);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(AuthFailure.serverError(e.toString()));
    }
  }

  /// Vérifier le code OTP
  Future<Either<AuthFailure, AuthCredentials>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.verifyOtp,
        data: {'phone': phone, 'code': otp},
      );

      final data = response.data;
      final token = data['token'];
      final userData = data['user'];

      // Sauvegarder le token
      if (kDebugMode) {
        print('📱 [AuthRepository] Saving token from verifyOtp: $token');
      }
      await _apiClient.saveToken(token);

      final user = User(
        id: userData['id'],
        email: userData['email'],
        phone: userData['phone'],
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        role: _parseRole(userData['role']),
        doctorProfile: userData['doctorProfile'],
        profilePictureUrl: userData['profilePictureUrl'],
        isVerified: userData['isVerified'] ?? true,
        createdAt: DateTime.now(),
      );

      final credentials = AuthCredentials(
        accessToken: token,
        refreshToken: token, // Backend utilise un seul token
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        user: user,
      );

      // Sauvegarder les credentials localement
      await _saveCredentials(credentials);

      return Right(credentials);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(AuthFailure.serverError(e.toString()));
    }
  }

  /// Rafraîchir le token d'accès
  Future<Either<AuthFailure, AuthCredentials>> refreshToken() async {
    // Le backend actuel n'a pas de refresh token, on garde le token existant
    final token = await _apiClient.getToken();

    if (token == null) {
      return const Left(AuthFailure.notAuthenticated());
    }

    final user = await getCurrentUser();
    if (user == null) {
      return const Left(AuthFailure.notAuthenticated());
    }

    return Right(
      AuthCredentials(
        accessToken: token,
        refreshToken: token,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        user: user,
      ),
    );
  }

  /// Déconnexion
  Future<Either<AuthFailure, bool>> logout() async {
    try {
      // Effacer les tokens
      await _apiClient.deleteToken();
      await _secureStorage.logout();

      // Effacer le profil local
      await _localStorage.deleteUserProfile();

      return const Right(true);
    } catch (e) {
      return Left(AuthFailure.serverError(e.toString()));
    }
  }

  /// Demander la réinitialisation du mot de passe
  Future<Either<AuthFailure, bool>> requestPasswordReset(String email) async {
    // TODO: Implémenter quand le backend aura cet endpoint
    if (kDebugMode) {
      debugPrint('📧 Reset password non implémenté pour: $email');
    }
    return const Right(true);
  }

  /// Mettre à jour le profil
  Future<Either<AuthFailure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      final response = await _apiClient.patch(
        ApiConfig.usersMe,
        data: {
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (email != null) 'email': email,
        },
      );

      final userData = response.data;

      // Conserver les champs existants non retournés
      final currentUser = await getCurrentUser();

      final updatedUser = User(
        id: userData['id'],
        email: userData['email'],
        phone: userData['phone'],
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        // Ces champs ne sont peut-être pas retournés par l'update, on garde l'existant
        isVerified: userData['isVerified'] ?? currentUser?.isVerified ?? false,
        createdAt: currentUser?.createdAt ?? DateTime.now(),
        profilePictureUrl: currentUser?.profilePictureUrl,
        address: currentUser?.address,
        city: currentUser?.city,
        dateOfBirth: currentUser?.dateOfBirth,
        role: currentUser?.role ?? UserRole.patient,
        doctorProfile: currentUser?.doctorProfile,
      );

      // Met à jour le cache local
      await _localStorage.saveUserProfile({
        'id': updatedUser.id,
        'email': updatedUser.email,
        'phone': updatedUser.phone,
        'first_name': updatedUser.firstName,
        'last_name': updatedUser.lastName,
        'profile_picture_url': updatedUser.profilePictureUrl,
        'is_verified': updatedUser.isVerified,
        'created_at': updatedUser.createdAt.toIso8601String(),
        'address': updatedUser.address,
        'city': updatedUser.city,
      });

      return Right(updatedUser);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(AuthFailure.serverError(e.toString()));
    }
  }

  /// Upload de l'avatar
  Future<Either<AuthFailure, User>> uploadAvatar(File file) async {
    try {
      final response = await _apiClient.post(
        '/users/avatar',
        data: FormData.fromMap({
          "avatar": await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        }),
      );

      final userData = response.data;
      final currentUser = await getCurrentUser();

      final updatedUser = User(
        id: userData['id'],
        email: userData['email'],
        phone: userData['phone'],
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        isVerified: userData['isVerified'] ?? currentUser?.isVerified ?? false,
        createdAt: currentUser?.createdAt ?? DateTime.now(),
        profilePictureUrl: userData['profilePictureUrl'], // This is crucial
        address: currentUser?.address,
        city: currentUser?.city,
        dateOfBirth: currentUser?.dateOfBirth,
        role: currentUser?.role ?? UserRole.patient,
        doctorProfile: currentUser?.doctorProfile,
      );

      // Save to cache
      await _localStorage.saveUserProfile({
        'id': updatedUser.id,
        'email': updatedUser.email,
        'phone': updatedUser.phone,
        'first_name': updatedUser.firstName,
        'last_name': updatedUser.lastName,
        'profile_picture_url': updatedUser.profilePictureUrl,
        'is_verified': updatedUser.isVerified,
        'created_at': updatedUser.createdAt.toIso8601String(),
        'address': updatedUser.address,
        'city': updatedUser.city,
      });

      return Right(updatedUser);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(AuthFailure.serverError(e.toString()));
    }
  }

  // ============================================================
  // ÉTAT D'AUTHENTIFICATION
  // ============================================================

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isAuthenticated() async {
    final hasToken = await _apiClient.hasToken();
    final hasLocalToken = await _secureStorage.hasValidToken();
    return hasToken || hasLocalToken;
  }

  /// Récupérer l'utilisateur actuel depuis le cache
  Future<User?> getCurrentUser() async {
    final profile = _localStorage.getUserProfile();
    if (profile == null) return null;

    try {
      return User(
        id: profile['id'] as String,
        email: profile['email'] as String,
        phone: profile['phone'] as String?,
        firstName: profile['first_name'] as String,
        lastName: profile['last_name'] as String,
        role: _parseRole(profile['role']),
        doctorProfile: profile['doctor_profile'] != null
            ? Map<String, dynamic>.from(profile['doctor_profile'])
            : null,
        profilePictureUrl: profile['profile_picture_url'] as String?,
        isVerified: profile['is_verified'] as bool? ?? false,
        createdAt: DateTime.parse(profile['created_at'] as String),
        city: profile['city'] as String?,
        address: profile['address'] as String?,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur parsing user: $e');
      }
      return null;
    }
  }

  /// Récupérer le token d'accès actuel
  Future<String?> getAccessToken() async {
    return await _apiClient.getToken() ?? await _secureStorage.getAccessToken();
  }

  // ============================================================
  // MÉTHODES PRIVÉES
  // ============================================================

  /// Gestion des erreurs Dio
  AuthFailure _handleDioError(DioException e) {
    if (e.response?.data != null && e.response!.data['error'] != null) {
      final errorMsg = e.response!.data['error'] as String;

      if (errorMsg.contains('incorrect') || errorMsg.contains('invalide')) {
        return const AuthFailure.invalidCredentials();
      }
      if (errorMsg.contains('OTP') || errorMsg.contains('code')) {
        return const AuthFailure.invalidOtp();
      }
      if (errorMsg.contains('déjà utilisé') || errorMsg.contains('exists')) {
        return const AuthFailure.emailAlreadyExists();
      }

      return AuthFailure.serverError(errorMsg);
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const AuthFailure.networkError();
    }

    return AuthFailure.serverError(e.message ?? 'Erreur inconnue');
  }

  /// Parser le rôle
  UserRole _parseRole(dynamic role) {
    if (role == 'DOCTOR') return UserRole.doctor;
    if (role == 'ADMIN') return UserRole.admin;
    return UserRole.patient;
  }

  /// Sauvegarder les credentials après authentification

  Future<void> _saveCredentials(AuthCredentials credentials) async {
    // Sauvegarder les tokens de manière sécurisée
    await _secureStorage.saveTokens(
      accessToken: credentials.accessToken,
      refreshToken: credentials.refreshToken,
    );
    await _secureStorage.saveUserId(credentials.user.id);

    // Sauvegarder le profil localement
    await _localStorage.saveUserProfile({
      'id': credentials.user.id,
      'email': credentials.user.email,
      'phone': credentials.user.phone,
      'first_name': credentials.user.firstName,
      'last_name': credentials.user.lastName,
      'profile_picture_url': credentials.user.profilePictureUrl,
      'is_verified': credentials.user.isVerified,
      'created_at': credentials.user.createdAt.toIso8601String(),
      'city': credentials.user.city,
      'address': credentials.user.address,
      'role': credentials.user.role.name.toUpperCase(),
      'doctor_profile': credentials.user.doctorProfile,
    });
  }
}

/// Classe d'erreur d'authentification
class AuthFailure {
  final String message;
  final String code;

  const AuthFailure._({required this.message, required this.code});

  const AuthFailure.invalidCredentials()
    : this._(
        message: 'Email ou mot de passe incorrect',
        code: 'invalid_credentials',
      );

  const AuthFailure.invalidOtp()
    : this._(message: 'Code OTP invalide', code: 'invalid_otp');

  const AuthFailure.otpExpired()
    : this._(message: 'Le code OTP a expiré', code: 'otp_expired');

  const AuthFailure.notAuthenticated()
    : this._(message: 'Non authentifié', code: 'not_authenticated');

  const AuthFailure.networkError()
    : this._(message: 'Erreur de connexion réseau', code: 'network_error');

  const AuthFailure.serverError(String details)
    : this._(message: 'Erreur serveur: $details', code: 'server_error');

  const AuthFailure.userNotFound()
    : this._(message: 'Utilisateur non trouvé', code: 'user_not_found');

  const AuthFailure.emailAlreadyExists()
    : this._(message: 'Cet email est déjà utilisé', code: 'email_exists');

  const AuthFailure.weakPassword()
    : this._(message: 'Le mot de passe est trop faible', code: 'weak_password');
}

/// Credentials d'authentification
class AuthCredentials {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final User user;

  AuthCredentials({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });
}
