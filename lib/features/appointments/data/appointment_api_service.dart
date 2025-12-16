import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../../../core/config/api_config.dart';
import '../domain/entities/appointment.dart';
import '../domain/entities/doctor.dart';
import '../../auth/domain/entities/user.dart';

/// Service pour les appels API des rendez-vous
class AppointmentApiService {
  final ApiClient _apiClient = ApiClient();

  /// Créer un rendez-vous
  Future<Appointment> createAppointment({
    required String doctorId,
    required DateTime date,
    required String timeSlot,
    String? type,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.appointments,
        data: {
          'doctorId': doctorId,
          'date': date.toIso8601String(),
          'timeSlot': timeSlot,
          if (type != null) 'type': type,
          if (notes != null) 'notes': notes,
        },
      );
      return _appointmentFromJson(response.data['appointment']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer tous les rendez-vous de l'utilisateur
  Future<List<Appointment>> getAppointments() async {
    try {
      final response = await _apiClient.get(ApiConfig.appointments);
      final List<dynamic> appointmentsJson = response.data['appointments'];
      return appointmentsJson
          .map((json) => _appointmentFromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer un rendez-vous par ID
  Future<Appointment> getAppointmentById(String id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.appointments}/$id');
      return _appointmentFromJson(response.data['appointment']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Annuler un rendez-vous
  Future<Appointment> cancelAppointment(String id) async {
    return updateAppointmentStatus(id, 'CANCELLED');
  }

  /// Mettre à jour le statut d'un rendez-vous
  Future<Appointment> updateAppointmentStatus(String id, String status) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.appointments}/$id/status',
        data: {'status': status},
      );
      return _appointmentFromJson(response.data['appointment']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Appointment _appointmentFromJson(Map<String, dynamic> json) {
    final doctorJson = json['doctor'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>?;

    return Appointment(
      id: json['id'],
      doctorId: json['doctorId'],
      userId: json['userId'],
      appointmentDate: DateTime.parse(json['date']),
      timeSlot: json['timeSlot'],
      status: _parseStatus(json['status']),
      type: _parseType(json['type']),
      notes: json['notes'],
      price: json['price'],
      createdAt: DateTime.parse(json['createdAt']),
      doctor: doctorJson != null ? _doctorFromJson(doctorJson) : null,
      user: userJson != null ? _userFromJson(userJson) : null,
    );
  }

  // Helper minimal pour parser le User (patient)
  User _userFromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] as String).toLowerCase(),
        orElse: () => UserRole.patient,
      ),
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  Doctor _doctorFromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      specialty: json['specialty'],
      location: json['location'],
      address: json['address'],
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'],
      consultationPrice: json['consultationPrice'],
      languages: List<String>.from(json['languages'] ?? []),
      availableDays: List<String>.from(json['availableDays'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      experienceYears: json['experienceYears'],
      bio: json['bio'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  AppointmentStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return AppointmentStatus.confirmed;
      case 'CANCELLED':
        return AppointmentStatus.cancelled;
      case 'COMPLETED':
        return AppointmentStatus.completed;
      default:
        return AppointmentStatus.pending;
    }
  }

  AppointmentType _parseType(String type) {
    switch (type.toUpperCase()) {
      case 'FOLLOW_UP':
        return AppointmentType.followUp;
      case 'EMERGENCY':
        return AppointmentType.emergency;
      case 'TELECONSULTATION':
        return AppointmentType.teleconsultation;
      default:
        return AppointmentType.consultation;
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data != null && e.response!.data['error'] != null) {
      return e.response!.data['error'];
    }
    return 'Erreur de connexion au serveur';
  }
}
