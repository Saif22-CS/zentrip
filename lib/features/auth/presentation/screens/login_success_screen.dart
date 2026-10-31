import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../routes/app_routes.dart';

class LoginSuccessScreen extends StatefulWidget {
  const LoginSuccessScreen({super.key});

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        final user = ApiService.instance.currentUser;
        final destination = user?.isAdmin == true
            ? AppRoutes.adminDashboard
            : user?.isPartner == true
                ? AppRoutes.partnerDashboard
                : AppRoutes.home;
        Navigator.pushReplacementNamed(context, destination);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .fade(duration: 400.ms),
            const SizedBox(height: 28),
            Text(
              l10n.commonWelcomeToZentrip,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
              textAlign: TextAlign.center,
            ).animate().fade(delay: 400.ms).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 10),
            Text(
              l10n.commonReadyToExplore,
              style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.8)),
            ).animate().fade(delay: 600.ms),
            const SizedBox(height: 48),
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white.withValues(alpha: 0.6)),
            ).animate().fade(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
