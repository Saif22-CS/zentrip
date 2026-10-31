import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/travel_package_model.dart';
import '../../../flight_booking/presentation/screens/flight_search_screen.dart';

/// شاشة وسيطة قبل البحث عن الطيران: بتقترح وجهة جاهزة بدل ما تسيب المستخدم
/// يكتب كل حاجة من الصفر — إما من باقة سياحية مفتوحة، أو من آخر بحث محفوظ.
class SearchFlightsScreen extends StatefulWidget {
  const SearchFlightsScreen({super.key});

  @override
  State<SearchFlightsScreen> createState() => _SearchFlightsScreenState();
}

class _SearchFlightsScreenState extends State<SearchFlightsScreen> {
  ({String code, String city})? _lastDestination;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _loadLastSearch();
  }

  Future<void> _loadLastSearch() async {
    final last = await FlightSearchHistory.lastDestination();
    if (!mounted) return;
    setState(() {
      _lastDestination = last;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final package = ModalRoute.of(context)?.settings.arguments as TravelPackage?;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchFlights)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (package != null)
                    _SuggestionCard(
                      isDark: isDark,
                      icon: Icons.card_travel_rounded,
                      color: AppColors.accentPurple,
                      title: l10n.tripsSuggestedFromPackage,
                      subtitle: '${package.location}, ${package.country}',
                      buttonLabel: l10n.tripsSearchFlightsTo(package.location),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlightSearchScreen(
                            initialDestinationCity: package.location,
                          ),
                        ),
                      ),
                    ).animate().fade().slideY(begin: 0.05, end: 0)
                  else if (_lastDestination != null)
                    _SuggestionCard(
                      isDark: isDark,
                      icon: Icons.history_rounded,
                      color: AppColors.primary,
                      title: l10n.tripsRepeatLastSearch,
                      subtitle: '${_lastDestination!.code} · ${_lastDestination!.city}',
                      buttonLabel: l10n.tripsSearchFlightsTo(_lastDestination!.city),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlightSearchScreen(
                            initialDestinationCode: _lastDestination!.code,
                            initialDestinationCity: _lastDestination!.city,
                          ),
                        ),
                      ),
                    ).animate().fade().slideY(begin: 0.05, end: 0),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FlightSearchScreen()),
                    ),
                    icon: const Icon(Icons.search_rounded),
                    label: Text(l10n.tripsGoToFlightSearch),
                  ).animate().fade(delay: 100.ms),
                ],
              ),
            ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.isDark,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
