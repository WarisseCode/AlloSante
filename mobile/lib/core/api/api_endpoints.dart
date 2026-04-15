/// AllôDoto — Configuration API
/// Changer [baseUrl] selon l'environnement de test.
class ApiConfig {
  ApiConfig._();

  // ⚠️  Sur téléphone physique : utiliser l'IP WiFi du PC, pas localhost.
  //     PC actuel : 192.168.1.198
  //     Lancer le backend : cd backend && venv/Scripts/python manage.py runserver 0.0.0.0:8000
  static const String baseUrl = 'http://192.168.1.198:8000/api/v1';

  // Auth
  static const String register = '/auth/register/';
  static const String verifyOtp = '/auth/verify-otp/';
  static const String resendOtp = '/auth/resend-otp/';
  static const String login = '/auth/login/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String me = '/auth/me/';
  static const String patientProfile = '/auth/me/patient-profile/';

  // Practitioners
  static const String specialties = '/practitioners/specialties/';
  static const String practitioners = '/practitioners/';
  static String practitionerDetail(int id) => '/practitioners/$id/';
  static String practitionerSlots(int id) => '/practitioners/$id/slots/';
  static String practitionerReviews(int id) => '/practitioners/$id/reviews/';
  static String leaveReview(int id) => '/practitioners/$id/reviews/add/';
  static const String myPractitionerProfile = '/practitioners/me/';
  static const String mySlots = '/practitioners/me/slots/';
  static const String myWorkingHours = '/practitioners/me/working-hours/';

  // Appointments
  static const String bookAppointment = '/appointments/book/';
  static const String myAppointments = '/appointments/mine/';
  static const String practitionerAppointments = '/appointments/practitioner/';
  static String appointmentDetail(int id) => '/appointments/$id/';
  static String cancelAppointment(int id) => '/appointments/$id/cancel/';
  static String confirmAppointment(int id) => '/appointments/$id/confirm/';
  static String completeAppointment(int id) => '/appointments/$id/complete/';

  // Pharmacies
  static const String pharmacies = '/pharmacies/';
  static const String onDutyPharmacies = '/pharmacies/on-duty/';

  // Medical records
  static const String prescriptions = '/medical-records/prescriptions/';
  static String prescriptionDetail(int id) => '/medical-records/prescriptions/$id/';
  static const String medicalDocuments = '/medical-records/documents/';
  static const String reminders = '/medical-records/reminders/';
  static String reminderDetail(int id) => '/medical-records/reminders/$id/';
}
