import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../logic/favorites_controller.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favorites)),
      body: ListenableBuilder(
        listenable: FavoritesController.instance,
        builder: (_, __) {
          final favs = FavoritesController.instance.all;
          if (favs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle),
                    child: const Icon(Icons.bookmark_border_rounded,
                        color: AppColors.primary, size: 44),
                  )
                      .animate()
                      .scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 20),
                  Text(l10n.noFavorites,
                          style: Theme.of(context).textTheme.titleMedium)
                      .animate()
                      .fade(delay: 200.ms),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(l10n.noFavoritesSubtitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium)
                        .animate()
                        .fade(delay: 300.ms),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: favs.length,
            itemBuilder: (_, i) {
              final fav = favs[i];
              return Dismissible(
                key: Key(fav.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                      color: AppColors.accentRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.bookmark_remove_rounded,
                      color: AppColors.accentRed),
                ),
                onDismissed: (_) => FavoritesController.instance.remove(fav.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.destinationGradients[
                              i % AppColors.destinationGradients.length],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_typeIcon(fav.type),
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fav.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14)),
                            const SizedBox(height: 3),
                            Text(fav.subtitle,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            FavoritesController.instance.remove(fav.id),
                        child: const Icon(Icons.bookmark_rounded,
                            color: AppColors.primary, size: 22),
                      ),
                    ],
                  ),
                )
                    .animate(delay: Duration(milliseconds: 60 * i))
                    .fade()
                    .slideY(begin: 0.05, end: 0),
              );
            },
          );
        },
      ),
    );
  }

  IconData _typeIcon(String type) => switch (type) {
        'hotel' => Icons.hotel_rounded,
        'attraction' => Icons.photo_camera_rounded,
        'restaurant' => Icons.restaurant_rounded,
        _ => Icons.location_on_rounded,
      };
}
