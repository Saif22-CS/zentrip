class CarModel {
  final String id;
  final String brand;
  final String model;
  final String category; // 'economy' | 'suv' | 'luxury' | 'electric' | 'van'
  final int year;
  final double pricePerDay;
  final int seats;
  final String transmission; // 'automatic' | 'manual'
  final String fuelType; // 'gasoline' | 'diesel' | 'hybrid' | 'electric'
  final String? imageUrl;
  final List<String> features;
  final double rating;
  final String pickupLocation;
  final int luggageCapacity;
  final int availableVehicles;
  final double insuranceFee;
  final double serviceFee;
  final bool hasAC;
  final bool hasGPS;
  final double? latitude;
  final double? longitude;
  final double? distanceMeters;
  final int? partnerListingId;
  final String? partnerName;

  const CarModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.category,
    required this.year,
    required this.pricePerDay,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    this.imageUrl,
    required this.features,
    required this.rating,
    required this.pickupLocation,
    this.luggageCapacity = 2,
    this.availableVehicles = 1,
    this.insuranceFee = 4,
    this.serviceFee = 10,
    this.hasAC = true,
    this.hasGPS = false,
    this.latitude,
    this.longitude,
    this.distanceMeters,
    this.partnerListingId,
    this.partnerName,
  });

  static String _stringFromDynamic(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return value.toString();
  }

  static int _intFromDynamic(dynamic value, [int fallback = 0]) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
    }
    return fallback;
  }

  static double _doubleFromDynamic(dynamic value, [double fallback = 0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static bool _boolFromDynamic(dynamic value, [bool fallback = false]) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is String) {
      final text = value.trim().toLowerCase();
      if (text == '1' || text == 'true' || text == 'yes') return true;
      if (text == '0' || text == 'false' || text == 'no') return false;
    }
    if (value is num) return value != 0;
    return fallback;
  }

  String get fullName => '$brand $model $year'.trim();
  String get modelName => fullName;
  String get name => fullName;
  String get type => category; // alias used by controller filter
  int get bags => luggageCapacity > 0 ? luggageCapacity : switch (category) {
        'van' => 6,
        'suv' => 4,
        'luxury' || 'electric' => 3,
        _ => 2,
      };
  CarRentalPriceBreakdown pricingForDays(int days) =>
      CarRentalPriceBreakdown(
        pricePerDay: pricePerDay,
        numberOfDays: days.clamp(1, 999).toInt(),
        insuranceFee: insuranceFee,
        serviceFee: serviceFee,
      );

  double totalPriceForDays(int days) => pricingForDays(days).totalPrice;

  CarModel withDistanceMeters(double distance) => CarModel(
        id: id,
        brand: brand,
        model: model,
        category: category,
        year: year,
        pricePerDay: pricePerDay,
        seats: seats,
        transmission: transmission,
        fuelType: fuelType,
        imageUrl: imageUrl,
        features: features,
        rating: rating,
        pickupLocation: pickupLocation,
        luggageCapacity: luggageCapacity,
        availableVehicles: availableVehicles,
        insuranceFee: insuranceFee,
        serviceFee: serviceFee,
        hasAC: hasAC,
        hasGPS: hasGPS,
        latitude: latitude,
        longitude: longitude,
        distanceMeters: distance,
        partnerListingId: partnerListingId,
        partnerName: partnerName,
      );

  factory CarModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] is Map
        ? Map<String, dynamic>.from(json['attributes'] as Map)
        : <String, dynamic>{};
    Object? value(String key) => json[key] ?? attributes[key];
    final title = _stringFromDynamic(json['title'] ?? json['name']);
    final brand = _stringFromDynamic(value('brand'));
    final model = _stringFromDynamic(value('model'));
    final fullTitle = model.isEmpty && title.isNotEmpty
        ? title
        : model;
    final resolvedBrand = brand.isEmpty && title.isNotEmpty
        ? title.split(' ').first
        : brand;
    final resolvedModel = resolvedBrand.isNotEmpty && fullTitle.startsWith('$resolvedBrand ')
        ? fullTitle.substring(resolvedBrand.length + 1)
        : fullTitle;
    return CarModel(
      id: _stringFromDynamic(json['id']),
      brand: resolvedBrand,
      model: resolvedModel,
      category: _stringFromDynamic(value('category'), 'economy'),
      year: _intFromDynamic(value('year')),
      pricePerDay: _doubleFromDynamic(
          json['price_per_day'] ?? json['price']),
      seats: _intFromDynamic(value('seats'), 4),
      transmission: _stringFromDynamic(value('transmission'), 'automatic'),
      fuelType: _stringFromDynamic(value('fuel_type'), 'gasoline'),
      imageUrl: (json['image_url'] ?? json['vehicle_image_url']) == null
          ? null
          : _stringFromDynamic(json['image_url'] ?? json['vehicle_image_url']),
      features:
          (value('features') as List? ?? []).map((e) => e.toString()).toList(),
      rating: _doubleFromDynamic(value('rating')),
      pickupLocation: _stringFromDynamic(
          value('pickup_location') ?? json['city']),
      luggageCapacity: _intFromDynamic(value('luggage_capacity'), 0),
      availableVehicles: _intFromDynamic(value('available_vehicles'), 1),
      insuranceFee: _doubleFromDynamic(value('insurance_fee'), 4),
      serviceFee: _doubleFromDynamic(value('service_fee'), 10),
      hasAC: _boolFromDynamic(value('has_ac'), true),
      hasGPS: _boolFromDynamic(value('has_gps'), false),
      latitude: json['latitude'] == null && value('latitude') == null
          ? null
          : _doubleFromDynamic(value('latitude')),
      longitude: json['longitude'] == null && value('longitude') == null
          ? null
          : _doubleFromDynamic(value('longitude')),
      distanceMeters: json['distance_meters'] == null
          ? null
          : _doubleFromDynamic(json['distance_meters']),
      partnerListingId: json['partner_listing_id'] == null
          ? null
          : _intFromDynamic(json['partner_listing_id']),
      partnerName: json['partner_name']?.toString(),
    );
  }
}

class CarRentalPriceBreakdown {
  final double pricePerDay;
  final int numberOfDays;
  final double insuranceFee;
  final double serviceFee;

  const CarRentalPriceBreakdown({
    required this.pricePerDay,
    required this.numberOfDays,
    required this.insuranceFee,
    required this.serviceFee,
  });

  double get subtotal => pricePerDay * numberOfDays;
  double get totalPrice => subtotal + insuranceFee + serviceFee;
}
