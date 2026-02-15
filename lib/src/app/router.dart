// lib/src/app/router.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:motor_ambos/src/core/widget/app_shell.dart';

// Auth screens
import 'package:motor_ambos/src/features/auth/presentation/signup_page.dart';
import 'package:motor_ambos/src/features/auth/presentation/login_page.dart';
import 'package:motor_ambos/src/features/auth/presentation/phone_login_page.dart';
import 'package:motor_ambos/src/features/auth/presentation/otp_verify_page.dart';
import 'package:motor_ambos/src/features/auth/presentation/splash_screen.dart';

// Tab screens (new navigation)
import 'package:motor_ambos/src/features/home/presentation/home_screen.dart';
import 'package:motor_ambos/src/features/services/presentation/services_screen.dart';
import 'package:motor_ambos/src/features/activity/presentation/activity_screen.dart';
import 'package:motor_ambos/src/features/sos/presentation/sos_screen.dart';
import 'package:motor_ambos/src/features/services/presentation/service_category_screen.dart';
import 'package:motor_ambos/src/features/services/presentation/service_provider_detail_screen.dart';
import 'package:motor_ambos/src/features/services/domain/service_provider.dart';

// Profile / settings (was "More")
import 'package:motor_ambos/src/features/more/presentation/more_screen.dart';
import 'package:motor_ambos/src/features/account/presentation/account_screen.dart';

// Sub-screens (kept for deep navigation)
import 'package:motor_ambos/src/features/garage/presentation/garage_screen.dart';
import 'package:motor_ambos/src/features/garage/presentation/add_vehicle_screen.dart';
import 'package:motor_ambos/src/features/garage/presentation/vehicle_detail_screen.dart';
import 'package:motor_ambos/src/features/membership/presentation/membership_screen.dart';
import 'package:motor_ambos/src/features/membership/presentation/membership_card_screen.dart';
import 'package:motor_ambos/src/features/history/presentation/history_screen.dart';
import 'package:motor_ambos/src/features/assist/presentation/assist_screen.dart';
import 'package:motor_ambos/src/features/assist/presentation/request_assist_screen.dart';
import 'package:motor_ambos/src/features/assist/presentation/providers_results_screen.dart';
import 'package:motor_ambos/src/core/models/vehicle.dart';

/// Rebuilds GoRouter whenever Supabase auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final supabase = Supabase.instance.client;

  return GoRouter(
    initialLocation: '/splash',

    /// 🔁 Rebuild on auth changes
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),

    /// 🔐 Global auth guard
    redirect: (context, state) {
      final session = supabase.auth.currentSession;

      final isPublicRoute =
          state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/sign-up' ||
          state.matchedLocation == '/phone-login' ||
          state.matchedLocation == '/otp-verify' ||
          state.matchedLocation == '/splash';

      // Not logged in → steer to phone login
      if (session == null && !isPublicRoute) {
        return '/phone-login';
      }

      // Logged in but on auth screen → go home
      if (session != null && isPublicRoute) {
        return '/app';
      }

      return null;
    },

    routes: [
      // ─────────────────────────────────── Public routes ─────────────────
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'sign-up',
        builder: (_, __) => const SignupPage(),
      ),
      GoRoute(
        path: '/phone-login',
        name: 'phone-login',
        builder: (_, __) => const PhoneLoginPage(),
      ),
      GoRoute(
        path: '/otp-verify',
        name: 'otp-verify',
        builder: (_, state) {
          final phone = state.extra as String? ?? '';
          return OtpVerifyPage(phoneNumber: phone);
        },
      ),

      // ─────────────────── Full-screen overlays (no bottom nav) ─────────
      GoRoute(
        path: '/sos',
        name: 'sos',
        builder: (_, __) => const SosScreen(),
      ),

      // ─────────────────────── Shell (bottom nav) ───────────────────────
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          // ── Tab 1: Home (Digital Garage dashboard) ─────────────────
          GoRoute(
            path: '/app',
            name: 'home',
            builder: (_, __) => const HomeScreen(),
          ),

          // ── Tab 2: Services (Marketplace) ──────────────────────────
          GoRoute(
            path: '/services',
            name: 'services',
            builder: (_, __) => const ServicesScreen(),
            routes: [
              GoRoute(
                path: 'category',
                name: 'service-category',
                builder: (_, state) {
                  final category = state.extra as ServiceCategory;
                  return ServiceCategoryScreen(category: category);
                },
              ),
              GoRoute(
                path: 'provider',
                name: 'service-provider-detail',
                builder: (_, state) {
                  final provider = state.extra as ServiceProvider;
                  return ServiceProviderDetailScreen(provider: provider);
                },
              ),
            ],
          ),

          // ── Tab 3: Activity (Vehicle History) ──────────────────────
          GoRoute(
            path: '/activity',
            name: 'activity',
            builder: (_, __) => const ActivityScreen(),
          ),

          // ── Tab 4: Profile (was "More") ────────────────────────────
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (_, __) => const ProfileScreen(),
          ),

          // ──────────────── Sub-screens (within the shell) ───────────

          // Garage management (pushed from Home)
          GoRoute(
            path: '/garage',
            name: 'garage',
            builder: (_, __) => const GarageScreen(),
          ),
          GoRoute(
            path: '/garage/add',
            name: 'garage-add',
            builder: (_, state) {
              final extra = state.extra;
              return AddVehicleScreen(
                  vehicle: extra is Vehicle ? extra : null);
            },
          ),
          GoRoute(
            path: '/garage/detail/:id',
            name: 'vehicle-detail',
            builder: (_, state) {
              final id = state.pathParameters['id']!;
              return VehicleDetailScreen(vehicleId: id);
            },
          ),

          // Membership
          GoRoute(
            path: '/membership',
            name: 'membership',
            builder: (_, __) => const MembershipScreen(),
          ),
          GoRoute(
            path: '/membership/card',
            name: 'membership-card',
            builder: (_, __) => const MembershipCardScreen(),
          ),

          // Legacy history (still accessible from home)
          GoRoute(
            path: '/history',
            name: 'history',
            builder: (_, __) => const HistoryScreen(),
          ),

          // Account / edit profile
          GoRoute(
            path: '/account',
            name: 'account',
            builder: (_, __) => const AccountScreen(),
          ),

          // Assist flow (pushed from SOS or kept for backwards compat)
          GoRoute(
            path: '/assist',
            name: 'assist',
            builder: (_, __) => const AssistScreen(),
          ),
          GoRoute(
            path: '/assist/request',
            name: 'assist-request',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return RequestAssistScreen(
                issue: extra['issue'] as String? ?? 'Towing',
                vehicleId: extra['vehicleId'] as String?,
                vehicleSummary:
                    extra['vehicleSummary'] as Map<String, dynamic>?,
              );
            },
          ),
          GoRoute(
            path: '/assist/providers',
            name: 'assist-providers',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>;
              return ProvidersResultsScreen(
                issue: extra['issue'] as String,
                serviceCode: extra['serviceCode'] as String,
                locationLabel: extra['locationLabel'] as String,
                providers: (extra['providers'] as List)
                    .cast<Map<String, dynamic>>(),
                driverName: extra['driverName'] as String,
                driverPhone: extra['driverPhone'] as String,
                lat: extra['lat'] as double,
                lng: extra['lng'] as double,
              );
            },
          ),
        ],
      ),
    ],
  );
});
