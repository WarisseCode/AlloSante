/// Constantes globales de l'application AlloSanté Bénin
class AppConstants {
  AppConstants._();

  // === APPLICATION ===
  static const String appName = 'AlloSanté';
  static const String appNameFull = 'AlloSanté Bénin';
  static const String appTagline = 'Votre santé, notre affaire au quotidien';
  static const String appVersion = '1.0.0';
  
  // === API ===
  static const String baseUrl = 'https://api.allosante.bj';
  static const String apiVersion = '/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration apiTimeoutSlow = Duration(seconds: 60); // Pour connexion 2G
  
  // === AUTHENTIFICATION ===
  static const int otpLength = 6;
  static const int otpResendDelaySeconds = 60;
  static const int otpExpirationMinutes = 10;
  static const int maxOtpAttempts = 3;
  static const int sessionTimeoutMinutes = 30;
  
  // === PAIEMENT MOBILE MONEY ===
  static const int paymentTimeoutSeconds = 300; // 5 minutes
  static const int paymentPollIntervalSeconds = 5;
  static const int slotLockDurationMinutes = 10;
  
  // === VALIDATION TÉLÉPHONE BÉNIN ===
  /// Préfixes Mobile Money Bénin
  static const List<String> mtnPrefixes = ['96', '97', '98', '99'];
  static const List<String> celtiisPrefixes = ['94', '95'];
  static const List<String> allMobilePrefixes = ['90', '91', '92', '93', '94', '95', '96', '97', '98', '99'];
  static const int beninPhoneLength = 8;
  static const String beninCountryCode = '+229';
  
  // === OFFLINE-FIRST ===
  static const Duration syncInterval = Duration(minutes: 5);
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxQueuedActions = 50;
  
  // === UI ===
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 16.0;
  static const double buttonHeight = 52.0;
  static const double inputHeight = 56.0;
  
  // === ANIMATIONS ===
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // === STORAGE KEYS ===
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserProfile = 'user_profile';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyLastSync = 'last_sync';
  static const String keySyncQueue = 'sync_queue';
  
  // === HIVE BOXES ===
  static const String boxAppointments = 'appointments';
  static const String boxDoctors = 'doctors';
  static const String boxUserProfile = 'user_profile';
  static const String boxSyncQueue = 'sync_queue';
  static const String boxSettings = 'settings';
}
