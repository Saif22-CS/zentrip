import 'package:flutter/material.dart';

import '../../../../models/flight_model.dart';
import 'flight_seat_selection.dart';

class SeatSelection16LineScreen extends StatelessWidget {
  final FlightModel flight;
  final int passengerCount;
  final String seatClass;
  final DateTime? returnDate;
  final int rowCount;

  const SeatSelection16LineScreen({
    super.key,
    required this.flight,
    required this.passengerCount,
    required this.seatClass,
    this.returnDate,
    this.rowCount = 16,
  });

  @override
  Widget build(BuildContext context) => FlightSeatSelectionScreen(
        flight: flight,
        passengerCount: passengerCount,
        seatClass: seatClass,
        returnDate: returnDate,
        seatsPerSide: 2,
        rowCount: rowCount,
      );
}
