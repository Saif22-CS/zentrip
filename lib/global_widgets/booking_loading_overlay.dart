import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Shared, branded loading treatment for searches and booking saves.
abstract class BookingLoadingOverlay {
  static Future<T> run<T>(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Future<T> Function() action,
    IconData serviceIcon = Icons.flight_rounded,
  }) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    unawaited(showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.white.withValues(alpha: 0.84),
      builder: (_) => _BookingLoadingDialog(
        title: title,
        subtitle: subtitle,
        serviceIcon: serviceIcon,
      ),
    ));

    try {
      final pending = action();
      await Future.delayed(const Duration(milliseconds: 550));
      return await pending;
    } finally {
      if (navigator.mounted && navigator.canPop()) navigator.pop();
    }
  }
}

class _BookingLoadingDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData serviceIcon;

  const _BookingLoadingDialog({
    required this.title,
    required this.subtitle,
    required this.serviceIcon,
  });

  @override
  State<_BookingLoadingDialog> createState() => _BookingLoadingDialogState();
}

class _BookingLoadingDialogState extends State<_BookingLoadingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 176,
            height: 176,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 142,
                  height: 142,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      width: 1.5,
                    ),
                  ),
                ),
                Container(
                  width: 112,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.serviceIcon,
                          size: 27, color: AppColors.primary),
                      const SizedBox(height: 5),
                      Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _orbitController,
                  builder: (_, child) {
                    final angle = _orbitController.value * 2 * math.pi;
                    return Transform.rotate(
                      angle: angle,
                      child: Transform.translate(
                        offset: const Offset(0, -70),
                        child: Transform.rotate(
                          angle: math.pi / 4,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flight_rounded,
                        size: 19, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 112,
            child: LinearProgressIndicator(
              minHeight: 4,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: AppColors.primarySurface,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
