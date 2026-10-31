import 'package:flutter_test/flutter_test.dart';
import 'package:zentrip/core/utils/hotel_geo.dart';
import 'package:zentrip/models/hotel_model.dart';
import 'package:zentrip/models/mock_data_service.dart';

void main() {
  test('Haversine distance returns meters for nearby Tripoli coordinates', () {
    final distance = hotelDistanceMeters(
      fromLatitude: 32.8,
      fromLongitude: 13.2,
      toLatitude: 32.81,
      toLongitude: 13.2,
    );

    expect(distance, closeTo(1112, 2));
  });

  test('nearby filtering applies radius and orders by calculated distance', () {
    final hotels = [
      _hotel('farther', latitude: 32.81),
      _hotel('nearer', latitude: 32.801),
      _hotel('outside-radius', latitude: 33.5),
    ];

    final results = hotelsWithinRadius(
      hotels: hotels,
      latitude: 32.8,
      longitude: 13.2,
      radiusMeters: 5000,
    );

    expect(results.map((hotel) => hotel.id), ['nearer', 'farther']);
    expect(
        results.first.distanceMeters, lessThan(results.last.distanceMeters!));
  });

  test('mock hotel listings include coordinates and availability metadata', () {
    final hotels = MockDataService.hotels(city: 'Tripoli');

    expect(
      hotels.every((hotel) =>
          hotel.latitude != null &&
          hotel.longitude != null &&
          hotel.roomTypes.isNotEmpty &&
          hotel.availabilitySchedule.isNotEmpty &&
          hotel.isActive),
      isTrue,
    );
    expect(
      hotelsWithinRadius(
        hotels: hotels,
        latitude: MockDataService.hotelFallbackLatitude,
        longitude: MockDataService.hotelFallbackLongitude,
        radiusMeters: 50000,
      ),
      isNotEmpty,
    );
  });

  test('invalid and missing hotel coordinates are excluded safely', () {
    final results = hotelsWithinRadius(
      hotels: [
        _hotel('invalid', latitude: 91),
        _hotel('missing', latitude: null),
      ],
      latitude: 32.8,
      longitude: 13.2,
      radiusMeters: 50000,
    );

    expect(results, isEmpty);
  });
}

HotelModel _hotel(String id, {double? latitude = 32.8}) => HotelModel(
      id: id,
      name: id,
      city: 'Tripoli',
      country: 'Libya',
      locationName: '',
      googleRating: 0,
      googleReviewCount: 0,
      pricePerNight: 100,
      amenities: const [],
      description: '',
      stars: 0,
      latitude: latitude,
      longitude: 13.2,
    );
