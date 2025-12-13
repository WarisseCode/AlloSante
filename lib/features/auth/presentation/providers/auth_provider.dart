import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';

/// États d'authentification
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  awaitingOtp,
  error,
}

/// Provider d'authentification
/// Gère l'état d'authentification global de l'application
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  // État
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  String? _pendingPhone;
  int _otpResendCountdown = 0;
  int _otpAttempts = 0;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get pendingPhone => _pendingPhone;
  int get otpResendCountdown => _otpResendCountdown;
  int get otpAttempts => _otpAttempts;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  /// Initialiser l'état d'authentification
  Future<void> initialize() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final isAuth = await _repository.isAuthenticated();
      
      if (isAuth) {
        _user = await _repository.getCurrentUser();
        _status = _user != null 
            ? AuthStatus.authenticated 
            : AuthStatus.unauthenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur initialisation auth: $e');
      }
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  /// Connexion avec email et mot de passe
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.login(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) async {
        _user = user;
        _pendingPhone = user.phone;
        
        // Envoyer OTP pour MFA
        if (user.phone != null && user.phone!.isNotEmpty) {
          await _sendOtp(user.phone!);
          _status = AuthStatus.awaitingOtp;
        } else {
          _status = AuthStatus.awaitingOtp;
        }
        
        notifyListeners();
        return true;
      },
    );
  }

  /// Inscription d'un nouvel utilisateur
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) async {
        _user = user;
        _pendingPhone = phone;
        
        // Envoyer OTP pour vérification
        await _sendOtp(phone);
        _status = AuthStatus.awaitingOtp;
        
        notifyListeners();
        return true;
      },
    );
  }

  /// Envoyer le code OTP
  Future<bool> _sendOtp(String phone) async {
    final result = await _repository.sendOtp(phone);
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        return false;
      },
      (success) {
        _startOtpCountdown();
        return true;
      },
    );
  }

  /// Renvoyer le code OTP
  Future<bool> resendOtp() async {
    if (_pendingPhone == null || _otpResendCountdown > 0) {
      return false;
    }

    _errorMessage = null;
    notifyListeners();

    final result = await _repository.sendOtp(_pendingPhone!);
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (success) {
        _startOtpCountdown();
        notifyListeners();
        return true;
      },
    );
  }

  /// Vérifier le code OTP
  Future<bool> verifyOtp(String otp) async {
    if (_pendingPhone == null) {
      _errorMessage = 'Numéro de téléphone manquant';
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    _otpAttempts++;

    final result = await _repository.verifyOtp(
      phone: _pendingPhone!,
      otp: otp,
    );

    return result.fold(
      (failure) {
        _status = AuthStatus.awaitingOtp;
        _errorMessage = failure.message;
        
        // Vérifier le nombre de tentatives
        if (_otpAttempts >= 3) {
          _errorMessage = 'Trop de tentatives. Veuillez renvoyer un nouveau code.';
        }
        
        notifyListeners();
        return false;
      },
      (credentials) {
        _user = credentials.user;
        _status = AuthStatus.authenticated;
        _pendingPhone = null;
        _otpAttempts = 0;
        
        if (kDebugMode) {
          debugPrint('✅ Authentification réussie: ${_user?.fullName}');
        }
        
        notifyListeners();
        return true;
      },
    );
  }

  /// Déconnexion
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await _repository.logout();

    _user = null;
    _pendingPhone = null;
    _errorMessage = null;
    _otpAttempts = 0;
    _status = AuthStatus.unauthenticated;
    
    notifyListeners();
  }

  /// Demander la réinitialisation du mot de passe
  Future<bool> requestPasswordReset(String email) async {
    _errorMessage = null;
    
    final result = await _repository.requestPasswordReset(email);
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (success) => true,
    );
  }

  /// Effacer les erreurs
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Démarrer le compte à rebours pour renvoyer l'OTP
  void _startOtpCountdown() {
    _otpResendCountdown = 60; // 60 secondes
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      _otpResendCountdown--;
      notifyListeners();
      return _otpResendCountdown > 0;
    });
  }

  /// Définir le numéro de téléphone en attente (pour OTP)
  void setPendingPhone(String phone) {
    _pendingPhone = phone;
    notifyListeners();
  }

  /// Annuler l'OTP et retourner à la connexion
  void cancelOtp() {
    _status = AuthStatus.unauthenticated;
    _pendingPhone = null;
    _otpAttempts = 0;
    _errorMessage = null;
    notifyListeners();
  }
}
