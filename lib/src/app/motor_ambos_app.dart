import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/garage/presentation/garage_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/membership/presentation/membership_screen.dart'; // Make sure you have this file created
import '../features/more/presentation/more_screen.dart'; // Make sure you have this file created
import 'app_shell.dart';
import 'theme.dart';

class MotorAmbosApp extends ConsumerWidget {
  const MotorAmbosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state to trigger re-builds on login/logout
    final authStateAsync = ref.watch(authStateProvider);

    final router = GoRouter(
      initialLocation: '/app',
      debugLogDiagnostics: true,

      // Redirect Logic
      redirect: (context, state) {
        // If auth is still initializing, do nothing
        if (authStateAsync.isLoading) return null;

        final session = Supabase.instance.client.auth.currentSession;
        final isLoggingIn = state.uri.toString() == '/login';

        // 1. Not logged in? -> Go to Login
        if (session == null) return '/login';

        // 2. Logged in but on Login page? -> Go to Home
        if (session != null && isLoggingIn) return '/app';

        // 3. Otherwise, let them go where they want
        return null;
      },

      routes: [
        // Public Route
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Private Routes (Wrapped in AppShell / Bottom Nav)
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/app',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/assist',
              // Replace with your actual AssistScreen import
              builder: (context, state) =>
                  const Center(child: Text("Assist Screen")),
            ),
            GoRoute(
              path: '/garage',
              builder: (context, state) => const GarageScreen(),
              routes: [
                // Sub-route for adding a vehicle
                GoRoute(
                  path: 'add',
                  // Replace with your AddVehicleScreen import
                  builder: (context, state) =>
                      const Center(child: Text("Add Vehicle Screen")),
                ),
              ],
            ),
            GoRoute(
              path: '/membership',
              builder: (context, state) => const MembershipScreen(),
            ),
            GoRoute(
              path: '/more',
              builder: (context, state) => const MoreScreen(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'MotorAmbos',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Respects device setting
      routerConfig: router,
    );
  }
}
