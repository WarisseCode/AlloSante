import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Service de détection de connectivité Offline-First
/// Optimisé pour les conditions réseau du Bénin (2G/3G intermittent)
class ConnectivityService extends ChangeNotifier {
  ConnectivityService._internal();
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();
  InternetConnectionChecker? _internetChecker;
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<InternetConnectionStatus>? _internetSubscription;

  bool _isConnected = true;
  bool _hasInternetAccess = true;
  ConnectivityResult _connectionType = ConnectivityResult.none;
  DateTime? _lastOnlineTime;
  DateTime? _lastSyncTime;

  /// État de connexion actuel
  bool get isConnected => _isConnected;
  
  /// Accès internet vérifié (pas seulement WiFi/Mobile connecté)
  bool get hasInternetAccess => _hasInternetAccess;
  
  /// Mode hors ligne effectif
  bool get isOffline => !_isConnected || !_hasInternetAccess;
  
  /// Type de connexion
  ConnectivityResult get connectionType => _connectionType;
  
  /// Dernière fois en ligne
  DateTime? get lastOnlineTime => _lastOnlineTime;
  
  /// Dernière synchronisation réussie
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Vérifie si la connexion est de type "lente" (2G)
  bool get isSlowConnection {
    return _connectionType == ConnectivityResult.mobile && !_hasInternetAccess;
  }

  /// Initialiser le service
  Future<void> initialize() async {
    // Vérification initiale
    await _checkConnectivity();
    
    // Écouter les changements de connectivité
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
    
    // Configuration du vérificateur internet
    // Note: internet_connection_checker peut ne pas fonctionner parfaitement sur le web
    if (!kIsWeb) {
      _internetChecker = InternetConnectionChecker.instance;
      _internetSubscription = _internetChecker?.onStatusChange.listen(
        _handleInternetStatusChange,
      );
    }
  }

  /// Vérifier la connectivité actuelle
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _connectionType = result.isNotEmpty ? result.first : ConnectivityResult.none;
      _isConnected = _connectionType != ConnectivityResult.none;
      
      if (_isConnected && !kIsWeb) {
        _hasInternetAccess = await _internetChecker?.hasConnection ?? true;
      } else if (_isConnected) {
        // Sur le web, on suppose que la connexion est disponible
        _hasInternetAccess = true;
      } else {
        _hasInternetAccess = false;
      }
      
      if (_isConnected && _hasInternetAccess) {
        _lastOnlineTime = DateTime.now();
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur vérification connectivité: $e');
      }
    }
  }

  /// Gérer les changements de connectivité
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    final wasConnected = _isConnected;
    
    _connectionType = result;
    _isConnected = result != ConnectivityResult.none;
    
    // Si on vient de se reconnecter
    if (!wasConnected && _isConnected) {
      _lastOnlineTime = DateTime.now();
      if (kDebugMode) {
        debugPrint('📶 Connexion rétablie: $_connectionType');
      }
    } else if (wasConnected && !_isConnected) {
      if (kDebugMode) {
        debugPrint('📴 Connexion perdue');
      }
    }
    
    notifyListeners();
  }

  /// Gérer les changements de statut internet
  void _handleInternetStatusChange(InternetConnectionStatus status) {
    final hadAccess = _hasInternetAccess;
    _hasInternetAccess = status == InternetConnectionStatus.connected;
    
    if (!hadAccess && _hasInternetAccess) {
      _lastOnlineTime = DateTime.now();
      if (kDebugMode) {
        debugPrint('🌐 Accès internet rétabli');
      }
    } else if (hadAccess && !_hasInternetAccess) {
      if (kDebugMode) {
        debugPrint('🌐 Accès internet perdu');
      }
    }
    
    notifyListeners();
  }

  /// Mettre à jour l'heure de dernière synchronisation
  void updateLastSyncTime() {
    _lastSyncTime = DateTime.now();
    notifyListeners();
  }

  /// Forcer une vérification de connectivité
  Future<bool> checkConnection() async {
    await _checkConnectivity();
    return !isOffline;
  }

  /// Libérer les ressources
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    super.dispose();
  }

  /// Texte décrivant l'état de connexion
  String get connectionStatusText {
    if (isOffline) {
      return 'Mode hors ligne';
    }
    
    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return 'Connecté via WiFi';
      case ConnectivityResult.mobile:
        return 'Connecté via réseau mobile';
      case ConnectivityResult.ethernet:
        return 'Connecté via Ethernet';
      default:
        return 'Connecté';
    }
  }

  /// Icône correspondant à l'état de connexion
  String get connectionIcon {
    if (isOffline) return '📴';
    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return '📶';
      case ConnectivityResult.mobile:
        return '📱';
      default:
        return '🌐';
    }
  }
}

/// Extension pour faciliter l'accès au service
extension ConnectivityContext on ConnectivityService {
  /// Exécute une action seulement si en ligne
  Future<T?> executeIfOnline<T>(Future<T> Function() action) async {
    if (!isOffline) {
      try {
        return await action();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Erreur action en ligne: $e');
        }
        return null;
      }
    }
    return null;
  }

  /// Exécute une action avec fallback hors ligne
  Future<T> executeWithFallback<T>({
    required Future<T> Function() onlineAction,
    required T Function() offlineFallback,
  }) async {
    if (!isOffline) {
      try {
        return await onlineAction();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Fallback vers mode hors ligne: $e');
        }
        return offlineFallback();
      }
    }
    return offlineFallback();
  }
}
