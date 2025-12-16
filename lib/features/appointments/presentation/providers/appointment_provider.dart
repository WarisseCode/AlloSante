import 'package:flutter/foundation.dart';
import '../../data/appointment_api_service.dart';
import '../../domain/entities/appointment.dart';

/// Provider pour gérer les rendez-vous
class AppointmentProvider extends ChangeNotifier {
  final AppointmentApiService _apiService = AppointmentApiService();

  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Appointment> get appointments => _appointments;
  List<Appointment> get upcomingAppointments => _appointments
      .where(
        (a) =>
            a.appointmentDate.isAfter(DateTime.now()) &&
            a.status != AppointmentStatus.cancelled,
      )
      .toList();
  List<Appointment> get pastAppointments => _appointments
      .where(
        (a) =>
            a.appointmentDate.isBefore(DateTime.now()) ||
            a.status == AppointmentStatus.cancelled,
      )
      .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charger les rendez-vous de l'utilisateur
  Future<void> loadAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments = await _apiService.getAppointments();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Créer un nouveau rendez-vous
  Future<Appointment?> createAppointment({
    required String doctorId,
    required DateTime date,
    required String timeSlot,
    String? type,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final appointment = await _apiService.createAppointment(
        doctorId: doctorId,
        date: date,
        timeSlot: timeSlot,
        type: type,
        notes: notes,
      );
      _appointments.insert(0, appointment);
      notifyListeners();
      return appointment;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  /// Annuler un rendez-vous
  Future<bool> cancelAppointment(String id) async {
    return updateAppointmentStatus(id, 'CANCELLED');
  }

  /// Mettre à jour le statut d'un rendez-vous
  Future<bool> updateAppointmentStatus(String id, String status) async {
    try {
      final updated = await _apiService.updateAppointmentStatus(id, status);
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        _appointments[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
