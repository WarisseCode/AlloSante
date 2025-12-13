import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../appointments/domain/entities/appointment.dart';

/// Repository de paiement Mobile Money (Mock)
/// Simule les API MTN MoMo et Celtiis Cash
class PaymentRepository {
  PaymentRepository();

  // État du paiement en cours (pour simulation)
  PaymentStatus? _currentPaymentStatus;
  Timer? _paymentTimer;

  // ============================================================
  // INITIATION DU PAIEMENT
  // ============================================================

  /// Initier un paiement Mobile Money
  Future<Either<PaymentFailure, PaymentSession>> initiatePayment({
    required String appointmentId,
    required PaymentMethod method,
    required String phoneNumber,
    required int amount,
  }) async {
    try {
      // Valider le numéro de téléphone
      final validationResult = _validatePhoneNumber(phoneNumber, method);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Simuler l'appel API
      await Future.delayed(const Duration(seconds: 1));

      // Créer la session de paiement
      final session = PaymentSession(
        transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        appointmentId: appointmentId,
        method: method,
        phoneNumber: phoneNumber,
        amount: amount,
        status: PaymentStatus.pending,
        expiresAt: DateTime.now().add(
          Duration(seconds: AppConstants.paymentTimeoutSeconds),
        ),
        createdAt: DateTime.now(),
      );

      // Démarrer la simulation de traitement
      _startPaymentSimulation(session.transactionId);

      if (kDebugMode) {
        debugPrint('📱 Demande USSD envoyée à +229 $phoneNumber');
        debugPrint('💰 Montant: $amount FCFA via ${method.displayName}');
      }

      return Right(session);
    } catch (e) {
      return Left(PaymentFailure.serverError(e.toString()));
    }
  }

  /// Vérifier le statut d'un paiement
  Future<Either<PaymentFailure, PaymentSession>> checkPaymentStatus(
    String transactionId,
  ) async {
    try {
      // Simuler l'appel API de vérification
      await Future.delayed(const Duration(milliseconds: 500));

      // Retourner le statut simulé
      final status = _currentPaymentStatus ?? PaymentStatus.pending;

      final session = PaymentSession(
        transactionId: transactionId,
        appointmentId: '',
        method: PaymentMethod.mtnMomo,
        phoneNumber: '',
        amount: 0,
        status: status,
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        createdAt: DateTime.now(),
        completedAt: status == PaymentStatus.success ? DateTime.now() : null,
      );

      return Right(session);
    } catch (e) {
      return Left(PaymentFailure.serverError(e.toString()));
    }
  }

