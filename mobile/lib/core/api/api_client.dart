import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';

/// Client HTTP Dio avec intercepteur JWT automatique.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final _storage = const FlutterSecureStorage();
  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );

    return dio;
  }

  /// Injecte le token JWT dans chaque requête.
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _accessKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// Rafraîchit le token si 401, sinon laisse passer l'erreur.
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Rejouer la requête originale avec le nouveau token
        final token = await _storage.read(key: _accessKey);
        final opts = error.requestOptions;
        opts.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await _dio.fetch(opts);
          handler.resolve(response);
          return;
        } catch (_) {}
      }
    }
    handler.next(error);
  }

  Future<bool> _tryRefreshToken() async {
    final refresh = await _storage.read(key: _refreshKey);
    if (refresh == null) return false;
    try {
      final resp = await Dio().post(
        '${ApiConfig.baseUrl}${ApiConfig.tokenRefresh}',
        data: {'refresh': refresh},
      );
      await saveTokens(
        access: resp.data['access'],
        refresh: resp.data['refresh'] ?? refresh,
      );
      return true;
    } catch (_) {
      await clearTokens();
      return false;
    }
  }

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  Future<bool> get isLoggedIn async {
    final token = await _storage.read(key: _accessKey);
    return token != null;
  }
}
