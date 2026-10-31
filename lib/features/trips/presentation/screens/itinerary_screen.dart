import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/booking_model.dart';

class _ItineraryItem {
  final DateTime date;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _ItineraryItem(
      {required this.date,
      required this.icon,
      required this.color,
      required this.title,
      required this.subtitle});
}

/// مخطط رحلة يومي — بيجمع كل حجوزاتك الحقيقية (طيران/فندق/سيارة/نشاط/عرض)
/// في جدول زمني واحد مرتّب باليوم، بدل ما تكون متفرقة في شاشات منفصلة.
class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  bool _isLoading = true;
  List<_ItineraryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final flightsResult = await ApiService.instance.getMyFlightTrips();
    final bookingsResult = await ApiService.instance.getMyBookings();
    final flights =
        (flightsResult.data ?? []).where((t) => t.status == 'upcoming');
    final bookings =
        (bookingsResult.data ?? []).where((b) => b.status == 'upcoming');

    final items = <_ItineraryItem>[
      ...flights.map((t) => _ItineraryItem(
            date: t.departureDate,
            icon: Icons.flight_takeoff_rounded,
            color: AppColors.primary,
            title: '${t.originCode} → ${t.destinationCode}',
            subtitle: t.flightNumber,
          )),
      ...bookings.map((b) => _ItineraryItem(
            date: b.date,
            icon: _iconFor(b.type),
            color: _colorFor(b.type),
            title: b.title,
            subtitle: b.subtitle,
          )),
    ]..sort((a, b) => a.date.compareTo(b.date));

    if (!mounted) return;
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  IconData _iconFor(BookingType t) => switch (t) {
        BookingType.hotel => Icons.hotel_rounded,
        BookingType.car => Icons.directions_car_rounded,
        BookingType.attraction => Icons.local_activity_rounded,
        BookingType.package => Icons.card_travel_rounded,
      };

  Color _colorFor(BookingType t) => switch (t) {
        BookingType.hotel => AppColors.primary,
        BookingType.car => AppColors.accentOrange,
        BookingType.attraction => AppColors.accentPurple,
        BookingType.package => AppColors.accentGreen,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.itineraryTitle)),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_outlined,
                          size: 48, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(l10n.itineraryEmpty,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final item = _items[i];
                      final showDateHeader =
                          i == 0 || !_sameDay(_items[i - 1].date, item.date);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader) ...[
                            if (i != 0) const SizedBox(height: 12),
                            Text(
                              DateTimeUtils.formatDate(item.date,
                                  locale: locale),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                      color: item.color.withValues(alpha: 0.12),
                                      shape: BoxShape.circle),
                                  child: Icon(item.icon,
                                      size: 17, color: item.color),
                                ),
                                if (i != _items.length - 1)
                                  Container(
                                      width: 2,
                                      height: 40,
                                      color: isDark
                                          ? AppColors.darkBorder
                                          : AppColors.border),
                              ]),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14)),
                                      const SizedBox(height: 3),
                                      Text(item.subtitle,
                                          style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12.5)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
