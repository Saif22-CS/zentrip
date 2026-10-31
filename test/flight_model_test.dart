import 'package:flutter_test/flutter_test.dart';
import 'package:zentrip/models/flight_model.dart';

void main() {
  group('partner flight search mapping', () {
    final departureDate = DateTime(2026, 11, 10);
    final flightJson = <String, dynamic>{
      'id': 'partner-25',
      'partner_listing_id': 25,
      'airline': 'Libyan Wings',
      'flight_number': 'YL-25',
      'origin_city': 'Misrata',
      'origin_code': '',
      'destination_city': 'Tripoli',
      'destination_code': 'MJI',
      'departure_time': '2026-11-10T08:00:00',
      'arrival_time': '2026-11-10T10:00:00',
      'duration_minutes': 120,
      'seats_available': 80,
      'economy_price': 175,
      'status': 'published',
      'is_active': true,
      'airline_logo_url': null,
    };

    test('finds an active Misrata-to-Tripoli listing on its departure date',
        () {
      final flight = FlightModel.fromJson(flightJson);

      expect(
        flight.matchesSearch(
          originCode: 'MRA',
          destinationCode: 'MJI',
          originCity: 'Misrata',
          destinationCity: 'Tripoli',
          departureDate: departureDate,
          passengers: 2,
        ),
        isTrue,
      );
      expect(flight.airline, 'Libyan Wings');
      expect(flight.originCode, 'MRA');
      expect(flight.partnerListingId, 25);
      expect(flight.airlineLogoUrl, isNull);
    });

    test('excludes paused listings and route/date/seat mismatches', () {
      final flight = FlightModel.fromJson(flightJson);

      expect(
        FlightModel.fromJson({
          ...flightJson,
          'status': 'paused',
          'is_active': false,
        }).matchesSearch(
          originCode: 'MRA',
          destinationCode: 'MJI',
          originCity: 'Misrata',
          destinationCity: 'Tripoli',
          departureDate: departureDate,
          passengers: 1,
        ),
        isFalse,
      );
      expect(
        flight.matchesSearch(
          originCode: 'MRA',
          destinationCode: 'CAI',
          originCity: 'Misrata',
          destinationCity: 'Cairo',
          departureDate: departureDate,
          passengers: 1,
        ),
        isFalse,
      );
      expect(
        flight.matchesSearch(
          originCode: 'MRA',
          destinationCode: 'MJI',
          originCity: 'Misrata',
          destinationCity: 'Tripoli',
          departureDate: DateTime(2026, 11, 11),
          passengers: 1,
        ),
        isFalse,
      );
      expect(
        flight.matchesSearch(
          originCode: 'MRA',
          destinationCode: 'MJI',
          originCity: 'Misrata',
          destinationCity: 'Tripoli',
          departureDate: departureDate,
          passengers: 81,
        ),
        isFalse,
      );
    });

    test('maps configured seat layout and row count', () {
      final flight = FlightModel.fromJson({
        ...flightJson,
        'seat_layout': '2-2',
        'seat_rows': '16',
      });

      expect(flight.usesTwoByTwoSeatLayout, isTrue);
      expect(flight.seatRows, 16);

      final defaultLayout = FlightModel.fromJson(flightJson);
      expect(defaultLayout.usesTwoByTwoSeatLayout, isFalse);
      expect(defaultLayout.seatRows, 30);

      final firstClassFlight = FlightModel.fromJson({
        ...flightJson,
        'first_price': '420.50',
      });
      expect(firstClassFlight.firstPrice, 420.5);
    });
  });
}
