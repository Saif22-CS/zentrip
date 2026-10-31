import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/app_colors.dart';
import '../l10n/app_localizations.dart';

class NoInternetView extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.accentRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, color: AppColors.accentRed, size: 42),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              l10n.noInternetTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ).animate().fade(delay: 200.ms),
            const SizedBox(height: 10),
            Text(
              l10n.noInternetSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ).animate().fade(delay: 300.ms),
            const SizedBox(height: 32),
            SizedBox(
              width: 160,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.retry),
              ),
            ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
