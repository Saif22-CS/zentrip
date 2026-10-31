import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../models/car_model.dart';

double? carDistanceMeters({
  required double? fromLatitude,
  required double? fromLongitude,
  required double? toLatitude,
  required double? toLongitude,
}) {
  if (!_validCoordinates(fromLatitude, fromLongitude) ||
      !_validCoordinates(toLatitude, toLongitude)) {
    return null;
  }
  const earthRadiusMeters = 6371000.0;
  double radians(double degrees) => degrees * math.pi / 180;
  final latitudeDelta = radians(toLatitude! - fromLatitude!);
  final longitudeDelta = radians(toLongitude! - fromLongitude!);
  final latitudeSine = math.sin(latitudeDelta / 2);
  final longitudeSine = math.sin(longitudeDelta / 2);
  final a = latitudeSine * latitudeSine +
      math.cos(radians(fromLatitude)) *
          math.cos(radians(toLatitude)) *
          longitudeSine *
          longitudeSine;
  final boundedA = a.clamp(0.0, 1.0);
  return earthRadiusMeters *
      2 *
      math.atan2(math.sqrt(boundedA), math.sqrt(1 - boundedA));
}

List<CarModel> carsWithinRadius({
  required Iterable<CarModel> cars,
  required double latitude,
  required double longitude,
  required double radiusMeters,
}) {
  if (!_validCoordinates(latitude, longitude) ||
      !radiusMeters.isFinite ||
      radiusMeters <= 0) {
    throw ArgumentError('A valid location and positive radius are required.');
  }
  final nearby = <CarModel>[];
  for (final car in cars) {
    final distance = carDistanceMeters(
      fromLatitude: latitude,
      fromLongitude: longitude,
      toLatitude: car.latitude,
      toLongitude: car.longitude,
    );
    if (distance == null) {
      debugPrint(
        'Car ${car.id} has no valid pickup coordinates and is excluded from nearby search.',
      );
    } else if (distance <= radiusMeters) {
      nearby.add(car.withDistanceMeters(distance));
    }
  }
  nearby.sort(
    (first, second) =>
        first.distanceMeters!.compareTo(second.distanceMeters!),
  );
  return nearby;
}

bool _validCoordinates(double? latitude, double? longitude) =>
    latitude != null &&
    longitude != null &&
    latitude.isFinite &&
    longitude.isFinite &&
    latitude >= -90 &&
    latitude <= 90 &&
    longitude >= -180 &&
    longitude <= 180 &&
    !(latitude == 0 && longitude == 0);
