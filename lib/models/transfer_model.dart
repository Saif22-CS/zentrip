class TransferModel {
  final String id;
  final String vehicleType; // 'sedan' | 'minivan' | 'bus' | 'luxury'
  final String vehicleName;
  final int maxPassengers;
  final int maxLuggage;
  final double price;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime pickupTime;
  final int durationMinutes;
  final String? driverName;
  final String? driverPhone;
  final double? driverRating;
  final String? vehicleImageUrl;
  final String status; // 'pending' | 'confirmed' | 'completed'
  final String providerName;
  final List<String> includedServices;
  final int? partnerListingId;
  final String? partnerName;

  double get priceUSD => price; // alias

  TransferModel copyWith({
    String? pickupLocation,
    String? dropoffLocation,
    DateTime? pickupTime,
  }) =>
      TransferModel(
        id: id,
        vehicleType: vehicleType,
        vehicleName: vehicleName,
        maxPassengers: maxPassengers,
        maxLuggage: maxLuggage,
        price: price,
        pickupLocation: pickupLocation ?? this.pickupLocation,
        dropoffLocation: dropoffLocation ?? this.dropoffLocation,
        pickupTime: pickupTime ?? this.pickupTime,
        durationMinutes: durationMinutes,
        driverName: driverName,
        driverPhone: driverPhone,
        driverRating: driverRating,
        vehicleImageUrl: vehicleImageUrl,
        status: status,
        providerName: providerName,
        includedServices: includedServices,
        partnerListingId: partnerListingId,
        partnerName: partnerName,
      );

  const TransferModel({
    required this.id,
    required this.vehicleType,
    required this.vehicleName,
    required this.maxPassengers,
    required this.maxLuggage,
    required this.price,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupTime,
    required this.durationMinutes,
    this.driverName,
    this.driverPhone,
    this.driverRating,
    this.vehicleImageUrl,
    this.status = 'pending',
    this.providerName = 'Zentrip Transfers',
    this.includedServices = const [],
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
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  factory TransferModel.fromJson(Map<String, dynamic> json) => TransferModel(
        id: _stringFromDynamic(json['id']),
        vehicleType: _stringFromDynamic(json['vehicle_type']),
        vehicleName: _stringFromDynamic(json['vehicle_name']),
        maxPassengers: _intFromDynamic(json['max_passengers'], 1),
        maxLuggage: _intFromDynamic(json['max_luggage'], 0),
        price: _doubleFromDynamic(json['price']),
        pickupLocation: _stringFromDynamic(json['pickup_location']),
        dropoffLocation: _stringFromDynamic(json['dropoff_location']),
        pickupTime: _parseDateTime(json['pickup_time']),
        durationMinutes: _intFromDynamic(json['duration_minutes'], 0),
        driverName: _stringFromDynamic(json['driver_name'], 'null') == 'null'
            ? null
            : _stringFromDynamic(json['driver_name']),
        driverPhone: _stringFromDynamic(json['driver_phone'], 'null') == 'null'
            ? null
            : _stringFromDynamic(json['driver_phone']),
        driverRating: json['driver_rating'] == null
            ? null
            : _doubleFromDynamic(json['driver_rating']),
        vehicleImageUrl:
            _stringFromDynamic(json['vehicle_image_url'], 'null') == 'null'
                ? null
                : _stringFromDynamic(json['vehicle_image_url']),
        status: _stringFromDynamic(json['status'], 'pending'),
        providerName:
            _stringFromDynamic(json['provider_name'], 'Zentrip Transfers'),
        includedServices: (json['included_services'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        partnerListingId: json['partner_listing_id'] == null
            ? null
            : _intFromDynamic(json['partner_listing_id']),
        partnerName: json['partner_name']?.toString(),
      );
}
