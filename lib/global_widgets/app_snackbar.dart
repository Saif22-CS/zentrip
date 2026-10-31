import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// شريط الإشعارات الموحّد — كل رسائل النجاح/الخطأ/التحذير تمر من هنا.
abstract class AppSnackbar {
  static void success(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.check_circle_rounded, color: AppColors.accentGreen);
  }

  static void error(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.error_rounded, color: AppColors.accentRed);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.warning_amber_rounded, color: AppColors.accentOrange);
  }

  static void info(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.info_outline_rounded, color: AppColors.primary);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          duration: const Duration(seconds: 3),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
