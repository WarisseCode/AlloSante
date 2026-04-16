import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/practitioners/presentation/screens/practitioner_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) {
      // ref.read et non ref.watch : on lit l'état au moment du redirect
      // sans que le router soit recréé à chaque changement d'état
      final isAuth = ref.read(authProvider).isAuthenticated;
      final loc = state.matchedLocation;
      final isAuthRoute = loc.startsWith('/onboarding') ||
          loc.startsWith('/login') ||
          loc.startsWith('/register') ||
          loc.startsWith('/otp');

      if (isAuth && isAuthRoute) return '/home';
      if (!isAuth && !isAuthRoute) return '/onboarding';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final phone = state.extra as String;
          return OtpScreen(phoneNumber: phone);
        },
      ),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/practitioners/:id',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PractitionerDetailScreen(practitionerId: id);
        },
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page introuvable : ${state.error}')),
    ),
  );

  // Réévalue les redirects quand l'auth change, sans recréer le router
  ref.listen(authProvider, (_, __) => router.refresh());

  return router;
});
