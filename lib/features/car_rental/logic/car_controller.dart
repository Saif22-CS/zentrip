import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../models/car_model.dart';

class CarSearchParams {
  final String city;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String carType; // 'economy' | 'suv' | 'luxury'

  const CarSearchParams({
    required this.city,
    required this.pickupDate,
    required this.returnDate,
    this.carType = 'all',
  });

  int get days => returnDate.difference(pickupDate).inDays.clamp(1, 999);
}

class CarController extends ChangeNotifier {
  CarSearchParams? searchParams;
  List<CarModel> results = [];
  bool isLoading = false;
  CarModel? selectedCar;

  Future<void> search(CarSearchParams params) async {
    searchParams = params;
    isLoading = true;
    notifyListeners();
    results = await ApiService.instance.searchCars(
      city: params.city,
      pickupDate: params.pickupDate,
      returnDate: params.returnDate,
      carType: params.carType,
    );
    results.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
    isLoading = false;
    notifyListeners();
  }

  Future<void> searchNearby(
    CarSearchParams params, {
    required double latitude,
    required double longitude,
    double radiusMeters = 50000,
  }) async {
    searchParams = params;
    isLoading = true;
    notifyListeners();
    results = await ApiService.instance.nearbyCars(
      lat: latitude,
      lng: longitude,
      radiusMeters: radiusMeters,
      carType: params.carType,
    );
    isLoading = false;
    notifyListeners();
  }

  void selectCar(CarModel car) {
    selectedCar = car;
    notifyListeners();
  }
}
