import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart'; // Import MediaType
import '../../../core/services/api_client.dart';
import '../../../core/config/api_config.dart';

/// Service pour les appels API d'authentification
class AuthApiService {
  final ApiClient _apiClient = ApiClient();

  /// Inscription d'un nouvel utilisateur
  Future<Map<String, dynamic>> register({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.register,
        data: {
          'email': email,
          'phone': phone,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Connexion
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Vérification OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.verifyOtp,
        data: {'phone': phone, 'code': code},
      );

      // Sauvegarder le token
      if (response.data['token'] != null) {
        await _apiClient.saveToken(response.data['token']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Renvoyer OTP
  Future<Map<String, dynamic>> resendOtp({required String phone}) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.resendOtp,
        data: {'phone': phone},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mettre à jour le profil utilisateur
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      final response = await _apiClient.patch(
        ApiConfig.usersMe,
        data: {
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (email != null) 'email': email,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload de l'avatar
  Future<Map<String, dynamic>> uploadAvatar(File file) async {
    try {
      String fileName = file.path.split('/').last;
      
      // Determine content type (simple logic for now)
      MediaType? contentType;
      if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
        contentType = MediaType('image', 'jpeg');
      } else if (fileName.toLowerCase().endsWith('.png')) {
        contentType = MediaType('image', 'png');
      }

      FormData formData = FormData.fromMap({
        "avatar": await MultipartFile.fromFile(
          file.path, 
          filename: fileName,
          contentType: contentType,
        ),
      });

      // Use lower level dio instance/patch to ensure formData is handled
      // Usually ApiClient.patch uses data: dynamic so it works.
      final response = await _apiClient.post(
        '/users/avatar', // Make sure to match backend route exactly: POST /users/avatar
        data: formData, // passing FormData as body
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _apiClient.deleteToken();
  }

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    return await _apiClient.hasToken();
  }

  String _handleError(DioException e) {
    if (e.response?.data != null && e.response!.data['error'] != null) {
      return e.response!.data['error'];
    }
    return 'Erreur de connexion au serveur';
  }
}
