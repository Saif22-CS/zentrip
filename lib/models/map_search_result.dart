class MapSearchResult {
  final String title;
  final String address;
  final double? rating;
  final int? reviews;
  final String? phone;
  final String? website;
  final double? latitude;
  final double? longitude;
  final String? type;
  final String? thumbnail;
  final String category;
  final String? placeId;
  const MapSearchResult({
    required this.title,
    required this.address,
    required this.category,
    this.placeId,
    this.rating,
    this.reviews,
    this.phone,
    this.website,
    this.latitude,
    this.longitude,
    this.type,
    this.thumbnail,
  });

  factory MapSearchResult.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int? parseInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return MapSearchResult(
      title: json['title']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      category: json['category']?.toString() ?? 'attraction',
      placeId: json['place_id']?.toString(),
      rating: parseDouble(json['rating']),
      reviews: parseInt(json['reviews']),
      phone: json['phone']?.toString(),
      website: json['website']?.toString(),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      type: json['type']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
    );
  }
}
