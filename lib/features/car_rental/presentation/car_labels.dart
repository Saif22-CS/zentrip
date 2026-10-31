import '../../../l10n/app_localizations.dart';

String carFuelLabel(AppLocalizations l10n, String fuel) => switch (fuel) {
      'electric' => l10n.carFuelElectric,
      'hybrid' => l10n.carFuelHybrid,
      'diesel' => l10n.carFuelDiesel,
      _ => l10n.carFuelPetrol,
    };
