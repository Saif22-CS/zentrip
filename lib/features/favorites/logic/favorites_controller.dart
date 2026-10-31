import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../models/map_search_result.dart';

class FavoritePlace {
  final String id;
  final String title;
  final String subtitle;
  final String
      type; // 'destination' | 'hotel' | 'attraction' | 'restaurant' | 'cafe'
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  const FavoritePlace({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  factory FavoritePlace.fromMapSearchResult(MapSearchResult place) {
    final id = place.placeId ??
        '${place.category}:${place.title}:${place.address}'.toLowerCase();
    return FavoritePlace(
      id: id,
      title: place.title,
      subtitle: place.address,
      type: place.category,
      imageUrl: place.thumbnail,
      latitude: place.latitude,
      longitude: place.longitude,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'type': type,
        'image_url': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory FavoritePlace.fromJson(Map<String, dynamic> j) => FavoritePlace(
        id: j['id'] as String,
        title: j['title'] as String,
        subtitle: j['subtitle'] as String,
        type: j['type'] as String,
        imageUrl: j['image_url'] as String?,
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
      );
}

class FavoritesController extends ChangeNotifier {
  static final FavoritesController instance = FavoritesController._();
  FavoritesController._();

  final List<FavoritePlace> _favorites = [];

  /// مفتاح مربوط بإيميل الحساب المسجّل دخول حاليًا — عشان مفضلة حساب
  /// معيّن متختلطش مع حساب تاني على نفس الجهاز.
  String get _key =>
      'favorites_v2_${ApiService.instance.currentUser?.email ?? 'guest'}';

  List<FavoritePlace> get all => List.unmodifiable(_favorites);

  bool isFavorite(String id) => _favorites.any((f) => f.id == id);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _favorites
      ..clear()
      ..addAll(raw.map((e) =>
          FavoritePlace.fromJson(jsonDecode(e) as Map<String, dynamic>)));
    notifyListeners();
  }

  /// بتتنادى عند تسجيل الخروج — عشان القائمة متفضلش شايلة بيانات الحساب
  /// القديم في الذاكرة لحد ما تسجل دخول تاني.
  void clear() {
    _favorites.clear();
    notifyListeners();
  }

  Future<void> toggle(FavoritePlace place) async {
    if (isFavorite(place.id)) {
      _favorites.removeWhere((f) => f.id == place.id);
    } else {
      _favorites.insert(0, place);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    _favorites.removeWhere((f) => f.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, _favorites.map((f) => jsonEncode(f.toJson())).toList());
  }
}
