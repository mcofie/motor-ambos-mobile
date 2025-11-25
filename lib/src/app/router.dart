// lib/src/app_router.dart (or wherever this file lives)
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:motor_ambos/src/core/widget/app_shell.dart';
import 'package:motor_ambos/src/features/auth/presentation/signup_page.dart';
import 'package:motor_ambos/src/features/auth/presentation/login_page.dart';
import 'package:motor_ambos/src/features/home/presentation/home_screen.dart';
import 'package:motor_ambos/src/features/account/presentation/account_screen.dart';
import 'package:motor_ambos/src/features/assist/presentation/assist_screen.dart';
import 'package:motor_ambos/src/features/assist/presentation/request_assist_screen.dart';
import 'package:motor_ambos/src/features/garage/presentation/garage_screen.dart';
import 'package:motor_ambos/src/features/garage/presentation/add_vehicle_screen.dart';
import 'package:motor_ambos/src/features/membership/presentation/membership_screen.dart';
import 'package:motor_ambos/src/features/membership/presentation/membership_card_screen.dart';
import 'package:motor_ambos/src/features/more/presentation/more_screen.dart';
import 'package:motor_ambos/src/features/assist/presentation/providers_results_screen.dart';
import 'package:motor_ambos/src/features/history/presentation/history_screen.dart';
import 'package:motor_ambos/src/core/models/vehicle.dart';

/// Small helper so GoRouter rebuilds when Supabase auth state changes
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
    initialLocation: '/app',

    /// 🔁 Rebuild router when auth changes (login/logout / OAuth finish)
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),

    /// 🔐 Global auth guard
    redirect: (context, state) {
      final session = supabase.auth.currentSession;

      // Is the user currently on the sign-in or sign-up screen?
      final loggingIn =
          state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/sign-up';

      // Not logged in & trying to hit a protected route → send to sign-in
      if (session == null && !loggingIn) {
        return '/sign-in';
      }

      // Logged in & trying to hit auth screens → send to app home
      if (session != null && loggingIn) {
        return '/app';
      }

      // No redirect
      return null;
    },

    routes: [
      // Public auth routes
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'sign-up',
        builder: (context, state) => const SignupPage(),
      ),

      // Shell with bottom nav / shared chrome
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/app',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/assist',
            name: 'assist',
            builder: (context, state) => const AssistScreen(),
          ),
          GoRoute(
            name: 'assist-request',
            path: '/assist/request',
            builder: (context, state) {
              // extra expected as a Map<String, dynamic>
              final extra = state.extra as Map<String, dynamic>? ?? {};

              final issue = extra['issue'] as String? ?? 'Towing';
              final vehicleId = extra['vehicleId'] as String?;
              final vehicleSummary =
                  extra['vehicleSummary'] as Map<String, dynamic>?;

              return RequestAssistScreen(
                issue: issue,
                vehicleId: vehicleId,
                vehicleSummary: vehicleSummary,
              );
            },
          ),
          GoRoute(
            path: '/assist/providers',
            name: 'assist-providers',
            builder: (context, state) {
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
          GoRoute(
            path: '/garage',
            name: 'garage',
            builder: (context, state) => const GarageScreen(),
          ),
          GoRoute(
            path: '/garage/add',
            name: 'garage-add',
            builder: (context, state) {
              final extra = state.extra;
              return AddVehicleScreen(vehicle: extra is Vehicle ? extra : null);
            },
          ),
          GoRoute(
            path: '/membership',
            name: 'membership',
            builder: (context, state) => const MembershipScreen(),
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/membership/card',
            name: 'membership-card',
            builder: (context, state) => const MembershipCardScreen(),
          ),
          GoRoute(
            path: '/account',
            name: 'account',
            builder: (context, state) => const AccountScreen(),
          ),
          GoRoute(
            path: '/more',
            name: 'more',
            builder: (context, state) => const MoreScreen(),
          ),
        ],
      ),
    ],
  );
});
