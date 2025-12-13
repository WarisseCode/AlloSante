import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Service de stockage sécurisé pour les tokens JWT et données sensibles
/// Utilise flutter_secure_storage (Android EncryptedSharedPreferences / iOS KeyChain)
class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  late FlutterSecureStorage _storage;
  bool _isInitialized = false;

  /// Initialiser le service
  void initialize() {
    if (_isInitialized) return;
    
    // Configuration Android optimisée
    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'allosante_secure_prefs',
      preferencesKeyPrefix: 'allosante_',
    );
    
    // Configuration iOS
    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'allosante_benin',
    );
    
    _storage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );
    
    _isInitialized = true;
    
    if (kDebugMode) {
      debugPrint('🔐 SecureStorageService initialisé');
    }
  }

  /// Vérifier si le service est initialisé
  bool get isInitialized => _isInitialized;

  // ============================================================
  // GESTION DES TOKENS JWT
  // ============================================================

  /// Sauvegarder le token d'accès
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: token);
    if (kDebugMode) {
      debugPrint('🔑 Access token sauvegardé');
    }
  }

  /// Récupérer le token d'accès
  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.keyAccessToken);
  }

  /// Supprimer le token d'accès
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: AppConstants.keyAccessToken);
  }

  /// Sauvegarder le token de rafraîchissement
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.keyRefreshToken, value: token);
    if (kDebugMode) {
      debugPrint('🔑 Refresh token sauvegardé');
    }
  }

  /// Récupérer le token de rafraîchissement
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.keyRefreshToken);
  }

  /// Supprimer le token de rafraîchissement
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppConstants.keyRefreshToken);
  }

  /// Sauvegarder les deux tokens après authentification
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  /// Vérifier si l'utilisateur est authentifié (a un token)
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Supprimer tous les tokens (déconnexion)
  Future<void> clearTokens() async {
    await Future.wait([
      deleteAccessToken(),
      deleteRefreshToken(),
    ]);
    if (kDebugMode) {
      debugPrint('🔑 Tokens supprimés');
    }
  }

  // ============================================================
  // GESTION DE L'UTILISATEUR
  // ============================================================

  /// Sauvegarder l'ID utilisateur
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppConstants.keyUserId, value: userId);
  }

  /// Récupérer l'ID utilisateur
  Future<String?> getUserId() async {
    return await _storage.read(key: AppConstants.keyUserId);
  }

  /// Supprimer l'ID utilisateur
  Future<void> deleteUserId() async {
    await _storage.delete(key: AppConstants.keyUserId);
  }

  // ============================================================
  // STOCKAGE GÉNÉRIQUE SÉCURISÉ
  // ============================================================

  /// Sauvegarder une valeur sécurisée
  Future<void> saveSecure(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Récupérer une valeur sécurisée
  Future<String?> getSecure(String key) async {
    return await _storage.read(key: key);
  }

  /// Supprimer une valeur sécurisée
  Future<void> deleteSecure(String key) async {
    await _storage.delete(key: key);
  }

  /// Vérifier si une clé existe
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  /// Récupérer toutes les clés
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  // ============================================================
  // DÉCONNEXION
  // ============================================================

  /// Effacer toutes les données sécurisées (déconnexion complète)
  Future<void> clearAll() async {
    await _storage.deleteAll();
    if (kDebugMode) {
      debugPrint('🔐 Stockage sécurisé vidé');
    }
  }

  /// Déconnexion propre
  Future<void> logout() async {
    await clearTokens();
    await deleteUserId();
  }
}
