import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../../../core/config/api_config.dart';
import '../domain/entities/doctor.dart';

/// Service pour les appels API des médecins
class DoctorApiService {
  final ApiClient _apiClient = ApiClient();

  /// Récupérer tous les médecins avec filtres optionnels
  Future<List<Doctor>> getDoctors({
    String? specialty,
    String? location,
    bool? isAvailable,
    double? minRating,
    int? maxPrice,
    List<String>? languages,
    String? gender,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (specialty != null) queryParams['specialty'] = specialty;
      if (location != null) queryParams['location'] = location;
      if (isAvailable != null)
        queryParams['isAvailable'] = isAvailable.toString();
      if (minRating != null) queryParams['minRating'] = minRating.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (languages != null && languages.isNotEmpty) {
        queryParams['languages'] = languages.join(',');
      }
      if (gender != null) queryParams['gender'] = gender;

      final response = await _apiClient.get(
        ApiConfig.doctors,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final List<dynamic> doctorsJson = response.data['doctors'];
      return doctorsJson.map((json) => _doctorFromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer un médecin par ID
  Future<Doctor> getDoctorById(String id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.doctors}/$id');
      return _doctorFromJson(response.data['doctor']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les spécialités disponibles
  Future<List<String>> getSpecialties() async {
    try {
      final response = await _apiClient.get('${ApiConfig.doctors}/specialties');
      return List<String>.from(response.data['specialties']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les localisations disponibles
  Future<List<String>> getLocations() async {
    try {
      final response = await _apiClient.get('${ApiConfig.doctors}/locations');
      return List<String>.from(response.data['locations']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les statistiques du tableau de bord (Médecin)
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiClient.get('${ApiConfig.doctors}/stats');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
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
      gender: json['gender'],
    );
  }

  String _handleError(DioException e) {
    if (e.response?.data != null && e.response!.data['error'] != null) {
      return e.response!.data['error'];
    }
    return 'Erreur de connexion au serveur';
  }
}
