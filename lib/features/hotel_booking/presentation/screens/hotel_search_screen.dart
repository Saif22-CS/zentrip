import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/current_location_service.dart';
import '../../../../global_widgets/app_snackbar.dart';
import '../../../../global_widgets/booking_loading_overlay.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/flight_model.dart';
import '../../../../routes/app_routes.dart';
import '../../logic/hotel_controller.dart';

/// مفتاح تخزين آخر مدينة تم البحث عنها، يُستخدم من شاشة SearchHotelsScreen
/// (لعرض اقتراح "كرر آخر بحث") ومن هذه الشاشة نفسها.
class HotelSearchHistory {
  static const _cityKey = 'last_hotel_city';

  static Future<String?> lastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cityKey);
  }

  static Future<void> saveCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, city);
  }
}

class HotelSearchScreen extends StatefulWidget {
  /// مدينة مبدئية تُملأ تلقائيًا (قادمة من باقة سياحية أو من آخر بحث).
  final String? initialCity;
  final DateTime? initialCheckIn;
  final DateTime? initialCheckOut;
  final int? initialGuests;
  final CurrentLocationService locationService;
  const HotelSearchScreen({
    super.key,
    this.initialCity,
    this.initialCheckIn,
    this.initialCheckOut,
    this.initialGuests,
    this.locationService = const CurrentLocationService(),
  });

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  final _ctrl = HotelController();
  final _cityCtrl = TextEditingController();
  TextEditingController? _autocompleteController;
  bool _cityInitialized = false;
  bool _isLoadingCurrentCity = false;
  bool _isLoadingNearby = false;
  String? _locationMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cityInitialized) {
      final initialCity = widget.initialCity?.trim();
      if (initialCity != null && initialCity.isNotEmpty) {
        _cityCtrl.text = initialCity;
      }
      _checkIn = widget.initialCheckIn ?? _checkIn;
      _checkOut = widget.initialCheckOut ?? _checkOut;
      _guests = widget.initialGuests ?? _guests;
      _cityInitialized = true;
    }
  }

  Future<void> _loadCurrentCity({bool overrideExisting = false}) async {
    setState(() {
      _isLoadingCurrentCity = true;
      _locationMessage = null;
    });
    try {
      final place = await widget.locationService.getCurrentPlace();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final airport = AirportOption.nearestTo(
        place.position.latitude,
        place.position.longitude,
      );
      final city = AirportOption.byCity(place.city ?? '')?.city ??
          airport?.city ??
          place.city;
      if ((overrideExisting || _cityCtrl.text.trim().isEmpty) && city != null) {
        _cityCtrl.text = city;
        _autocompleteController?.text = city;
      }
      setState(() {
        _isLoadingCurrentCity = false;
        _locationMessage = city == null ? l10n.currentCityUnavailable : null;
      });
    } on CurrentLocationException catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _isLoadingCurrentCity = false;
        _locationMessage = switch (error.reason) {
          CurrentLocationError.serviceDisabled =>
            l10n.nearbyLocationServiceDisabled,
          CurrentLocationError.permissionDenied =>
            l10n.nearbyLocationPermissionDenied,
          CurrentLocationError.permissionDeniedForever =>
            l10n.nearbyLocationPermissionDeniedForever,
          CurrentLocationError.unableToDetermine =>
            l10n.nearbyLocationUnableToDetermine,
        };
      });
    } finally {
      if (mounted && _isLoadingCurrentCity) {
        setState(() => _isLoadingCurrentCity = false);
      }
    }
  }

  DateTime _checkIn = DateTime.now().add(const Duration(days: 7));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 10));
  int _rooms = 1;
  int _guests = 2;

  Future<void> _search() async {
    final city = (_autocompleteController ?? _cityCtrl).text.trim();
    if (city.isEmpty) {
      AppSnackbar.error(
        context,
        _locationMessage ??
            AppLocalizations.of(context).hotelDestinationRequired,
      );
      return;
    }
    final params = HotelSearchParams(
      city: city,
      checkIn: _checkIn,
      checkOut: _checkOut,
      rooms: _rooms,
      guests: _guests,
    );
    await BookingLoadingOverlay.run<void>(
      context,
      title: AppLocalizations.of(context).hotelSearching,
      subtitle: city,
      serviceIcon: Icons.hotel_rounded,
      action: () => _ctrl.search(params),
    );
    unawaited(HotelSearchHistory.saveCity(city));
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.hotelResults, arguments: _ctrl);
  }

  Future<void> _searchNearby() async {
    setState(() {
      _isLoadingNearby = true;
      _locationMessage = null;
    });
    try {
      late final Position position;
      try {
        position = await widget.locationService.getPosition();
      } on CurrentLocationException catch (error) {
        if (mounted) {
          setState(() {
            _locationMessage = _locationErrorMessage(
              error.reason,
              AppLocalizations.of(context),
            );
          });
        }
        return;
      }
      final nearestAirport = AirportOption.nearestTo(
        position.latitude,
        position.longitude,
      );
      if (nearestAirport == null) {
        if (mounted) {
          setState(() => _locationMessage =
              AppLocalizations.of(context).nearbyLocationUnableToDetermine);
        }
        return;
      }
      if (!mounted) return;
      final params = HotelSearchParams(
        city: AppLocalizations.of(context).hotelNearbyTitle,
        checkIn: _checkIn,
        checkOut: _checkOut,
        rooms: _rooms,
        guests: _guests,
      );
      await BookingLoadingOverlay.run<void>(
        context,
        title: AppLocalizations.of(context).hotelSearching,
        subtitle: AppLocalizations.of(context).hotelNearbyTitle,
        serviceIcon: Icons.hotel_rounded,
        action: () async {
          await _ctrl.searchNearby(
            params,
            latitude: position.latitude,
            longitude: position.longitude,
          );
        },
      );
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.hotelResults, arguments: _ctrl);
    } finally {
      if (mounted) setState(() => _isLoadingNearby = false);
    }
  }

  String _locationErrorMessage(
    CurrentLocationError error,
    AppLocalizations l10n,
  ) =>
      switch (error) {
        CurrentLocationError.serviceDisabled =>
          l10n.nearbyLocationServiceDisabled,
        CurrentLocationError.permissionDenied =>
          l10n.nearbyLocationPermissionDenied,
        CurrentLocationError.permissionDeniedForever =>
          l10n.nearbyLocationPermissionDeniedForever,
        CurrentLocationError.unableToDetermine =>
          l10n.nearbyLocationUnableToDetermine,
      };

  TextSpan _highlightSuggestion(String value) {
    final query = _cityCtrl.text.trim();
    final start = value.toLowerCase().indexOf(query.toLowerCase());
    if (query.isEmpty || start < 0) return TextSpan(text: value);
    final end = start + query.length;
    return TextSpan(children: [
      TextSpan(text: value.substring(0, start)),
      TextSpan(
        text: value.substring(start, end),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      TextSpan(text: value.substring(end)),
    ]);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(l10n.searchHotels),
          flexibleSpace: const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.primaryGradient))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Destination ──────────────────────────────────────────────
          _Label(l10n.destination),
          const SizedBox(height: 8),
          _InputBox(
            isDark: isDark,
            child: Autocomplete<String>(
              initialValue: TextEditingValue(text: _cityCtrl.text),
              optionsBuilder: (value) =>
                  ApiService.instance.searchHotelLocations(value.text),
              onSelected: (selection) {
                _cityCtrl.text = selection;
                if (_locationMessage != null) {
                  setState(() => _locationMessage = null);
                }
              },
              optionsViewBuilder: (context, onSelected, options) => Align(
                alignment: AlignmentDirectional.topStart,
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: options
                          .map((option) => ListTile(
                                dense: true,
                                leading: const Icon(Icons.place_outlined),
                                title: Text.rich(_highlightSuggestion(option)),
                                onTap: () => onSelected(option),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                _autocompleteController = controller;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (value) {
                    _cityCtrl.text = value;
                    if (_locationMessage != null) {
                      setState(() => _locationMessage = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: l10n.hotelDestinationHint,
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.primary),
                    suffixIcon: _isLoadingCurrentCity
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            tooltip: l10n.useCurrentLocation,
                            onPressed: () =>
                                _loadCurrentCity(overrideExisting: true),
                            icon: const Icon(Icons.my_location_rounded),
                          ),
                    border: InputBorder.none,
                    filled: false,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                );
              },
            ),
          ).animate().fade(duration: 300.ms),
          if (_locationMessage != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 12, top: 6),
              child: Text(
                _locationMessage!,
                style:
                    const TextStyle(color: AppColors.accentRed, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),

          // ── Dates ─────────────────────────────────────────────────────
          Row(children: [
            Expanded(
                child: _DatePick(
                    label: l10n.checkIn,
                    date: _checkIn,
                    icon: Icons.login_rounded,
                    isDark: isDark,
                    onTap: () async {
                      final d = await showDatePicker(
                          context: context,
                          initialDate: _checkIn,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)));
                      if (d != null) setState(() => _checkIn = d);
                    })),
            const SizedBox(width: 12),
            Expanded(
                child: _DatePick(
                    label: l10n.checkOut,
                    date: _checkOut,
                    icon: Icons.logout_rounded,
                    isDark: isDark,
                    onTap: () async {
                      final d = await showDatePicker(
                          context: context,
                          initialDate: _checkOut,
                          firstDate: _checkIn.add(const Duration(days: 1)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)));
                      if (d != null) setState(() => _checkOut = d);
                    })),
          ]).animate().fade(delay: 100.ms),
          const SizedBox(height: 16),

          // ── Rooms + Guests ────────────────────────────────────────────
          Row(children: [
            Expanded(
                child: _Stepper(
                    label: l10n.hotelRoomsLabel,
                    icon: Icons.hotel_rounded,
                    value: _rooms,
                    isDark: isDark,
                    min: 1,
                    max: 9,
                    onChanged: (v) => setState(() => _rooms = v))),
            const SizedBox(width: 12),
            Expanded(
                child: _Stepper(
                    label: l10n.hotelGuestsLabel,
                    icon: Icons.people_rounded,
                    value: _guests,
                    isDark: isDark,
                    min: 1,
                    max: 20,
                    onChanged: (v) => setState(() => _guests = v))),
          ]).animate().fade(delay: 180.ms),

          // ── Summary ───────────────────────────────────────────────────
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.nights_stay_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Text(
                  l10n.hotelStaySummary(
                      _checkOut.difference(_checkIn).inDays, _rooms, _guests),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ]),
          ).animate().fade(delay: 240.ms),
          const SizedBox(height: 28),

          // ── Search ─────────────────────────────────────────────────────
          ListenableBuilder(
            listenable: _ctrl,
            builder: (_, __) => Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _ctrl.isLoading || _isLoadingNearby ? null : _search,
                    icon: _ctrl.isLoading && !_isLoadingNearby
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.search_rounded),
                    label: Text(_ctrl.isLoading && !_isLoadingNearby
                        ? l10n.hotelSearching
                        : l10n.searchHotelsBtn),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _ctrl.isLoading || _isLoadingNearby
                        ? null
                        : _searchNearby,
                    icon: _isLoadingNearby
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.near_me_outlined),
                    label: Text(l10n.hotelSearchNearby),
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 300.ms),
        ]),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textSecondary));
}

class _InputBox extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _InputBox({required this.child, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border)),
        child: child,
      );
}

class _DatePick extends StatelessWidget {
  final String label;
  final DateTime date;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _DatePick(
      {required this.label,
      required this.date,
      required this.icon,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(icon, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Text('${date.day}/${date.month}/${date.year}',
                style: const TextStyle(fontWeight: FontWeight.w700))
          ]),
        ]),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value, min, max;
  final bool isDark;
  final void Function(int) onChanged;
  const _Stepper(
      {required this.label,
      required this.icon,
      required this.value,
      required this.isDark,
      required this.min,
      required this.max,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 5),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textSecondary))
        ]),
        const SizedBox(height: 8),
        Row(children: [
          GestureDetector(
              onTap: value > min ? () => onChanged(value - 1) : null,
              child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.remove_rounded,
                      color: AppColors.primary, size: 16))),
          Expanded(
              child: Text('$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18))),
          GestureDetector(
              onTap: value < max ? () => onChanged(value + 1) : null,
              child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add_rounded,
                      color: AppColors.primary, size: 16))),
        ]),
      ]),
    );
  }
}
