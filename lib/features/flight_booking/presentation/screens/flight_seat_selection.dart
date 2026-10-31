import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../global_widgets/app_snackbar.dart';
import '../../../../global_widgets/payment_checkout_screen.dart';
import '../../../../features/aircraft/aircraft.dart';
import '../../../../features/aircraft/airbus_a320.dart';
import '../../../../features/aircraft/atr72.dart';
import '../../../../models/flight_booking_model.dart';
import '../../../../models/flight_model.dart';
import '../../../../l10n/app_localizations.dart';
import 'booking_confirmed_screen.dart';
import 'flight_primary_button.dart';

const _extraPrices = <String, double>{
  'extra_baggage': 18,
  'flexible_ticket': 12,
};

class FlightSeatSelectionScreen extends StatefulWidget {
  final FlightModel flight;
  final int passengerCount;
  final String seatClass;
  final DateTime? returnDate;
  final int seatsPerSide;
  final int rowCount;

  const FlightSeatSelectionScreen({
    super.key,
    required this.flight,
    required this.passengerCount,
    required this.seatClass,
    required this.returnDate,
    required this.seatsPerSide,
    required this.rowCount,
  });

  @override
  State<FlightSeatSelectionScreen> createState() =>
      _FlightSeatSelectionScreenState();
}

class _FlightSeatSelectionScreenState extends State<FlightSeatSelectionScreen> {
  Set<String> _occupiedSeats = {};
  final Set<String> _selectedSeats = {};
  bool _loadingSeats = true;
  bool _submitting = false;
  String? _seatError;
  final Set<String> _selectedExtras = {};

  Aircraft get _aircraft {
    final name = widget.flight.aircraftName.toLowerCase();
    return name.contains('atr') || widget.flight.usesTwoByTwoSeatLayout
        ? atr72
        : airbusA320;
  }

  String? get _flightId {
    final id = widget.flight.partnerListingId?.toString() ??
        widget.flight.id.replaceFirst(RegExp(r'^partner-'), '');
    return RegExp(r'^\d+$').hasMatch(id) ? id : null;
  }

  int get _rowCount => widget.rowCount.clamp(1, _aircraft.rowCount).toInt();
  int get _seatCount => widget.seatsPerSide * 2;
  List<String> get _seatLetters => _aircraft.letters.take(_seatCount).toList();

  double get _farePerPassenger {
    return switch (widget.seatClass.toLowerCase()) {
      'business' => widget.flight.businessPrice ?? widget.flight.economyPrice,
      'first' => widget.flight.firstPrice ?? widget.flight.economyPrice,
      _ => widget.flight.economyPrice,
    };
  }

  bool _isPremiumSeat(String seat) {
    final row = int.tryParse(seat.substring(0, seat.length - 1));
    return row != null && _aircraft.legroomRows.contains(row);
  }

  double get _totalPrice {
    final seatFees = _selectedSeats.where(_isPremiumSeat).length * 15.0;
    final extras = _selectedExtras.fold<double>(
      0,
      (total, extra) => total + (_extraPrices[extra] ?? 0),
    );
    return (_farePerPassenger * widget.passengerCount + seatFees + extras) *
            1.12 +
        12;
  }

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    final flightId = _flightId;
    if (flightId == null) {
      setState(() {
        _loadingSeats = false;
        _seatError = 'This flight is missing its listing ID.';
      });
      return;
    }

