import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/doctor.dart';

/// Repository de rendez-vous avec architecture Offline-First
/// Stratégie: Stale-While-Revalidate pour les lectures
class AppointmentRepository {
  final ConnectivityService _connectivity;
  final LocalStorageService _localStorage;

  AppointmentRepository({
    ConnectivityService? connectivity,
    LocalStorageService? localStorage,
  })  : _connectivity = connectivity ?? ConnectivityService(),
        _localStorage = localStorage ?? LocalStorageService();

  // ============================================================
  // MOCK DATA
  // ============================================================

  /// Liste des médecins mockés
  static final List<Doctor> _mockDoctors = [
    const Doctor(
      id: 'doc_001',
      firstName: 'Aminou',
      lastName: 'Kouyaté',
      specialty: 'Médecine Générale',
      location: 'Cotonou',
      address: 'Quartier Cadjèhoun, Rue 234',
      rating: 4.8,
      reviewCount: 124,
      consultationPrice: 15000,
      languages: ['Français', 'Fon', 'Yoruba'],
      availableDays: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'],
      isAvailable: true,
      bio: 'Médecin généraliste avec 15 ans d\'expérience',
      experienceYears: 15,
    ),
    const Doctor(
      id: 'doc_002',
      firstName: 'Aïcha',
      lastName: 'Dossou',
      specialty: 'Gynécologie',
      location: 'Cotonou',
      address: 'Quartier Ganhi, Avenue Jean-Paul II',
      rating: 4.9,
      reviewCount: 89,
      consultationPrice: 25000,
      languages: ['Français', 'Fon'],
      availableDays: ['Lundi', 'Mercredi', 'Vendredi'],
      isAvailable: true,
      bio: 'Spécialiste en gynécologie obstétrique',
      experienceYears: 12,
    ),
    const Doctor(
      id: 'doc_003',
      firstName: 'Koffi',
      lastName: 'Agbossou',
      specialty: 'Cardiologie',
      location: 'Porto-Novo',
      address: 'Centre Hospitalier, Bâtiment C',
      rating: 4.7,
      reviewCount: 67,
      consultationPrice: 30000,
      languages: ['Français', 'Goun'],
      availableDays: ['Mardi', 'Jeudi', 'Samedi'],
      isAvailable: true,
      bio: 'Cardiologue certifié, spécialiste des maladies cardiovasculaires',
      experienceYears: 18,
    ),
    const Doctor(
      id: 'doc_004',
      firstName: 'Mariama',
      lastName: 'Sanni',
      specialty: 'Pédiatrie',
      location: 'Cotonou',
      address: 'Clinique Les Palmiers, Akpakpa',
      rating: 4.9,
      reviewCount: 156,
      consultationPrice: 12000,
      languages: ['Français', 'Fon', 'Mina'],
      availableDays: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'],
      isAvailable: true,
      bio: 'Pédiatre passionnée par la santé des enfants',
      experienceYears: 10,
    ),
    const Doctor(
      id: 'doc_005',
      firstName: 'Emmanuel',
      lastName: 'Gbèdo',
      specialty: 'Dentiste',
      location: 'Abomey-Calavi',
      address: 'Cabinet Dentaire du Lac, près de l\'UAC',
      rating: 4.6,
      reviewCount: 78,
      consultationPrice: 10000,
      languages: ['Français'],
      availableDays: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'],
      isAvailable: true,
      bio: 'Chirurgien dentiste spécialisé en implantologie',
      experienceYears: 8,
    ),
    const Doctor(
      id: 'doc_006',
      firstName: 'Félicia',
      lastName: 'Ahouannou',
      specialty: 'Dermatologie',
      location: 'Cotonou',
      address: 'Clinique Dermatologique, Haie Vive',
      rating: 4.8,
      reviewCount: 92,
      consultationPrice: 20000,
      languages: ['Français', 'Fon'],
      availableDays: ['Mardi', 'Mercredi', 'Vendredi'],
      isAvailable: true,
      bio: 'Dermatologue spécialisée dans les problèmes de peau tropicaux',
      experienceYears: 14,
    ),
  ];

