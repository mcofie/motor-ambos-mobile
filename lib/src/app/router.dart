import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:motor_ambos/src/core/widget/app_shell.dart';
import 'package:motor_ambos/src/features/auth/presentation/sign_in_screen.dart';
import 'package:motor_ambos/src/features/home/presentation/home_screen.dart';
import 'package:motor_ambos/src/features/account/presentation/account_screen.dart';
import 'package:motor_ambos/src/features/assist/presentation/assist_screen.dart';
import 'package:motor_ambos/src/features/assist/presentation/request_assist_screen.dart';
import 'package:motor_ambos/src/features/garage/presentation/garage_screen.dart';
import 'package:motor_ambos/src/features/garage/presentation/add_vehicle_screen.dart';
import 'package:motor_ambos/src/features/membership/presentation/membership_screen.dart';
import 'package:motor_ambos/src/features/membership/presentation/membership_card_screen.dart';
import 'package:motor_ambos/src/features/more/presentation/more_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/app',
    routes: [
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
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
            path: '/assist/request',
            name: 'assist-request',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final issue = extra?['issue'] as String? ?? 'Towing';

              return RequestAssistScreen(
                issue: issue,
              );
            },
          ),
          GoRoute(
            path: '/garage',
            name: 'garage',
            builder: (context, state) => const GarageScreen(),
          ),
          GoRoute(
            path: '/account',
            name: 'account',
            builder: (context, state) => const AccountScreen(),
          ),
          GoRoute(
            path: '/garage/add',
            name: 'garage-add',
            builder: (context, state) => const AddVehicleScreen(),
          ),
          GoRoute(
            path: '/membership',
            name: 'membership',
            builder: (context, state) => const MembershipScreen(),
          ),
          GoRoute(
            path: '/membership/card',
            name: 'membership-card',
            builder: (context, state) => const MembershipCardScreen(),
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
