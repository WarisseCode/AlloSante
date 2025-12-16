import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/services/connectivity_service.dart';
import 'core/storage/local_storage_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/otp_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/payment/presentation/providers/payment_provider.dart';
import 'features/appointments/presentation/providers/doctor_provider.dart';
import 'features/appointments/presentation/providers/appointment_provider.dart';
import 'features/medical_record/presentation/providers/medical_record_provider.dart';
import 'features/doctor/presentation/screens/doctor_home_screen.dart';
import 'features/auth/domain/entities/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurer l'orientation préférée
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurer la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialiser les services
  await _initializeServices();

  runApp(const AlloSanteApp());
}

/// Initialiser les services de l'application
Future<void> _initializeServices() async {
  // Initialiser le stockage local (Hive)
  await LocalStorageService().initialize();

  // Initialiser le stockage sécurisé
  SecureStorageService().initialize();

  // Initialiser le service de connectivité
  await ConnectivityService().initialize();
}

/// Application principale AlloSanté Bénin
class AlloSanteApp extends StatelessWidget {
  const AlloSanteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        ChangeNotifierProvider(create: (_) => ConnectivityService()),

        // Providers d'authentification
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),

        // Provider de paiement
        ChangeNotifierProvider(create: (_) => PaymentProvider()),

        // Provider des médecins
        ChangeNotifierProvider(create: (_) => DoctorProvider()),

        // Provider des rendez-vous
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),

        // Provider du dossier médical
        ChangeNotifierProvider(create: (_) => MedicalRecordProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appNameFull,
        debugShowCheckedModeBanner: false,

        // Thème
        theme: AlloSanteTheme.lightTheme,
        darkTheme: AlloSanteTheme.darkTheme,
        themeMode: ThemeMode.light,

        // Localisation (Français)
        locale: const Locale('fr', 'FR'),

        // Page d'accueil avec gestion de l'état d'authentification
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper d'authentification
/// Gère la navigation en fonction de l'état d'authentification
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Afficher un écran de chargement pendant l'initialisation
        if (authProvider.status == AuthStatus.initial ||
            authProvider.status == AuthStatus.loading) {
          return const SplashScreen();
        }

        // Si authentifié, afficher l'écran d'accueil approprié
        if (authProvider.status == AuthStatus.authenticated) {
          if (authProvider.user?.role == UserRole.doctor) {
            return const DoctorHomeScreen();
          }
          return const HomeScreen();
        }

        // Si en attente d'OTP, afficher l'écran OTP
        if (authProvider.status == AuthStatus.awaitingOtp) {
          return const OtpScreen();
        }

        // Sinon, afficher l'écran de bienvenue
        return const WelcomeScreen();
      },
    );
  }
}

/// Écran de démarrage (Splash Screen)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.local_hospital_rounded,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 32),

            // Nom de l'app
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            Text(
              AppConstants.appTagline,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),

            const SizedBox(height: 48),

            // Indicateur de chargement
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
