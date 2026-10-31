import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../global_widgets/theme_controller.dart';
import '../../../../l10n/app_localizations.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final options = [
      (ThemeMode.light, Icons.light_mode_rounded, l10n.lightMode),
      (ThemeMode.dark, Icons.dark_mode_rounded, l10n.darkMode),
      (ThemeMode.system, Icons.settings_suggest_rounded, l10n.systemDefault),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearance)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListenableBuilder(
          listenable: ThemeController.instance,
          builder: (_, __) {
            final current = ThemeController.instance.themeMode;
            return Column(
              children: options.map((opt) {
                final (mode, icon, label) = opt;
                final isSelected = current == mode;
                return GestureDetector(
                  onTap: () => ThemeController.instance.setTheme(mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primarySurface : (isDark ? AppColors.darkSurface : AppColors.surface),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.border), width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: isSelected ? Colors.white : AppColors.textSecondary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 15)),
                        const Spacer(),
                        if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
