import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/current_location_service.dart';
import '../../../../features/favorites/logic/favorites_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/map_search_result.dart';

/// Unified place map with exclusive category filters and tappable markers.
class PlacesMapScreen extends StatefulWidget {
  final MapSearchResult? selectedPlace;
  final List<MapSearchResult> places;

  const PlacesMapScreen(
      {super.key, this.selectedPlace, this.places = const []});

  @override
  State<PlacesMapScreen> createState() => _PlacesMapScreenState();
}

enum _MapLayer { favorites, restaurants, cafes, hotels, attractions }

class _MapPlace {
  final String id;
  final String title;
  final String subtitle;
  final LatLng point;
  final _MapLayer layer;
  final String? priceOrRating;
  final MapSearchResult? result;
  final String? favoriteId;
  const _MapPlace(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.point,
      required this.layer,
      this.priceOrRating,
      this.result,
      this.favoriteId});
}

class _PlacesMapScreenState extends State<PlacesMapScreen> {
  final _locationService = const CurrentLocationService();
  _MapLayer? _activeLayer;
  LatLng? _myLocation;
  CurrentLocationError? _locationError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final position = await _locationService.getPosition();
      _myLocation = LatLng(position.latitude, position.longitude);
      _locationError = null;
    } on CurrentLocationException catch (error) {
      _locationError = error.reason;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _locationErrorMessage(AppLocalizations l10n) =>
      switch (_locationError!) {
        CurrentLocationError.serviceDisabled =>
          l10n.nearbyLocationServiceDisabled,
        CurrentLocationError.permissionDenied =>
          l10n.nearbyLocationPermissionDenied,
        CurrentLocationError.permissionDeniedForever =>
          l10n.nearbyLocationPermissionDeniedForever,
        CurrentLocationError.unableToDetermine =>
          l10n.nearbyLocationUnableToDetermine,
      };

  _MapLayer? _layerForCategory(String category) => switch (category) {
        'restaurant' => _MapLayer.restaurants,
        'cafe' => _MapLayer.cafes,
        'hotel' => _MapLayer.hotels,
        'landmark' || 'attraction' => _MapLayer.attractions,
        _ => null,
      };

  _MapPlace _mapPlaceFromResult(MapSearchResult result) {
    final favorite = FavoritePlace.fromMapSearchResult(result);
    final rating = result.rating == null ? null : '★ ${result.rating}';
    return _MapPlace(
      id: favorite.id,
      title: result.title,
      subtitle: result.address,
      point: LatLng(result.latitude!, result.longitude!),
      layer: _layerForCategory(result.category) ?? _MapLayer.attractions,
      priceOrRating: rating,
      result: result,
    );
  }

  List<_MapPlace> get _places {
    final list = <_MapPlace>[];
    final visibleResultIds = <String>{};
    for (final result in widget.places) {
      if (result.latitude == null || result.longitude == null) continue;
      final layer = _layerForCategory(result.category);
      if (layer == null || (_activeLayer != null && _activeLayer != layer)) {
        continue;
      }
      final mapPlace = _mapPlaceFromResult(result);
      list.add(mapPlace);
      visibleResultIds.add(mapPlace.id);
    }
    for (final f in FavoritesController.instance.all) {
      if (f.latitude == null || f.longitude == null) continue;
      if ((_activeLayer != null && _activeLayer != _MapLayer.favorites) ||
          visibleResultIds.contains(f.id)) {
        continue;
      }
      list.add(_MapPlace(
        id: 'fav-${f.id}',
        title: f.title,
        subtitle: f.subtitle,
        point: LatLng(f.latitude!, f.longitude!),
        layer: _MapLayer.favorites,
        favoriteId: f.id,
      ));
    }
    return list;
  }

  (IconData, Color) _layerStyle(_MapLayer l) => switch (l) {
        _MapLayer.favorites => (Icons.bookmark_rounded, AppColors.accentOrange),
        _MapLayer.restaurants => (Icons.restaurant_rounded, AppColors.primary),
        _MapLayer.cafes => (Icons.local_cafe_rounded, const Color(0xFF8D6E63)),
        _MapLayer.hotels => (Icons.hotel_rounded, AppColors.accentPurple),
        _MapLayer.attractions => (Icons.place_rounded, AppColors.accentRed),
      };

  String _layerLabel(AppLocalizations l10n, _MapLayer l) => switch (l) {
        _MapLayer.favorites => l10n.favorites,
        _MapLayer.restaurants => l10n.nearbyRestaurants,
        _MapLayer.cafes => l10n.nearbyCafes,
        _MapLayer.hotels => l10n.nearbyHotels,
        _MapLayer.attractions => l10n.nearbyAttractions,
      };

  void _showMapResult(MapSearchResult result) {
    if (result.latitude == null || result.longitude == null) return;
    _showPlaceSheet(_mapPlaceFromResult(result));
  }

  void _showPlaceSheet(_MapPlace place) {
    final l10n = AppLocalizations.of(context);
    final (icon, color) = _layerStyle(place.layer);
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(place.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 3),
                        Text(place.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (place.priceOrRating != null)
                    Text(place.priceOrRating!,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: color,
                            fontSize: 14)),
                ],
              ),
              if (place.result?.phone != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(place.result!.phone!,
                      style: const TextStyle(color: AppColors.textSecondary)),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: ListenableBuilder(
                  listenable: FavoritesController.instance,
                  builder: (_, __) {
                    final favoriteId = place.result == null
                        ? place.favoriteId
                        : FavoritePlace.fromMapSearchResult(place.result!).id;
                    final isSaved = favoriteId != null &&
                        FavoritesController.instance.isFavorite(favoriteId);
                    return FilledButton.tonalIcon(
                      onPressed: favoriteId == null
                          ? null
                          : () async {
                              if (place.result != null) {
                                await FavoritesController.instance.toggle(
                                  FavoritePlace.fromMapSearchResult(
                                      place.result!),
                                );
                              } else {
                                await FavoritesController.instance
                                    .remove(favoriteId);
                              }
                              if (mounted) setState(() {});
                            },
                      icon: Icon(isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_add_outlined),
                      label: Text(isSaved ? l10n.savedPlace : l10n.savePlace),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedPlace = widget.selectedPlace;
    final places = _places;
    final selectedCenter = selectedPlace != null &&
            selectedPlace.latitude != null &&
            selectedPlace.longitude != null
        ? LatLng(selectedPlace.latitude!, selectedPlace.longitude!)
        : null;
    final center = selectedCenter ??
        _myLocation ??
        (places.isNotEmpty ? places.first.point : null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.placesMapTitle)),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : center == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_off_rounded,
                            color: AppColors.accentRed, size: 44),
                        const SizedBox(height: 12),
                        Text(
                          _locationErrorMessage(l10n),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _isLoading = true);
                            _load();
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: selectedCenter == null ? 12 : 16,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.zentrip.app',
                        ),
                        MarkerLayer(markers: [
                          if (selectedPlace != null &&
                              selectedPlace.latitude != null &&
                              selectedPlace.longitude != null)
                            Marker(
                              point: LatLng(selectedPlace.latitude!,
                                  selectedPlace.longitude!),
                              width: 52,
                              height: 52,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _showMapResult(selectedPlace),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 48,
                                ),
                              ),
                            ),
                          if (_myLocation != null)
                            Marker(
                              point: _myLocation!,
                              width: 22,
                              height: 22,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 6)
                                  ],
                                ),
                              ),
                            ),
                          for (final p in places)
                            Marker(
                              point: p.point,
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _showPlaceSheet(p),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _layerStyle(p.layer).$2,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2))
                                    ],
                                  ),
                                  child: Icon(_layerStyle(p.layer).$1,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                        ]),
                      ],
                    ),
                    // ── طبقات قابلة للتفعيل ─────────────────────────────────
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _MapLayer.values.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final layer =
                                i == 0 ? null : _MapLayer.values[i - 1];
                            final isActive = _activeLayer == layer;
                            final (icon, color) = layer == null
                                ? (Icons.layers_rounded, AppColors.primary)
                                : _layerStyle(layer);
                            final label = layer == null
                                ? l10n.nearbyAll
                                : _layerLabel(l10n, layer);
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () =>
                                    setState(() => _activeLayer = layer),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? color
                                        : (isDark
                                            ? AppColors.darkSurface
                                            : Colors.white),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2))
                                    ],
                                  ),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(icon,
                                            size: 15,
                                            color: isActive
                                                ? Colors.white
                                                : color),
                                        const SizedBox(width: 6),
                                        Text(label,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: isActive
                                                  ? Colors.white
                                                  : (isDark
                                                      ? AppColors
                                                          .darkTextPrimary
                                                      : AppColors.textPrimary),
                                            )),
                                      ]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
