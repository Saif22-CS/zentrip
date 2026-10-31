import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../models/travel_package_model.dart';
import '../../../models/trip_model.dart';

class HomeController extends ChangeNotifier {
  List<TravelPackage> packages = [];
  TripModel? upcomingTrip;
  bool isLoadingPackages = false;
  bool isLoadingTrip = false;
  String? packagesLoadError;

  Future<void> loadAll() async {
    await Future.wait([loadPackages(), loadUpcomingTrip()]);
  }

  Future<void> loadPackages() async {
    isLoadingPackages = true;
    packagesLoadError = null;
    notifyListeners();
    // العروضات دلوقتي بتيجي من ApiService.getOffers() — نفس المصدر اللي
    // هيرجّع بيانات حقيقية من لوحة تحكم الأدمن أول ما useMockMode = false،
    // من غير أي تعديل هنا خالص.
    final result = await ApiService.instance.getOffers();
    packages = result.data ?? [];
    packagesLoadError = result.isFailure ? result.errorMessage : null;
    isLoadingPackages = false;
    notifyListeners();
  }

  Future<void> loadUpcomingTrip() async {
    isLoadingTrip = true;
    notifyListeners();
    // الرحلة القادمة بتعرض بس الحجوزات الحقيقية اللي المستخدم عملها فعليًا —
    // مفيش بيانات تجريبية هنا خالص، عشان لو مفيش حجز، القسم يفضل فاضي.
    final realResult = await ApiService.instance.getMyFlightTrips();
    final trips = realResult.data ?? [];
    upcomingTrip = trips.where((t) => t.status == 'upcoming').isNotEmpty
        ? trips.firstWhere((t) => t.status == 'upcoming')
        : null;
    isLoadingTrip = false;
    notifyListeners();
  }
}
