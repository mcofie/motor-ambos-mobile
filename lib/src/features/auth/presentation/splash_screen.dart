import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/app/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to app after animation
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/app');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brightLime.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                CupertinoIcons.car_detailed,
                size: 64,
                color: AppColors.brightLime,
              ),
            ).animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .fade(duration: 400.ms),

            const SizedBox(height: 24),

            // App Name
            const Text(
              'Motor Ambos',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1.0,
              ),
            ).animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'Premium Roadside Assistance',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
            ).animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
            
            const SizedBox(height: 48),
            
            // Loading Indicator
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brightLime),
              ),
            ).animate()
                .fadeIn(duration: 600.ms, delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}