  /// Créneaux horaires disponibles
  static final List<String> _timeSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30',
  ];

  // ============================================================
  // MÉDECINS
  // ============================================================

  /// Récupérer tous les médecins (Offline-First)
  Future<Either<AppointmentFailure, List<Doctor>>> getDoctors({
    String? specialty,
    String? location,
  }) async {
    try {
      // 1. Lire d'abord depuis le cache local
      List<Doctor> doctors = _getDoctorsFromCache();

      // 2. Si en ligne, rafraîchir depuis l'API
      if (!_connectivity.isOffline) {
        final remoteDoctors = await _fetchDoctorsFromApi(
          specialty: specialty,
          location: location,
        );
        
        if (remoteDoctors.isNotEmpty) {
          // Mettre à jour le cache
          await _cacheDoctors(remoteDoctors);
          doctors = remoteDoctors;
          _connectivity.updateLastSyncTime();
        }
      }

      // Appliquer les filtres si spécifiés
      if (specialty != null && specialty.isNotEmpty) {
        doctors = doctors.where((d) => 
          d.specialty.toLowerCase() == specialty.toLowerCase()
        ).toList();
      }
      
      if (location != null && location.isNotEmpty) {
        doctors = doctors.where((d) => 
          d.location.toLowerCase().contains(location.toLowerCase())
        ).toList();
      }

      return Right(doctors);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur getDoctors: $e');
      }
      return Left(AppointmentFailure.serverError(e.toString()));
    }
  }

  /// Récupérer un médecin par ID
  Future<Either<AppointmentFailure, Doctor>> getDoctorById(String id) async {
    try {
      // Chercher d'abord dans le cache
      final cached = _localStorage.getDoctor(id);
      if (cached != null) {
        return Right(Doctor.fromMap(cached));
      }

      // Sinon, utiliser les données mock
      final doctor = _mockDoctors.firstWhere(
        (d) => d.id == id,
        orElse: () => throw Exception('Médecin non trouvé'),
      );

      return Right(doctor);
    } catch (e) {
      return const Left(AppointmentFailure.doctorNotFound());
    }
  }

  // ============================================================
  // CRÉNEAUX HORAIRES
  // ============================================================

  /// Récupérer les créneaux disponibles pour un médecin
  Future<Either<AppointmentFailure, List<TimeSlot>>> getAvailableSlots({
    required String doctorId,
    required DateTime date,
  }) async {
    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 500));

      // Générer des créneaux mock (certains aléatoirement indisponibles)
      final slots = _timeSlots.map((time) {
        final isAvailable = DateTime.now().millisecond % 3 != 0 || 
                           _timeSlots.indexOf(time) % 2 == 0;
        return TimeSlot(
          id: '${doctorId}_${date.toIso8601String()}_$time',
          time: time,
          isAvailable: isAvailable,
          date: date,
        );
      }).toList();

      return Right(slots);
    } catch (e) {
      return Left(AppointmentFailure.serverError(e.toString()));
    }
  }

  // ============================================================
  // RENDEZ-VOUS
  // ============================================================

  /// Créer un rendez-vous (Optimistic UI)
  Future<Either<AppointmentFailure, Appointment>> createAppointment({
    required String doctorId,
    required String userId,
    required DateTime date,
    required String timeSlot,
    required AppointmentType type,
    String? notes,
  }) async {
    try {
      // Récupérer le médecin pour le prix
      final doctorResult = await getDoctorById(doctorId);
      
      return doctorResult.fold(
        (failure) => Left(failure),
        (doctor) async {
          // Créer le rendez-vous localement (Optimistic)
          final appointment = Appointment(
            id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
            doctorId: doctorId,
            userId: userId,
            appointmentDate: date,
            timeSlot: timeSlot,
            status: AppointmentStatus.pending,
            type: type,
            notes: notes,
            price: doctor.consultationPrice,
            createdAt: DateTime.now(),
            doctor: doctor,
          );

          // Sauvegarder localement
          await _localStorage.saveAppointment(appointment.id, appointment.toMap());

          // Si hors ligne, ajouter à la queue de sync
          if (_connectivity.isOffline) {
            await _localStorage.addToSyncQueue({
              'id': appointment.id,
              'action': 'create_appointment',
              'data': appointment.toMap(),
            });
          }

          return Right(appointment);
        },
      );
    } catch (e) {
      return Left(AppointmentFailure.serverError(e.toString()));
    }
  }

  /// Récupérer les rendez-vous d'un utilisateur
  Future<Either<AppointmentFailure, List<Appointment>>> getUserAppointments(
    String userId,
  ) async {
    try {
      // Lire depuis le cache local
      final cachedData = _localStorage.getUserAppointments(userId);
      
      final appointments = cachedData.map((data) {
        final appointment = Appointment.fromMap(data);
        // Charger le médecin associé
        final doctorData = _localStorage.getDoctor(appointment.doctorId);
        if (doctorData != null) {
          return appointment.copyWith(doctor: Doctor.fromMap(doctorData));
        }
        return appointment;
      }).toList();

      // Trier par date
      appointments.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));

      return Right(appointments);
    } catch (e) {
      return Left(AppointmentFailure.serverError(e.toString()));
    }
  }

  /// Annuler un rendez-vous
  Future<Either<AppointmentFailure, bool>> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) async {
    try {
      final data = _localStorage.getAppointment(appointmentId);
      if (data == null) {
        return const Left(AppointmentFailure.appointmentNotFound());
      }

      // Mettre à jour le statut
      data['status'] = AppointmentStatus.cancelled.name;
      data['cancelled_at'] = DateTime.now().toIso8601String();
      data['cancel_reason'] = reason;

      await _localStorage.saveAppointment(appointmentId, data);

      // Si hors ligne, ajouter à la queue
      if (_connectivity.isOffline) {
        await _localStorage.addToSyncQueue({
          'id': appointmentId,
          'action': 'cancel_appointment',
          'data': {'reason': reason},
        });
      }

      return const Right(true);
    } catch (e) {
      return Left(AppointmentFailure.serverError(e.toString()));
    }
  }

  // ============================================================
  // MÉTHODES PRIVÉES
  // ============================================================

  /// Récupérer les médecins depuis le cache
  List<Doctor> _getDoctorsFromCache() {
    final cachedData = _localStorage.getAllDoctors();
    if (cachedData.isNotEmpty) {
      return cachedData.map((data) => Doctor.fromMap(data)).toList();
    }
    return _mockDoctors;
  }

  /// Récupérer les médecins depuis l'API (Mock)
  Future<List<Doctor>> _fetchDoctorsFromApi({
    String? specialty,
    String? location,
  }) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(seconds: 1));
    return _mockDoctors;
  }

  /// Mettre en cache les médecins
  Future<void> _cacheDoctors(List<Doctor> doctors) async {
    await _localStorage.saveDoctors(
      doctors.map((d) => d.toMap()).toList(),
    );
  }
}

/// Classe d'erreur pour les rendez-vous
class AppointmentFailure {
  final String message;
  final String code;

  const AppointmentFailure._({required this.message, required this.code});

  const AppointmentFailure.serverError(String details)
      : this._(message: 'Erreur serveur: $details', code: 'server_error');

  const AppointmentFailure.doctorNotFound()
      : this._(message: 'Médecin non trouvé', code: 'doctor_not_found');

  const AppointmentFailure.appointmentNotFound()
      : this._(message: 'Rendez-vous non trouvé', code: 'appointment_not_found');

  const AppointmentFailure.slotUnavailable()
      : this._(message: 'Ce créneau n\'est plus disponible', code: 'slot_unavailable');

  const AppointmentFailure.paymentRequired()
      : this._(message: 'Paiement requis', code: 'payment_required');

  const AppointmentFailure.networkError()
      : this._(message: 'Erreur de connexion', code: 'network_error');
}
