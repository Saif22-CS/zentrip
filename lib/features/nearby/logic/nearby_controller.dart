import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/current_location_service.dart';
import '../../../core/services/api_service.dart';
import '../../../models/map_search_result.dart';

enum NearbyFilter { all, landmark, restaurant, cafe, hotel, attraction }

/// Location error reasons — the UI maps these to localized messages.
typedef NearbyLocationError = CurrentLocationError;

class NearbyController extends ChangeNotifier {
  final CurrentLocationService _locationService =
      const CurrentLocationService();
  List<MapSearchResult> _all = [];
  List<MapSearchResult> filtered = [];
  NearbyFilter selectedFilter = NearbyFilter.all;
  String searchQuery = '';
  Position? currentPosition;
  bool isLoadingLocation = false;
  bool isLoadingPlaces = false;
  NearbyLocationError? locationError;
  String? placesLoadError;

  List<MapSearchResult> get allPlaces => List.unmodifiable(_all);

  Future<void> init() async {
    await _getLocation();
    await _loadPlaces();
  }

  Future<void> _getLocation() async {
    isLoadingLocation = true;
    locationError = null;
    currentPosition = null;
    notifyListeners();
    try {
      currentPosition = await _locationService.getPosition();
    } on CurrentLocationException catch (error) {
      locationError = error.reason;
    } finally {
      isLoadingLocation = false;
      notifyListeners();
    }
  }

  Future<void> _loadPlaces() async {
    if (currentPosition == null) {
      _all = [];
      _applyFilter();
      notifyListeners();
      return;
    }

    isLoadingPlaces = true;
    placesLoadError = null;
    notifyListeners();
    final lat = currentPosition!.latitude;
    final lng = currentPosition!.longitude;
    try {
      final responses = await Future.wait([
        ApiService.instance.searchGoogleMaps(
          query: 'restaurants',
          latitude: lat,
          longitude: lng,
          category: 'restaurant',
        ),
        ApiService.instance.searchGoogleMaps(
          query: 'cafes',
          latitude: lat,
          longitude: lng,
          category: 'cafe',
        ),
        ApiService.instance.searchGoogleMaps(
          query: 'tourist attractions',
          latitude: lat,
          longitude: lng,
          category: 'attraction',
        ),
        ApiService.instance.searchGoogleMaps(
          query: 'landmarks',
          latitude: lat,
          longitude: lng,
          category: 'landmark',
        ),
        ApiService.instance.searchGoogleMaps(
          query: 'hotels',
          latitude: lat,
          longitude: lng,
          category: 'hotel',
        ),
      ]);

      final successfulResponses =
          responses.where((response) => response.isSuccess);
      final failedResponses = responses.where((response) => response.isFailure);
      _all = successfulResponses
          .expand<MapSearchResult>(
              (response) => response.data ?? const <MapSearchResult>[])
          .where((place) => place.latitude != null && place.longitude != null)
          .toList();

      if (failedResponses.isNotEmpty) {
        placesLoadError = failedResponses
            .map((response) => response.errorMessage)
            .firstWhere((message) => message != null && message.isNotEmpty,
                orElse: () => 'Nearby categories could not be loaded.');
      }
    } catch (error) {
      _all = [];
      placesLoadError = error.toString();
    } finally {
      _applyFilter();
      isLoadingPlaces = false;
      notifyListeners();
    }
  }

  Future<void> retryPlaces() async {
    await _getLocation();
    await _loadPlaces();
  }

  void setFilter(NearbyFilter filter) {
    selectedFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void search(String query) {
    searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    List<MapSearchResult> result = List.of(_all);
    if (selectedFilter != NearbyFilter.all) {
      final catMap = {
        NearbyFilter.landmark: 'landmark',
        NearbyFilter.restaurant: 'restaurant',
        NearbyFilter.cafe: 'cafe',
        NearbyFilter.hotel: 'hotel',
        NearbyFilter.attraction: 'attraction',
      };
      result =
          result.where((p) => p.category == catMap[selectedFilter]).toList();
    }
    if (searchQuery.isNotEmpty) {
      result = result
          .where((p) =>
              p.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              p.address.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    filtered = result;
  }

  List<MapSearchResult> get recommendations {
    final lat = currentPosition?.latitude;
    final lng = currentPosition?.longitude;

    if (lat == null || lng == null) {
      return filtered.take(10).toList();
    }

    final places = List<MapSearchResult>.from(filtered);

    places.sort((a, b) {
      final aDistance = Geolocator.distanceBetween(
        lat,
        lng,
        a.latitude!,
        a.longitude!,
      );

      final bDistance = Geolocator.distanceBetween(
        lat,
        lng,
        b.latitude!,
        b.longitude!,
      );

      final aScore = (a.rating ?? 0) - (aDistance / 1000 * 0.25);
      final bScore = (b.rating ?? 0) - (bDistance / 1000 * 0.25);

      return bScore.compareTo(aScore);
    });

    return places.take(10).toList();
  }
}
