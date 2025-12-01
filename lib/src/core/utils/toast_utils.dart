import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:motor_ambos/src/app/theme.dart';

class ToastUtils {
  static void showSuccess(BuildContext context, {required String title, String? description}) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: description != null ? Text(description) : null,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        )
      ],
      showProgressBar: false,
      primaryColor: AppColors.forestGreen,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  static void showError(BuildContext context, {required String title, String? description}) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: description != null ? Text(description) : null,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: false,
      primaryColor: AppColors.error,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  static void showInfo(BuildContext context, {required String title, String? description}) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: description != null ? Text(description) : null,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: false,
      primaryColor: AppColors.brightLime, // Neon/Lime
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
