import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/connectivity_service.dart';
import '../l10n/app_localizations.dart';

/// بانر رفيع بيظهر فوق أي شاشة لما مفيش اتصال بالإنترنت — الشاشات المهمة
/// (زي "رحلاتي") بتفضل شغالة برضه لأنها بتعتمد على نسخة محفوظة محليًا.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ConnectivityService.instance,
      builder: (context, _) {
        if (ConnectivityService.instance.isOnline) return const SizedBox.shrink();
        final l10n = AppLocalizations.of(context);
        return Container(
          width: double.infinity,
          color: AppColors.accentRed,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 13),
              const SizedBox(width: 6),
              Text(l10n.offlineBannerText, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }
}
