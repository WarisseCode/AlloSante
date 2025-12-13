import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/user.dart';

/// Repository d'authentification avec Mock API
/// Implémente le pattern Repository pour l'architecture Offline-First
class AuthRepository {
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  AuthRepository({
    SecureStorageService? secureStorage,
    LocalStorageService? localStorage,
  })  : _secureStorage = secureStorage ?? SecureStorageService(),
        _localStorage = localStorage ?? LocalStorageService();

  // ============================================================
  // MOCK DATA
  // ============================================================

  /// Utilisateur de test (Mock)
  static final User _mockUser = User(
    id: 'user_001',
    email: 'test@allosante.bj',
    phone: '97000000',
    firstName: 'Kofi',
    lastName: 'Mensah',
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    city: 'Cotonou',
    address: 'Quartier Gbèdjromédé',
  );

  /// Token JWT simulé
  static const String _mockAccessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyXzAwMSIsImVtYWlsIjoidGVzdEBhbGxvc2FudGUuYmoiLCJpYXQiOjE2MzA1NzYwMDAsImV4cCI6MTYzMDY2MjQwMH0.mock_signature';
  static const String _mockRefreshToken = 'refresh_token_mock_12345';

  /// OTP simulé (en production, envoyé par SMS)
  static const String _mockOtp = '123456';

  // ============================================================
  // AUTHENTIFICATION
  // ============================================================

  /// Connexion avec email et mot de passe
  Future<Either<AuthFailure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 1));

      // Mock: Vérification des credentials
      if (email == 'test@allosante.bj' && password == 'password123') {
        // Retourner l'utilisateur (OTP sera envoyé)
        return Right(_mockUser);
      } else if (email.contains('@') && password.length >= 6) {
        // Accepter tout email valide pour les tests
        return Right(_mockUser.copyWith(email: email));
      }

      return const Left(AuthFailure.invalidCredentials());
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
  }) async {
    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 1));

      // Mock: Créer un nouvel utilisateur
      final newUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        isVerified: false,
        createdAt: DateTime.now(),
      );

      return Right(newUser);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur inscription: $e');
      }
      return Left(AuthFailure.serverError(e.toString()));
    }
  }

  /// Envoyer le code OTP par SMS
  Future<Either<AuthFailure, bool>> sendOtp(String phone) async {
    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock: OTP envoyé avec succès
      if (kDebugMode) {
        debugPrint('📱 OTP envoyé à +229 $phone: $_mockOtp');
      }

      return const Right(true);
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
      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 1));

      // Mock: Vérification OTP
      if (otp == _mockOtp || otp == '123456') {
        // OTP valide - Générer les tokens
        final credentials = AuthCredentials(
          accessToken: _mockAccessToken,
          refreshToken: _mockRefreshToken,
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
          user: _mockUser.copyWith(
            phone: phone,
            isVerified: true,
          ),
        );

        // Sauvegarder les tokens de manière sécurisée
        await _saveCredentials(credentials);

        return Right(credentials);
      }

      return const Left(AuthFailure.invalidOtp());
    } catch (e) {
      return Left(AuthFailure.serverError(e.toString()));
    }
  }

  /// Rafraîchir le token d'accès
  Future<Either<AuthFailure, AuthCredentials>> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      
      if (refreshToken == null) {
        return const Left(AuthFailure.notAuthenticated());
      }

      // Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock: Nouveau token
      final credentials = AuthCredentials(
        accessToken: '${_mockAccessToken}_refreshed',
        refreshToken: _mockRefreshToken,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        user: _mockUser,
      );

      await _saveCredentials(credentials);

      return Right(credentials);
    } catch (e) {
      return Left(AuthFailure.serverError(e.toString()));
    }
  }

  /// Déconnexion
  Future<Either<AuthFailure, bool>> logout() async {
    try {
      // Effacer les tokens
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
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      if (kDebugMode) {
        debugPrint('📧 Email de réinitialisation envoyé à: $email');
      }

      return const Right(true);
    } catch (e) {
      return Left(AuthFailure.serverError(e.toString()));
    }
  }

  // ============================================================
  // ÉTAT D'AUTHENTIFICATION
  // ============================================================

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isAuthenticated() async {
    return await _secureStorage.hasValidToken();
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
    return await _secureStorage.getAccessToken();
  }

  // ============================================================
  // MÉTHODES PRIVÉES
  // ============================================================

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
    });
  }
}

/// Classe d'erreur d'authentification
class AuthFailure {
  final String message;
  final String code;

  const AuthFailure._({required this.message, required this.code});

  const AuthFailure.invalidCredentials()
      : this._(message: 'Email ou mot de passe incorrect', code: 'invalid_credentials');

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
