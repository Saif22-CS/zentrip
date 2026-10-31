import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../global_widgets/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/travel_preferences.dart';

class TravelPreferencesScreen extends StatefulWidget {
  const TravelPreferencesScreen({super.key});

  @override
  State<TravelPreferencesScreen> createState() =>
      _TravelPreferencesScreenState();
}

class _TravelPreferencesScreenState extends State<TravelPreferencesScreen> {
  static const _interestOptions = <String>[
    'culture',
    'food',
    'nature',
    'beaches',
    'history',
    'shopping',
    'adventure',
  ];

  final _destinationController = TextEditingController();
  TravelPreferences _preferences = const TravelPreferences();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await ApiService.instance.getTravelPreferences();
    if (!mounted) return;
    if (result.isSuccess && result.data != null) {
      setState(() {
        _preferences = result.data!;
        _destinationController.text = _preferences.preferredDestination;
        _loadError = null;
        _isLoading = false;
      });
    } else {
      setState(() {
        _loadError = result.errorMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final result = await ApiService.instance.saveTravelPreferences(
      _preferences.copyWith(
        preferredDestination: _destinationController.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (result.isSuccess && result.data != null) {
      setState(() => _preferences = result.data!);
      AppSnackbar.success(
          context, AppLocalizations.of(context).travelPreferencesSaved);
    } else {
      AppSnackbar.error(
        context,
        result.errorMessage ?? AppLocalizations.of(context).genericError,
      );
    }
  }

  String _interestLabel(AppLocalizations l10n, String interest) =>
      switch (interest) {
        'culture' => l10n.travelInterestCulture,
        'food' => l10n.travelInterestFood,
        'nature' => l10n.travelInterestNature,
        'beaches' => l10n.travelInterestBeaches,
        'history' => l10n.travelInterestHistory,
        'shopping' => l10n.travelInterestShopping,
        'adventure' => l10n.travelInterestAdventure,
        _ => interest,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.travelPreferencesTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                if (_loadError != null) ...[
                  Text(l10n.travelPreferencesLoadError,
                      style: const TextStyle(color: AppColors.accentRed)),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() => _isLoading = true);
                        _load();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.retry),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _PreferenceSection(
                  title: l10n.travelBudgetLabel,
                  isDark: isDark,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _choice(
                          l10n.travelBudgetLow,
                          'budget',
                          _preferences.budgetLevel,
                          isDark,
                          (value) => setState(() => _preferences =
                              _preferences.copyWith(budgetLevel: value))),
                      _choice(
                          l10n.travelBudgetBalanced,
                          'balanced',
                          _preferences.budgetLevel,
                          isDark,
                          (value) => setState(() => _preferences =
                              _preferences.copyWith(budgetLevel: value))),
                      _choice(
                          l10n.travelBudgetLuxury,
                          'luxury',
                          _preferences.budgetLevel,
                          isDark,
                          (value) => setState(() => _preferences =
                              _preferences.copyWith(budgetLevel: value))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _PreferenceSection(
                  title: l10n.travelPaceLabel,
                  isDark: isDark,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _choice(
                          l10n.travelPaceRelaxed,
                          'relaxed',
                          _preferences.travelPace,
                          isDark,
                          (value) => setState(() => _preferences =
                              _preferences.copyWith(travelPace: value))),
                      _choice(
                          l10n.travelPaceBalanced,
                          'balanced',
                          _preferences.travelPace,
                          isDark,
                          (value) => setState(() => _preferences =
                              _preferences.copyWith(travelPace: value))),
                      _choice(
                          l10n.travelPacePacked,
                          'packed',
                          _preferences.travelPace,
                          isDark,
                          (value) => setState(() => _preferences =
                              _preferences.copyWith(travelPace: value))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _PreferenceSection(
                  title:
                      l10n.travelDurationLabel(_preferences.tripDurationDays),
                  isDark: isDark,
                  child: Slider(
                    value: _preferences.tripDurationDays.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    label: '${_preferences.tripDurationDays}',
                    onChanged: (value) => setState(() => _preferences =
                        _preferences.copyWith(tripDurationDays: value.round())),
                  ),
                ),
                const SizedBox(height: 16),
                _PreferenceSection(
                  title: l10n.travelersLabel,
                  isDark: isDark,
                  child: Row(
                    children: [
                      IconButton.outlined(
                        onPressed: _preferences.travelers > 1
                            ? () => setState(() => _preferences =
                                _preferences.copyWith(
                                    travelers: _preferences.travelers - 1))
                            : null,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text('${_preferences.travelers}',
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      IconButton.outlined(
                        onPressed: _preferences.travelers < 12
                            ? () => setState(() => _preferences =
                                _preferences.copyWith(
                                    travelers: _preferences.travelers + 1))
                            : null,
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _PreferenceSection(
                  title: l10n.travelDestinationLabel,
                  isDark: isDark,
                  child: TextField(
                    controller: _destinationController,
                    maxLength: 255,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: l10n.travelDestinationHint,
                      prefixIcon: const Icon(Icons.place_outlined),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _PreferenceSection(
                  title: l10n.travelInterestsLabel,
                  isDark: isDark,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _interestOptions.map((interest) {
                      final selected =
                          _preferences.interests.contains(interest);
                      return FilterChip(
                        label: Text(_interestLabel(l10n, interest)),
                        selected: selected,
                        backgroundColor: isDark
                            ? AppColors.darkSurfaceSecondary
                            : AppColors.surfaceSecondary,
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                        ),
                        onSelected: (value) {
                          final interests = [..._preferences.interests];
                          value
                              ? interests.add(interest)
                              : interests.remove(interest);
                          setState(() => _preferences =
                              _preferences.copyWith(interests: interests));
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(l10n.saveChanges),
                ),
              ],
            ),
    );
  }

  Widget _choice(
    String label,
    String value,
    String selectedValue,
    bool isDark,
    ValueChanged<String> onSelected,
  ) =>
      ChoiceChip(
        label: Text(label),
        selected: selectedValue == value,
        backgroundColor: isDark
            ? AppColors.darkSurfaceSecondary
            : AppColors.surfaceSecondary,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: selectedValue == value
              ? Colors.white
              : isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
        ),
        onSelected: (_) => onSelected(value),
      );
}

class _PreferenceSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final Widget child;

  const _PreferenceSection({
    required this.title,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          ),
        ],
      );
}
