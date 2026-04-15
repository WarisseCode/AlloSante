import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final _client = ApiClient.instance;

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    String role = 'patient',
  }) async {
    await _client.dio.post(ApiConfig.register, data: {
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'password': password,
      'role': role,
    });
  }

  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    final resp = await _client.dio.post(ApiConfig.verifyOtp, data: {
      'phone_number': phoneNumber,
      'code': code,
    });
    await _client.saveTokens(
      access: resp.data['access'],
      refresh: resp.data['refresh'],
    );
    return UserModel.fromJson(resp.data['user'] as Map<String, dynamic>);
  }

  Future<void> resendOtp(String phoneNumber) async {
    await _client.dio.post(ApiConfig.resendOtp, data: {
      'phone_number': phoneNumber,
    });
  }

  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    final resp = await _client.dio.post(ApiConfig.login, data: {
      'username': phoneNumber,
      'password': password,
    });
    await _client.saveTokens(
      access: resp.data['access'],
      refresh: resp.data['refresh'],
    );
    // Charger le profil après connexion
    return getMe();
  }

  Future<UserModel> getMe() async {
    final resp = await _client.dio.get(ApiConfig.me);
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _client.clearTokens();
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final values = data.values.expand((v) => v is List ? v : [v]);
        return values.join(' ');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
      }
    }
    return 'Une erreur est survenue. Réessayez.';
  }

  String friendlyError(Object e) => _friendlyError(e);
}
