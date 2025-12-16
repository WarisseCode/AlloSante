import 'package:equatable/equatable.dart';
import 'doctor.dart';
import '../../../auth/domain/entities/user.dart';

/// Entité Rendez-vous
class Appointment extends Equatable {
  final String id;
  final String doctorId;
  final String userId;
  final DateTime appointmentDate;
  final String timeSlot;
  final AppointmentStatus status;
  final AppointmentType type;
  final String? notes;
  final int price;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final PaymentInfo? paymentInfo;

  // Relations (chargées depuis le cache)
  final Doctor? doctor;
  final User? user;

  const Appointment({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    required this.type,
    this.notes,
    required this.price,
    required this.createdAt,
    this.confirmedAt,
    this.cancelledAt,
    this.cancelReason,
    this.paymentInfo,
    this.doctor,
    this.user,
  });

  /// Vérifier si le RDV est à venir
  bool get isUpcoming {
    final now = DateTime.now();
    return appointmentDate.isAfter(now) &&
        (status == AppointmentStatus.confirmed ||
            status == AppointmentStatus.pending);
  }

  /// Vérifier si le RDV est passé
  bool get isPast => appointmentDate.isBefore(DateTime.now());

  /// Vérifier si le RDV peut être annulé
  bool get canBeCancelled {
    if (status != AppointmentStatus.confirmed &&
        status != AppointmentStatus.pending) {
      return false;
    }
    // Peut être annulé jusqu'à 2 heures avant
    final deadline = appointmentDate.subtract(const Duration(hours: 2));
    return DateTime.now().isBefore(deadline);
  }

  /// Date formatée
  String get formattedDate {
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    final days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];

    return '${days[appointmentDate.weekday - 1]} ${appointmentDate.day} ${months[appointmentDate.month - 1]} ${appointmentDate.year}';
  }

  /// Prix formaté
  String get formattedPrice => '$price FCFA';

  /// Copier avec modifications
  Appointment copyWith({
    String? id,
    String? doctorId,
    String? userId,
    DateTime? appointmentDate,
    String? timeSlot,
    AppointmentStatus? status,
    AppointmentType? type,
    String? notes,
    int? price,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    String? cancelReason,
    PaymentInfo? paymentInfo,
    Doctor? doctor,
    User? user,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      userId: userId ?? this.userId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelReason: cancelReason ?? this.cancelReason,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      doctor: doctor ?? this.doctor,
      user: user ?? this.user,
    );
  }

  /// Convertir en Map pour le stockage local
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'user_id': userId,
      'appointment_date': appointmentDate.toIso8601String(),
      'time_slot': timeSlot,
      'status': status.name,
      'type': type.name,
      'notes': notes,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancel_reason': cancelReason,
      'payment_info': paymentInfo?.toMap(),
    };
  }

  /// Créer depuis un Map
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as String,
      doctorId: map['doctor_id'] as String,
      userId: map['user_id'] as String,
      appointmentDate: DateTime.parse(map['appointment_date'] as String),
      timeSlot: map['time_slot'] as String,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      type: AppointmentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AppointmentType.consultation,
      ),
      notes: map['notes'] as String?,
      price: map['price'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      confirmedAt: map['confirmed_at'] != null
          ? DateTime.parse(map['confirmed_at'] as String)
          : null,
      cancelledAt: map['cancelled_at'] != null
          ? DateTime.parse(map['cancelled_at'] as String)
          : null,
      cancelReason: map['cancel_reason'] as String?,
      paymentInfo: map['payment_info'] != null
          ? PaymentInfo.fromMap(map['payment_info'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    doctorId,
    userId,
    appointmentDate,
    timeSlot,
    status,
    type,
    notes,
    price,
    createdAt,
    confirmedAt,
    cancelledAt,
    cancelReason,
    paymentInfo,
  ];
}

/// Statut du rendez-vous
enum AppointmentStatus {
  pending, // En attente de paiement
  confirmed, // Confirmé
  completed, // Terminé
  cancelled, // Annulé
  noShow, // Patient absent
}

/// Type de rendez-vous
enum AppointmentType {
  consultation, // Consultation standard
  followUp, // Suivi
  emergency, // Urgence
  teleconsultation, // Téléconsultation
}

/// Créneau horaire disponible
class TimeSlot extends Equatable {
  final String id;
  final String time;
  final bool isAvailable;
  final DateTime date;

  const TimeSlot({
    required this.id,
    required this.time,
    required this.isAvailable,
    required this.date,
  });

  @override
  List<Object?> get props => [id, time, isAvailable, date];
}

/// Informations de paiement
class PaymentInfo extends Equatable {
  final String transactionId;
  final PaymentMethod method;
  final PaymentStatus status;
  final int amount;
  final String? phoneNumber;
  final DateTime initiatedAt;
  final DateTime? completedAt;

  const PaymentInfo({
    required this.transactionId,
    required this.method,
    required this.status,
    required this.amount,
    this.phoneNumber,
    required this.initiatedAt,
    this.completedAt,
  });

  /// Convertir en Map
  Map<String, dynamic> toMap() {
    return {
      'transaction_id': transactionId,
      'method': method.name,
      'status': status.name,
      'amount': amount,
      'phone_number': phoneNumber,
      'initiated_at': initiatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Créer depuis un Map
  factory PaymentInfo.fromMap(Map<String, dynamic> map) {
    return PaymentInfo(
      transactionId: map['transaction_id'] as String,
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == map['method'],
        orElse: () => PaymentMethod.mtnMomo,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PaymentStatus.pending,
      ),
      amount: map['amount'] as int,
      phoneNumber: map['phone_number'] as String?,
      initiatedAt: DateTime.parse(map['initiated_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    transactionId,
    method,
    status,
    amount,
    phoneNumber,
    initiatedAt,
    completedAt,
  ];
}

/// Méthode de paiement
enum PaymentMethod {
  mtnMomo, // MTN Mobile Money
  celtiisCash, // Celtiis Cash
  cash, // Paiement sur place
}

/// Statut du paiement
enum PaymentStatus {
  pending, // En attente de validation utilisateur
  processing, // En cours de traitement
  success, // Paiement réussi
  failed, // Paiement échoué
  cancelled, // Paiement annulé
  expired, // Délai expiré
}
