import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../data/repositories/payment_repository.dart';

/// États du flux de paiement
enum PaymentFlowStatus {
  initial,
  selectingMethod,
  enteringPhone,
  processing,
  awaitingConfirmation,
  success,
  failed,
  cancelled,
  expired,
}

/// Provider de paiement Mobile Money
/// Gère l'état asynchrone du flux de paiement
class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository;

  PaymentProvider({PaymentRepository? repository})
      : _repository = repository ?? PaymentRepository();

  // État
  PaymentFlowStatus _status = PaymentFlowStatus.initial;
  PaymentMethod? _selectedMethod;
  String _phoneNumber = '';
  PaymentSession? _currentSession;
  String? _errorMessage;
  int _remainingSeconds = 0;
  
  Timer? _countdownTimer;
  Timer? _pollTimer;

  // Getters
  PaymentFlowStatus get status => _status;
  PaymentMethod? get selectedMethod => _selectedMethod;
  String get phoneNumber => _phoneNumber;
  PaymentSession? get currentSession => _currentSession;
  String? get errorMessage => _errorMessage;
  int get remainingSeconds => _remainingSeconds;
  bool get isProcessing => 
      _status == PaymentFlowStatus.processing || 
      _status == PaymentFlowStatus.awaitingConfirmation;

  /// Démarrer le flux de paiement
  void startPaymentFlow() {
    _status = PaymentFlowStatus.selectingMethod;
    _selectedMethod = null;
    _phoneNumber = '';
    _currentSession = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Sélectionner la méthode de paiement
  void selectPaymentMethod(PaymentMethod method) {
    _selectedMethod = method;
    _status = PaymentFlowStatus.enteringPhone;
    _phoneNumber = '';
    _errorMessage = null;
    notifyListeners();
  }

  /// Mettre à jour le numéro de téléphone
  void updatePhoneNumber(String phone) {
    _phoneNumber = phone.replaceAll(RegExp(r'\D'), '');
    _errorMessage = null;
    notifyListeners();
  }

  /// Valider le numéro de téléphone
  String? validatePhoneNumber() {
    if (_phoneNumber.isEmpty) {
      return 'Veuillez entrer votre numéro';
    }
    
    if (_phoneNumber.length != AppConstants.beninPhoneLength) {
      return 'Le numéro doit contenir ${AppConstants.beninPhoneLength} chiffres';
    }

    final prefix = _phoneNumber.substring(0, 2);
    
    if (_selectedMethod == PaymentMethod.mtnMomo) {
      if (!AppConstants.mtnPrefixes.contains(prefix)) {
        return 'Ce numéro n\'est pas un numéro MTN';
      }
    } else if (_selectedMethod == PaymentMethod.celtiisCash) {
      if (!AppConstants.celtiisPrefixes.contains(prefix)) {
        return 'Ce numéro n\'est pas un numéro Celtiis';
      }
    }

    return null;
  }

  /// Initier le paiement
  Future<bool> initiatePayment({
    required String appointmentId,
    required int amount,
  }) async {
    // Valider d'abord
    final validationError = validatePhoneNumber();
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    if (_selectedMethod == null) {
      _errorMessage = 'Veuillez sélectionner un mode de paiement';
      notifyListeners();
      return false;
    }

    _status = PaymentFlowStatus.processing;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.initiatePayment(
      appointmentId: appointmentId,
      method: _selectedMethod!,
      phoneNumber: _phoneNumber,
      amount: amount,
    );

    return result.fold(
      (failure) {
        _status = PaymentFlowStatus.failed;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (session) {
        _currentSession = session;
        _status = PaymentFlowStatus.awaitingConfirmation;
        _startCountdown();
        _startPolling();
        notifyListeners();
        return true;
      },
    );
  }

  /// Démarrer le compte à rebours
  void _startCountdown() {
    _remainingSeconds = AppConstants.paymentTimeoutSeconds;
    
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _handleTimeout();
      }
      
      notifyListeners();
    });
  }

  /// Démarrer le polling du statut
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      Duration(seconds: AppConstants.paymentPollIntervalSeconds),
      (timer) async {
        if (_currentSession == null) {
          timer.cancel();
          return;
        }

        final result = await _repository.checkPaymentStatus(
          _currentSession!.transactionId,
        );

        result.fold(
          (failure) {
            // Continuer à polling en cas d'erreur
            if (kDebugMode) {
              debugPrint('⚠️ Erreur polling: ${failure.message}');
            }
          },
          (session) {
            _currentSession = session;
            
            if (session.status == PaymentStatus.success) {
              timer.cancel();
              _handleSuccess();
            } else if (session.status == PaymentStatus.failed) {
              timer.cancel();
              _handleFailure('Le paiement a échoué');
            }
            
            notifyListeners();
          },
        );
      },
    );
  }

  /// Gérer le succès du paiement
  void _handleSuccess() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    _status = PaymentFlowStatus.success;
    notifyListeners();
  }

  /// Gérer l'échec du paiement
  void _handleFailure(String message) {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    _status = PaymentFlowStatus.failed;
    _errorMessage = message;
    notifyListeners();
  }

  /// Gérer le timeout
  void _handleTimeout() {
    _pollTimer?.cancel();
    _status = PaymentFlowStatus.expired;
    _errorMessage = 'Le délai de paiement a expiré';
    notifyListeners();
  }

  /// Annuler le paiement
  Future<void> cancelPayment() async {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();

    if (_currentSession != null) {
      await _repository.cancelPayment(_currentSession!.transactionId);
    }

    _status = PaymentFlowStatus.cancelled;
    notifyListeners();
  }

  /// Réessayer le paiement
  void retryPayment() {
    _status = PaymentFlowStatus.enteringPhone;
    _currentSession = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Changer de méthode de paiement
  void changePaymentMethod() {
    _status = PaymentFlowStatus.selectingMethod;
    _selectedMethod = null;
    _currentSession = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Réinitialiser le flux
  void reset() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    _status = PaymentFlowStatus.initial;
    _selectedMethod = null;
    _phoneNumber = '';
    _currentSession = null;
    _errorMessage = null;
    _remainingSeconds = 0;
    notifyListeners();
  }

  /// Simuler le succès (pour tests)
  void simulateSuccess() {
    _repository.simulatePaymentSuccess();
  }

  /// Simuler l'échec (pour tests)
  void simulateFailure() {
    _repository.simulatePaymentFailure();
  }

  /// Temps restant formaté
  String get formattedRemainingTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
