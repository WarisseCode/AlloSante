/// Configuration de l'API backend
class ApiConfig {
  ApiConfig._();

  /// URL de base du backend
  /// En développement: localhost
  /// En production: votre URL de serveur
  /// Pour le build web: flutter build web --dart-define=API_URL=https://votre-url-backend.onrender.com/api
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue:
        'http://10.113.214.50:3000/api', // Valeur par défaut pour le dev local
  );

  static String get baseDomain => baseUrl.replaceAll('/api', '');

  /// Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Endpoints
  static const String auth = '/auth';
  static const String doctors = '/doctors';
  static const String appointments = '/appointments';
  static const String medicalRecord = '/medical-record';

  /// Auth endpoints
  static const String register = '$auth/register';
  static const String login = '$auth/login';
  static const String verifyOtp = '$auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String usersMe = '/users/me';
}
