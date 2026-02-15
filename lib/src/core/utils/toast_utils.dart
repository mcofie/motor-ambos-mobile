import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastUtils {
  static const _radius = BorderRadius.all(Radius.circular(16));
  static const _padding = EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  static const _margin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const _shadow = [
    BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 12), spreadRadius: 0)
  ];

  static void showSuccess(BuildContext context, {required String title, String? description}) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
      description: description != null 
          ? Text(description, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)) 
          : null,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: _radius,
      boxShadow: _shadow,
      showProgressBar: true,
      dragToClose: true,
      primaryColor: const Color(0xFF22C55E), // Bright Green
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      foregroundColor: Colors.white,
      padding: _padding,
      margin: _margin,
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 28),
    );
  }

  static void showError(BuildContext context, {required String title, String? description}) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
      description: description != null 
          ? Text(description, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)) 
          : null,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 5),
      borderRadius: _radius,
      boxShadow: _shadow,
      showProgressBar: true,
      dragToClose: true,
      primaryColor: const Color(0xFFEF4444), // Bright Red
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      foregroundColor: Colors.white,
      padding: _padding,
      margin: _margin,
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      icon: const Icon(Icons.error_rounded, color: Color(0xFFEF4444), size: 28),
    );
  }

  static void showInfo(BuildContext context, {required String title, String? description}) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
      description: description != null 
          ? Text(description, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)) 
          : null,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: _radius,
      boxShadow: _shadow,
      showProgressBar: true,
      dragToClose: true,
      primaryColor: const Color(0xFF3B82F6), // Bright Blue
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      foregroundColor: Colors.white,
      padding: _padding,
      margin: _margin,
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      icon: const Icon(Icons.info_rounded, color: Color(0xFF3B82F6), size: 28),
    );
  }
}
