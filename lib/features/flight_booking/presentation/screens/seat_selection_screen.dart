import 'package:flutter/material.dart';

import '../../../../models/flight_model.dart';
import 'flight_seat_selection.dart';

class SeatSelectionScreen extends StatelessWidget {
  final FlightModel flight;
  final int passengerCount;
  final String seatClass;
  final DateTime? returnDate;
  final int rowCount;

  const SeatSelectionScreen({
    super.key,
    required this.flight,
    required this.passengerCount,
    required this.seatClass,
    this.returnDate,
    this.rowCount = 30,
  });

  @override
  Widget build(BuildContext context) => FlightSeatSelectionScreen(
        flight: flight,
        passengerCount: passengerCount,
        seatClass: seatClass,
        returnDate: returnDate,
        seatsPerSide: 3,
        rowCount: rowCount,
      );
}
