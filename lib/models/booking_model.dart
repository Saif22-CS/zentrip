/// نوع الحجز — الطيران بيستخدم TripModel المخصص له (شكله مختلف تمامًا:
/// مطارات، رقم رحلة..الخ)، والموديل ده بيغطي الباقي (فندق/سيارة/نشاط)
/// اللي بينفعهم شكل عام موحّد.
enum BookingType { hotel, car, attraction, package }

class BookingModel {
  final String id;
  final BookingType type;
  final String title; // اسم الفندق / السيارة / النشاط
  final String subtitle; // المدينة أو الموقع
  final DateTime date; // تاريخ الوصول / الاستلام / الزيارة
  final DateTime? endDate;
  final double? price;
  final String? refCode;
  final String status; // 'upcoming' | 'completed' | 'cancelled'
  final String? imageUrl; // صورة الغلاف في كارت رحلاتي
  final int? partnerListingId;
  final int rooms;

  const BookingModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    this.endDate,
    this.price,
    this.refCode,
    this.status = 'upcoming',
    this.imageUrl,
    this.partnerListingId,
    this.rooms = 1,
  });

  static String _stringFromDynamic(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return value.toString();
  }

  static double _doubleFromDynamic(dynamic value, [double fallback = 0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: _stringFromDynamic(json['id']),
        type: BookingType.values.firstWhere(
          (t) => t.name == _stringFromDynamic(json['type']),
          orElse: () => BookingType.hotel,
        ),
        title: _stringFromDynamic(json['title']),
        subtitle: _stringFromDynamic(json['subtitle']),
        date: DateTime.tryParse(_stringFromDynamic(json['date'])) ??
            DateTime.now(),
        endDate: json['end_date'] == null ||
                _stringFromDynamic(json['end_date']).isEmpty
            ? null
            : DateTime.tryParse(_stringFromDynamic(json['end_date'])),
        price: json['price'] == null ? null : _doubleFromDynamic(json['price']),
        refCode: json['ref_code'] == null
            ? null
            : _stringFromDynamic(json['ref_code']),
        status: _stringFromDynamic(json['status'], 'upcoming'),
        imageUrl: json['image_url'] == null ||
                _stringFromDynamic(json['image_url']).isEmpty
            ? null
            : _stringFromDynamic(json['image_url']),
        partnerListingId: json['partner_listing_id'] == null
            ? null
            : int.tryParse(json['partner_listing_id'].toString()),
        rooms: int.tryParse('${json['rooms'] ?? 1}') ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'subtitle': subtitle,
        'date': date.toUtc().toIso8601String(),
        'end_date': endDate?.toUtc().toIso8601String(),
        'price': price,
        'ref_code': refCode,
        'status': status,
        'image_url': imageUrl,
        'partner_listing_id': partnerListingId,
        if (type == BookingType.hotel) 'rooms': rooms,
      };
}
