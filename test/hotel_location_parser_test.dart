import 'package:flutter_test/flutter_test.dart';
import 'package:zentrip/features/admin/logic/hotel_location_parser.dart';

void main() {
  test('accepts a Google Maps short link', () {
    const link = 'https://maps.app.goo.gl/wssdTSk54ERQ3xfn6';

    expect(
      parseHotelLocationInput(link),
      {'location_input': link},
    );
  });

  test('accepts a Plus Code with its locality', () {
    const plusCode = '93FP+88V, Misrata';

    expect(
      parseHotelLocationInput(plusCode),
      {'location_input': plusCode},
    );
  });

  test('accepts a Maps link and Plus Code pasted on separate lines', () {
    const value = 'https://maps.app.goo.gl/wssdTSk54ERQ3xfn6\n'
        '93FP+88V, Misrata';

    expect(
      parseHotelLocationInput(value),
      {'location_input': value},
    );
  });

  test('keeps numeric coordinates available for nearby search', () {
    expect(
      parseHotelLocationInput('32.8872, 13.1913'),
      {
        'location_input': '32.8872, 13.1913',
        'latitude': 32.8872,
        'longitude': 13.1913,
      },
    );
  });

  test('rejects a URL that is not a Google Maps URL', () {
    expect(
      () => parseHotelLocationInput('https://example.com/location'),
      throwsFormatException,
    );
  });
}