  /// Annuler un paiement en cours
  Future<Either<PaymentFailure, bool>> cancelPayment(
    String transactionId,
  ) async {
    try {
      _paymentTimer?.cancel();
      _currentPaymentStatus = PaymentStatus.cancelled;

      return const Right(true);
    } catch (e) {
      return Left(PaymentFailure.serverError(e.toString()));
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  /// Valider le numéro de téléphone selon l'opérateur
  PaymentFailure? _validatePhoneNumber(String phone, PaymentMethod method) {
    // Nettoyer le numéro
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    // Vérifier la longueur
    if (cleaned.length != AppConstants.beninPhoneLength) {
      return const PaymentFailure.invalidPhoneNumber(
        'Le numéro doit contenir ${AppConstants.beninPhoneLength} chiffres',
      );
    }

    // Vérifier le préfixe selon l'opérateur
    final prefix = cleaned.substring(0, 2);

    if (method == PaymentMethod.mtnMomo) {
      if (!AppConstants.mtnPrefixes.contains(prefix)) {
        return const PaymentFailure.invalidPhoneNumber(
          'Ce numéro n\'est pas un numéro MTN valide',
        );
      }
    } else if (method == PaymentMethod.celtiisCash) {
      if (!AppConstants.celtiisPrefixes.contains(prefix)) {
        return const PaymentFailure.invalidPhoneNumber(
          'Ce numéro n\'est pas un numéro Celtiis valide',
        );
      }
    }

    return null;
  }

  /// Obtenir les préfixes valides pour un opérateur
  List<String> getValidPrefixes(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mtnMomo:
        return AppConstants.mtnPrefixes;
      case PaymentMethod.celtiisCash:
        return AppConstants.celtiisPrefixes;
      default:
        return AppConstants.allMobilePrefixes;
    }
  }

  // ============================================================
  // SIMULATION
  // ============================================================

  /// Simuler le processus de paiement (pour tests)
  void _startPaymentSimulation(String transactionId) {
    _currentPaymentStatus = PaymentStatus.pending;

    // Après 5 secondes, passer en "processing"
    _paymentTimer = Timer(const Duration(seconds: 5), () {
      _currentPaymentStatus = PaymentStatus.processing;

      // Après 5 secondes de plus, succès (80%) ou échec (20%)
      Timer(const Duration(seconds: 5), () {
        final random = DateTime.now().millisecond % 10;
        if (random < 8) {
          _currentPaymentStatus = PaymentStatus.success;
          if (kDebugMode) {
            debugPrint('✅ Paiement réussi: $transactionId');
          }
        } else {
          _currentPaymentStatus = PaymentStatus.failed;
          if (kDebugMode) {
            debugPrint('❌ Paiement échoué: $transactionId');
          }
        }
      });
    });
  }

  /// Forcer le succès du paiement (pour tests)
  void simulatePaymentSuccess() {
    _paymentTimer?.cancel();
    _currentPaymentStatus = PaymentStatus.success;
  }

  /// Forcer l'échec du paiement (pour tests)
  void simulatePaymentFailure() {
    _paymentTimer?.cancel();
    _currentPaymentStatus = PaymentStatus.failed;
  }

  /// Libérer les ressources
  void dispose() {
    _paymentTimer?.cancel();
  }
}

/// Session de paiement
class PaymentSession {
  final String transactionId;
  final String appointmentId;
  final PaymentMethod method;
  final String phoneNumber;
  final int amount;
  final PaymentStatus status;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;

  const PaymentSession({
    required this.transactionId,
    required this.appointmentId,
    required this.method,
    required this.phoneNumber,
    required this.amount,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });

  /// Temps restant avant expiration
  Duration get timeRemaining {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Vérifier si la session est expirée
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Montant formaté
  String get formattedAmount => '$amount FCFA';

  PaymentSession copyWith({
    String? transactionId,
    String? appointmentId,
    PaymentMethod? method,
    String? phoneNumber,
    int? amount,
    PaymentStatus? status,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
  }) {
    return PaymentSession(
      transactionId: transactionId ?? this.transactionId,
      appointmentId: appointmentId ?? this.appointmentId,
      method: method ?? this.method,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Classe d'erreur pour les paiements
class PaymentFailure {
  final String message;
  final String code;

  const PaymentFailure._({required this.message, required this.code});

  const PaymentFailure.serverError(String details)
      : this._(message: 'Erreur serveur: $details', code: 'server_error');

  const PaymentFailure.invalidPhoneNumber(String details)
      : this._(message: details, code: 'invalid_phone');

  const PaymentFailure.paymentFailed(String details)
      : this._(message: details, code: 'payment_failed');

  const PaymentFailure.paymentCancelled()
      : this._(message: 'Paiement annulé', code: 'payment_cancelled');

  const PaymentFailure.paymentExpired()
      : this._(message: 'Délai de paiement expiré', code: 'payment_expired');

  const PaymentFailure.insufficientFunds()
      : this._(message: 'Solde insuffisant', code: 'insufficient_funds');

  const PaymentFailure.networkError()
      : this._(message: 'Erreur de connexion', code: 'network_error');
}

/// Extension pour PaymentMethod
extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.mtnMomo:
        return 'MTN MoMo';
      case PaymentMethod.celtiisCash:
        return 'Celtiis Cash';
      case PaymentMethod.cash:
        return 'Paiement sur place';
    }
  }

  String get iconPath {
    switch (this) {
      case PaymentMethod.mtnMomo:
        return 'assets/icons/mtn_momo.png';
      case PaymentMethod.celtiisCash:
        return 'assets/icons/celtiis.png';
      case PaymentMethod.cash:
        return 'assets/icons/cash.png';
    }
  }
}
