import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'admin_dashboard_model.dart';

class PartnerDashboardData {
  final String companyName;
  final String serviceType;
  final int listingCount;
  final int activeListingCount;
  final int reservationCount;
  final int customerCount;
  final double bookedValue;
  final List<PartnerReservation> recentReservations;

  const PartnerDashboardData({
    required this.companyName,
    required this.serviceType,
    required this.listingCount,
    required this.activeListingCount,
    required this.reservationCount,
    required this.customerCount,
    required this.bookedValue,
    required this.recentReservations,
  });

  factory PartnerDashboardData.fromJson(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>;
    final summary = json['summary'] as Map<String, dynamic>;
    final reservations = json['recent_reservations'] as List? ?? const [];
    return PartnerDashboardData(
      companyName: '${company['name'] ?? ''}',
      serviceType: '${company['service_type'] ?? ''}',
      listingCount: _asInt(summary['listing_count']),
      activeListingCount: _asInt(summary['active_listing_count']),
      reservationCount: _asInt(summary['reservation_count']),
      customerCount: _asInt(summary['customer_count']),
      bookedValue: _asDouble(summary['booked_value']),
      recentReservations: reservations
          .map((item) =>
              PartnerReservation.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PartnerReservation extends AdminReservation {
  final String customerEmail;
  final String customerPhone;
  final int? listingId;

  const PartnerReservation({
    required super.id,
    required super.type,
    required super.title,
    required super.customerName,
    required super.reservationDate,
    required super.amount,
    required super.status,
    required this.customerEmail,
    required this.customerPhone,
    required this.listingId,
  });

  factory PartnerReservation.fromJson(Map<String, dynamic> json) =>
      PartnerReservation(
        id: '${json['id'] ?? ''}',
        type: '${json['type'] ?? ''}',
        title: '${json['title'] ?? ''}',
        customerName: '${json['customer_name'] ?? ''}',
        reservationDate: DateTime.tryParse('${json['reservation_date'] ?? ''}'),
        amount: _asDouble(json['amount']),
        status: '${json['status'] ?? ''}',
        customerEmail: '${json['customer_email'] ?? ''}',
        customerPhone: '${json['customer_phone'] ?? ''}',
        listingId: json['partner_listing_id'] == null
            ? null
            : _asInt(json['partner_listing_id']),
      );
}

class PartnerListing {
  final int? id;
  final String type;
  final String title;
  final String city;
  final String country;
  final String description;
  final String imageUrl;
  final double price;
  final bool active;
  final Map<String, dynamic> attributes;

  const PartnerListing({
    this.id,
    required this.type,
    required this.title,
    required this.city,
    required this.country,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.active,
    this.attributes = const {},
  });

  String? get listingCode => attributes['listing_code']?.toString();
  String get locationName => _firstNonEmpty([
        attributes['location_name'],
        attributes['address'],
        attributes['neighborhood'],
        attributes['district'],
        attributes['landmark'],
        city,
      ]);
  String? get googleMapsUrl => _nullableString(attributes['google_maps_url']);
  String? get placeId => _nullableString(
        attributes['place_id'] ?? attributes['google_place_id'],
      );
  List<String> get amenities => _stringList(attributes['amenities']);
  List<String> get galleryImages => _stringList(attributes['gallery_images']);
  double get googleRating => _asDouble(attributes['google_rating']);
  int get googleReviewCount => _asInt(attributes['google_review_count']);
  int get availableRooms => _asInt(attributes['available_rooms']);
  double get taxAndFeesPercentage =>
      _asDouble(attributes['tax_and_fees_percentage'], fallback: 12);

  factory PartnerListing.fromJson(Map<String, dynamic> json) {
    final rawAttributes = json['attributes'];
    final Map<String, dynamic> attributes = <String, dynamic>{};
    if (rawAttributes is Map<String, dynamic>) {
      attributes.addAll(rawAttributes);
    } else if (rawAttributes is Map) {
      attributes.addAll(Map<String, dynamic>.from(rawAttributes));
    } else if (rawAttributes is String && rawAttributes.isNotEmpty) {
      final decoded = jsonDecode(rawAttributes);
      if (decoded is Map) {
        attributes.addAll(Map<String, dynamic>.from(decoded));
      }
    }
    for (final key in const [
      'address',
      'location_name',
      'district',
      'neighborhood',
      'landmark',
      'amenities',
      'google_maps_url',
      'place_id',
      'google_rating',
      'google_review_count',
      'tax_and_fees_percentage',
      'available_rooms',
      'stars',
      'room_types',
      'availability_schedule',
      'gallery_images',
      'latitude',
      'longitude',
      'location_input',
      'google_place_id',
    ]) {
      if (json.containsKey(key) &&
          (!attributes.containsKey(key) ||
              key == 'google_rating' ||
              key == 'google_review_count')) {
        attributes[key] = json[key];
      }
    }
    if (kDebugMode && json['type'] == 'hotel') {
      debugPrint(
        '[PartnerListing] Google rating parse for listing ${json['id']}: '
        'rating=${attributes['google_rating']} '
        '(${attributes['google_rating'].runtimeType}) -> '
        '${_asDouble(attributes['google_rating'])}; '
        'reviews=${attributes['google_review_count']} '
        '(${attributes['google_review_count'].runtimeType}) -> '
        '${_asInt(attributes['google_review_count'])}',
      );
    }
    return PartnerListing(
      id: json['id'] == null ? null : _asInt(json['id']),
      type: '${json['type'] ?? ''}',
      title: '${json['title'] ?? ''}',
      city: '${json['city'] ?? ''}',
      country: '${json['country'] ?? ''}',
      description: '${json['description'] ?? ''}',
      imageUrl: '${json['image_url'] ?? ''}',
      price: _asDouble(json['price']),
      active: json['active'] == true ||
          json['active'] == 1 ||
          json['active'] == '1' ||
          json['active'] == 'true' ||
          const {'active', 'published'}
              .contains('${json['status'] ?? ''}'.toLowerCase()),
      attributes: attributes,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'city': city,
        'country': country,
        'description': description,
        'image_url': type == 'flight' ? null : imageUrl,
        'price': price,
        'active': active,
        if (type == 'hotel') 'available_rooms': availableRooms,
        'attributes': attributes,
      };

  PartnerListing copyWith({
    String? type,
    String? title,
    String? city,
    String? country,
    String? description,
    String? imageUrl,
    double? price,
    bool? active,
    Map<String, dynamic>? attributes,
  }) =>
      PartnerListing(
        id: id,
        type: type ?? this.type,
        title: title ?? this.title,
        city: city ?? this.city,
        country: country ?? this.country,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        price: price ?? this.price,
        active: active ?? this.active,
        attributes: attributes ?? this.attributes,
      );
}

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

String _firstNonEmpty(List<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return '';
}

List<String> _stringList(dynamic value) => value is List
    ? value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList()
    : const [];

String? _nullableString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
