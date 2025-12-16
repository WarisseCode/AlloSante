import 'package:flutter/foundation.dart';
import '../../data/doctor_api_service.dart';
import '../../domain/entities/doctor.dart';

/// Provider pour gérer les données des médecins
class DoctorProvider extends ChangeNotifier {
  final DoctorApiService _apiService = DoctorApiService();

  List<Doctor> _doctors = [];
  List<String> _specialties = [];
  List<String> _locations = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Doctor> get doctors => _doctors;
  List<String> get specialties => _specialties;
  List<String> get locations => _locations;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charger tous les médecins
  Future<void> loadDoctors({
    String? specialty,
    String? location,
    bool? isAvailable,
    double? minRating,
    int? maxPrice,
    List<String>? languages,
    String? gender,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _doctors = await _apiService.getDoctors(
        specialty: specialty,
        location: location,
        isAvailable: isAvailable,
        minRating: minRating,
        maxPrice: maxPrice,
        languages: languages,
        gender: gender,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les filtres (spécialités et localisations)
  Future<void> loadFilters() async {
    try {
      _specialties = await _apiService.getSpecialties();
      _locations = await _apiService.getLocations();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur chargement filtres: $e');
    }
  }

  /// Charger les statistiques du dashboard
  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _apiService.getDashboardStats();
    } catch (e) {
      _error = e.toString();
      debugPrint('Erreur chargement stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer un médecin par son ID
  Future<Doctor?> getDoctorById(String id) async {
    try {
      return await _apiService.getDoctorById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
