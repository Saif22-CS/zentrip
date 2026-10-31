import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

IconData attractionCategoryIcon(String cat) => switch (cat) {
      'landmark' => Icons.account_balance_rounded,
      'historical' => Icons.history_edu_rounded,
      'natural' => Icons.landscape_rounded,
      'cultural' => Icons.theater_comedy_rounded,
      'architecture' => Icons.temple_hindu_rounded,
      'museum' => Icons.museum_rounded,
      'park' => Icons.park_rounded,
      'beach' => Icons.beach_access_rounded,
      'shopping' => Icons.shopping_bag_rounded,
      'restaurant' => Icons.restaurant_rounded,
      'cafe' => Icons.local_cafe_rounded,
      _ => Icons.place_rounded,
    };

String attractionCategoryLabel(AppLocalizations l10n, String cat) =>
    switch (cat) {
      'all' => l10n.attractionCategoryAll,
      'landmark' => l10n.landmark,
      'historical' => l10n.attractionCatHistorical,
      'natural' => l10n.attractionCatNatural,
      'cultural' => l10n.attractionCatCultural,
      'architecture' => l10n.attractionCatArchitecture,
      'museum' => l10n.museum,
      'park' => l10n.park,
      'beach' => l10n.beach,
      'shopping' => l10n.shopping,
      'restaurant' => l10n.restaurant,
      'cafe' => l10n.attractionCatCafe,
      _ => cat,
    };