    setState(() {
      _loadingSeats = true;
      _seatError = null;
    });
    final result = await ApiService.instance.getOccupiedFlightSeats(flightId);
    if (!mounted) return;
    setState(() {
      _loadingSeats = false;
      if (result.isFailure) {
        _seatError = result.errorMessage ?? 'Could not load available seats.';
      } else {
        _occupiedSeats = result.data!;
        _selectedSeats.removeWhere(_occupiedSeats.contains);
      }
    });
  }

  void _toggleSeat(String seat) {
    if (_submitting || _loadingSeats || _occupiedSeats.contains(seat)) return;
    if (_selectedSeats.contains(seat)) {
      HapticFeedback.selectionClick();
      setState(() => _selectedSeats.remove(seat));
      return;
    }
    if (_selectedSeats.length >= widget.passengerCount) {
      AppSnackbar.info(
        context,
        'Select up to ${widget.passengerCount} seats for this booking.',
      );
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedSeats.add(seat));
  }

  Future<void> _proceedToPayment() async {
    final flightId = _flightId;
    if (_submitting || flightId == null) return;
    if (_selectedSeats.length != widget.passengerCount) {
      AppSnackbar.error(
        context,
        'Select ${widget.passengerCount} seat${widget.passengerCount == 1 ? '' : 's'} to continue.',
      );
      return;
    }

    setState(() => _submitting = true);
    final availability = await ApiService.instance.checkFlightAvailability(
      departureDate: widget.flight.departureTime,
      arrivalDate: widget.flight.arrivalTime,
      returnDate: widget.returnDate,
    );
    if (!mounted) return;
    if (availability.isFailure || availability.data != true) {
      setState(() => _submitting = false);
      AppSnackbar.error(
        context,
        availability.isFailure
            ? availability.errorMessage ??
                'Could not verify flight availability.'
            : 'This flight conflicts with another booking on your account.',
      );
      return;
    }

    final reservation = await ApiService.instance.reserveFlightSeats(
      flightId: flightId,
      seats: _selectedSeats.toList()..sort(),
    );
    if (!mounted) return;
    if (reservation.isFailure) {
      setState(() => _submitting = false);
      AppSnackbar.error(
        context,
        reservation.errorMessage ?? 'Those seats are no longer available.',
      );
      await _loadSeats();
      return;
    }
    setState(() => _occupiedSeats = reservation.data!);

    final requestReference =
        'flight-$flightId-${DateTime.now().microsecondsSinceEpoch}';
    final paid = await PaymentCheckoutScreen.start(
      context,
      amountUsd: _totalPrice,
      description: '${widget.flight.flightNumber} seat booking',
      referenceId: requestReference,
    );
    if (!mounted) return;
    if (!paid) {
      final release =
          await ApiService.instance.releaseFlightSeatReservation(flightId);
      if (!mounted) return;
      setState(() => _submitting = false);
      AppSnackbar.error(
        context,
        release.isFailure
            ? 'Payment was not completed and the seat hold could not be released. ${release.errorMessage ?? ''}'
            : 'Payment was not completed. Your seat hold was released.',
      );
      await _loadSeats();
      return;
    }

    final draft = FlightBookingDraft(
      flight: widget.flight,
      passengerCount: widget.passengerCount,
      seatClass: widget.seatClass,
      seats: _selectedSeats.toList()..sort(),
      returnDate: widget.returnDate,
      totalPrice: _totalPrice,
      extras: _selectedExtras.toList()..sort(),
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingConfirmedScreen(draft: draft),
      ),
    );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Choose seats')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  _flightSummary(localizations),
                  const SizedBox(height: 18),
                  _priceSummary(),
                  const SizedBox(height: 18),
                  _extraOptions(),
                  const SizedBox(height: 18),
                  _seatMap(),
                  const SizedBox(height: 12),
                  _legend(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FlightPrimaryButton(
                label:
                    'Proceed to Payment · \$${_totalPrice.toStringAsFixed(2)}',
                icon: Icons.lock_rounded,
                loading: _submitting,
                onPressed: !_loadingSeats &&
                        _seatError == null &&
                        _selectedSeats.length == widget.passengerCount
                    ? _proceedToPayment
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flightSummary(MaterialLocalizations localizations) {
    final flight = widget.flight;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${flight.originCode}  →  ${flight.destinationCode}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${flight.airline} · ${flight.flightNumber} · ${_aircraft.name}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            '${localizations.formatMediumDate(flight.departureTime)} · ${TimeOfDay.fromDateTime(flight.departureTime).format(context)}'
            ' · ${widget.passengerCount} passenger${widget.passengerCount == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _priceSummary() {
    final baseTotal = _farePerPassenger * widget.passengerCount;
    final seatFees = _selectedSeats.where(_isPremiumSeat).length * 15.0;
    final extraFees = _selectedExtras.fold<double>(
      0,
      (total, extra) => total + (_extraPrices[extra] ?? 0),
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _priceRow(
            '${widget.seatClass} fare × ${widget.passengerCount}',
            '\$${baseTotal.toStringAsFixed(2)}',
          ),
          if (seatFees > 0) ...[
            const SizedBox(height: 6),
            _priceRow(
                'Extra-legroom seats', '\$${seatFees.toStringAsFixed(2)}'),
          ],
          if (extraFees > 0) ...[
            const SizedBox(height: 6),
            _priceRow('Selected extras', '\$${extraFees.toStringAsFixed(2)}'),
          ],
          const Divider(height: 20),
          _priceRow(
            'Estimated total including taxes and fees',
            '\$${_totalPrice.toStringAsFixed(2)}',
            bold: true,
          ),
          const SizedBox(height: 4),
          Text(
            '${_selectedSeats.length} of ${widget.passengerCount} seats selected',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _extraOptions() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.flightExtraOptions,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          _extraTile(
            key: 'extra_baggage',
            title: l10n.flightExtraBaggage,
            subtitle: l10n.flightExtraBaggageDescription,
          ),
          _extraTile(
            key: 'flexible_ticket',
            title: l10n.flightFlexibleTicket,
            subtitle: l10n.flightFlexibleTicketDescription,
          ),
        ],
      ),
    );
  }

  Widget _extraTile({
    required String key,
    required String title,
    required String subtitle,
  }) {
    final selected = _selectedExtras.contains(key);
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: selected,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '$subtitle · \$${_extraPrices[key]!.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 12),
      ),
      onChanged: _submitting
          ? null
          : (value) => setState(() {
                if (value == true) {
                  _selectedExtras.add(key);
                } else {
                  _selectedExtras.remove(key);
                }
              }),
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false}) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: bold ? AppColors.primary : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );

  Widget _seatMap() {
    if (_loadingSeats) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_seatError != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(_seatError!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _loadSeats,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Text(
            'Select seats',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 30),
              Expanded(
                  child: _letterGroup(_seatLetters.take(widget.seatsPerSide))),
              const SizedBox(width: 20),
              Expanded(
                  child: _letterGroup(_seatLetters.skip(widget.seatsPerSide))),
            ],
          ),
          const SizedBox(height: 6),
          for (int row = 1; row <= _rowCount; row++) _seatRow(row),
        ],
      ),
    );
  }

  Widget _letterGroup(Iterable<String> letters) => Row(
        children: [
          for (final letter in letters)
            Expanded(
              child: Center(
                child: Text(
                  letter,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      );

  Widget _seatRow(int row) {
    final letters = _seatLetters;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_aircraft.exitRows.contains(row))
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              AppLocalizations.of(context).flightExitRow,
              style: const TextStyle(
                color: AppColors.accentOrange,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        SizedBox(
          height: 42,
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '$row',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    for (final letter in letters.take(widget.seatsPerSide))
                      Expanded(child: _seatButton('$row$letter')),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  children: [
                    for (final letter in letters.skip(widget.seatsPerSide))
                      Expanded(child: _seatButton('$row$letter')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _seatButton(String seat) {
    final occupied = _occupiedSeats.contains(seat);
    final selected = _selectedSeats.contains(seat);
    final premium = _isPremiumSeat(seat);
    final background = occupied
        ? AppColors.border
        : selected
            ? AppColors.primary
            : premium
                ? AppColors.primarySurface
                : AppColors.surfaceSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      child: Semantics(
        button: true,
        enabled: !occupied,
        label:
            'Seat $seat${occupied ? ', occupied' : selected ? ', selected' : ''}',
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: occupied ? null : () => _toggleSeat(seat),
            child: Center(
              child: Icon(
                occupied ? Icons.close_rounded : Icons.event_seat_rounded,
                size: 18,
                color: occupied
                    ? AppColors.textHint
                    : selected
                        ? Colors.white
                        : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _legend() => Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 8,
        children: [
          _legendItem(AppColors.surfaceSecondary, 'Available'),
          _legendItem(AppColors.primarySurface, 'Extra legroom'),
          _legendItem(AppColors.primary, 'Selected'),
          _legendItem(AppColors.border, 'Occupied'),
        ],
      );

  Widget _legendItem(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      );
}
