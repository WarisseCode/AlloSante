import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

/// Service de stockage local avec Hive
/// Optimisé pour l'architecture Offline-First
class LocalStorageService {
  LocalStorageService._internal();
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;

  bool _isInitialized = false;
  
  // Boxes Hive
  Box? _appointmentsBox;
  Box? _doctorsBox;
  Box? _userProfileBox;
  Box? _syncQueueBox;
  Box? _settingsBox;

  /// Initialiser Hive et ouvrir les boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialiser Hive pour Flutter
      await Hive.initFlutter();
      
      // Ouvrir les boxes
      _appointmentsBox = await Hive.openBox(AppConstants.boxAppointments);
      _doctorsBox = await Hive.openBox(AppConstants.boxDoctors);
      _userProfileBox = await Hive.openBox(AppConstants.boxUserProfile);
      _syncQueueBox = await Hive.openBox(AppConstants.boxSyncQueue);
      _settingsBox = await Hive.openBox(AppConstants.boxSettings);
      
      _isInitialized = true;
      
      if (kDebugMode) {
        debugPrint('📦 LocalStorageService initialisé avec succès');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur initialisation LocalStorageService: $e');
      }
      rethrow;
    }
  }

  /// Vérifier si le service est initialisé
  bool get isInitialized => _isInitialized;

  // ============================================================
  // RENDEZ-VOUS (Appointments)
  // ============================================================
  
  /// Sauvegarder un rendez-vous
  Future<void> saveAppointment(String id, Map<String, dynamic> data) async {
    await _appointmentsBox?.put(id, data);
  }

  /// Sauvegarder plusieurs rendez-vous
  Future<void> saveAppointments(List<Map<String, dynamic>> appointments) async {
    final Map<String, dynamic> entries = {};
    for (final appt in appointments) {
      if (appt['id'] != null) {
        entries[appt['id'] as String] = appt;
      }
    }
    await _appointmentsBox?.putAll(entries);
  }

  /// Récupérer un rendez-vous par ID
  Map<String, dynamic>? getAppointment(String id) {
    final data = _appointmentsBox?.get(id);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Récupérer tous les rendez-vous
  List<Map<String, dynamic>> getAllAppointments() {
    if (_appointmentsBox == null) return [];
    
    return _appointmentsBox!.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Récupérer les rendez-vous d'un utilisateur
  List<Map<String, dynamic>> getUserAppointments(String userId) {
    return getAllAppointments()
        .where((appt) => appt['user_id'] == userId)
        .toList();
  }

  /// Supprimer un rendez-vous
  Future<void> deleteAppointment(String id) async {
    await _appointmentsBox?.delete(id);
  }

  /// Vider tous les rendez-vous
  Future<void> clearAppointments() async {
    await _appointmentsBox?.clear();
  }

  // ============================================================
  // MÉDECINS (Doctors)
  // ============================================================

  /// Sauvegarder un médecin
  Future<void> saveDoctor(String id, Map<String, dynamic> data) async {
    await _doctorsBox?.put(id, data);
  }

  /// Sauvegarder plusieurs médecins
  Future<void> saveDoctors(List<Map<String, dynamic>> doctors) async {
    final Map<String, dynamic> entries = {};
    for (final doc in doctors) {
      if (doc['id'] != null) {
        entries[doc['id'] as String] = doc;
      }
    }
    await _doctorsBox?.putAll(entries);
  }

  /// Récupérer un médecin par ID
  Map<String, dynamic>? getDoctor(String id) {
    final data = _doctorsBox?.get(id);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Récupérer tous les médecins
  List<Map<String, dynamic>> getAllDoctors() {
    if (_doctorsBox == null) return [];
    
    return _doctorsBox!.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Rechercher des médecins par spécialité
  List<Map<String, dynamic>> getDoctorsBySpecialty(String specialty) {
    return getAllDoctors()
        .where((doc) => 
            (doc['specialty'] as String?)?.toLowerCase() == specialty.toLowerCase())
        .toList();
  }

  /// Rechercher des médecins par localisation
  List<Map<String, dynamic>> getDoctorsByLocation(String location) {
    return getAllDoctors()
        .where((doc) => 
            (doc['location'] as String?)?.toLowerCase().contains(location.toLowerCase()) ?? false)
        .toList();
  }

  /// Vider tous les médecins
  Future<void> clearDoctors() async {
    await _doctorsBox?.clear();
  }

  // ============================================================
  // PROFIL UTILISATEUR
  // ============================================================

  /// Sauvegarder le profil utilisateur
  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _userProfileBox?.put('current_user', profile);
  }

  /// Récupérer le profil utilisateur
  Map<String, dynamic>? getUserProfile() {
    final data = _userProfileBox?.get('current_user');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Supprimer le profil utilisateur
  Future<void> deleteUserProfile() async {
    await _userProfileBox?.delete('current_user');
  }

  // ============================================================
  // FILE D'ATTENTE DE SYNCHRONISATION (Sync Queue)
  // ============================================================

  /// Ajouter une action à la file de synchronisation
  Future<void> addToSyncQueue(Map<String, dynamic> action) async {
    final String id = action['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    action['queued_at'] = DateTime.now().toIso8601String();
    await _syncQueueBox?.put(id, action);
  }

  /// Récupérer toutes les actions en attente
  List<Map<String, dynamic>> getSyncQueue() {
    if (_syncQueueBox == null) return [];
    
    return _syncQueueBox!.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
      ..sort((a, b) => 
          (a['queued_at'] as String).compareTo(b['queued_at'] as String));
  }

  /// Supprimer une action de la file
  Future<void> removeFromSyncQueue(String id) async {
    await _syncQueueBox?.delete(id);
  }

  /// Vider la file de synchronisation
  Future<void> clearSyncQueue() async {
    await _syncQueueBox?.clear();
  }

  /// Nombre d'actions en attente
  int get syncQueueLength => _syncQueueBox?.length ?? 0;

  // ============================================================
  // PARAMÈTRES
  // ============================================================

  /// Sauvegarder un paramètre
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  /// Récupérer un paramètre
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox?.get(key, defaultValue: defaultValue) as T?;
  }

  /// Supprimer un paramètre
  Future<void> deleteSetting(String key) async {
    await _settingsBox?.delete(key);
  }

  /// Sauvegarder la dernière synchronisation
  Future<void> saveLastSyncTime() async {
    await saveSetting(AppConstants.keyLastSync, DateTime.now().toIso8601String());
  }

  /// Récupérer la dernière synchronisation
  DateTime? getLastSyncTime() {
    final timestamp = getSetting<String>(AppConstants.keyLastSync);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  // ============================================================
  // UTILITAIRES
  // ============================================================

  /// Vider tout le stockage local
  Future<void> clearAll() async {
    await _appointmentsBox?.clear();
    await _doctorsBox?.clear();
    await _userProfileBox?.clear();
    await _syncQueueBox?.clear();
    await _settingsBox?.clear();
    
    if (kDebugMode) {
      debugPrint('🧹 Stockage local vidé');
    }
  }

  /// Fermer toutes les boxes
  Future<void> close() async {
    await _appointmentsBox?.close();
    await _doctorsBox?.close();
    await _userProfileBox?.close();
    await _syncQueueBox?.close();
    await _settingsBox?.close();
    _isInitialized = false;
  }

  /// Obtenir la taille approximative du stockage
  int get approximateStorageSize {
    int size = 0;
    size += _appointmentsBox?.length ?? 0;
    size += _doctorsBox?.length ?? 0;
    size += _userProfileBox?.length ?? 0;
    size += _syncQueueBox?.length ?? 0;
    size += _settingsBox?.length ?? 0;
    return size;
  }
}
