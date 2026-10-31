import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../l10n/app_localizations.dart';

/// شاشة خطأ بديلة للـ Spinner اللانهائي اللي كان بيظهر لو وصلت الشاشة
/// من غير الموديل/الكنترولر المطلوب (مثلاً navigation من غير الـ arguments
/// الصحيحة). بدل ما المستخدم يفضل شايف تحميل من غير أي تفسير، بيشوف رسالة
/// واضحة وزرار رجوع.
class BookingLoadError extends StatelessWidget {
  const BookingLoadError({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.accentRed),
              const SizedBox(height: 16),
              Text(l10n.bookingLoadError, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              Text(l10n.bookingLoadErrorSubtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(l10n.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
