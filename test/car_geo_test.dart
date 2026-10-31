import 'package:flutter_test/flutter_test.dart';
import 'package:zentrip/core/utils/car_geo.dart';
import 'package:zentrip/models/car_model.dart';

CarModel _car(String id, double? latitude, double? longitude) => CarModel(
      id: id,
      brand: 'Test',
      model: 'Car',
      category: 'economy',
      year: 2024,
      pricePerDay: 20,
      seats: 4,
      transmission: 'automatic',
      fuelType: 'gasoline',
      features: const [],
      rating: 4,
      pickupLocation: 'Misrata',
      latitude: latitude,
      longitude: longitude,
    );

void main() {
  test('computes zero distance for identical valid coordinates', () {
    expect(
      carDistanceMeters(
        fromLatitude: 32.3754,
        fromLongitude: 15.0925,
        toLatitude: 32.3754,
        toLongitude: 15.0925,
      ),
      0,
    );
  });

  test('nearby cars filters by radius and sorts by distance', () {
    final cars = carsWithinRadius(
      cars: [
        _car('far', 33, 16),
        _car('near', 32.376, 15.0925),
        _car('missing', null, null),
      ],
      latitude: 32.3754,
      longitude: 15.0925,
      radiusMeters: 1000,
    );

    expect(cars.map((car) => car.id), ['near']);
    expect(cars.first.distanceMeters, lessThan(1000));
  });
}
