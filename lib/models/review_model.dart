class ReviewModel {
  final String id;
  final String itemId;
  final String itemType; // 'hotel' | 'car' | 'attraction' | 'package'
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  static double _doubleFromDynamic(dynamic value, [double fallback = 0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'item_id': itemId,
        'item_type': itemType,
        'user_name': userName,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };

  factory ReviewModel.fromJson(Map<String, dynamic> j) => ReviewModel(
        id: (j['id'] ?? '').toString(),
        itemId: (j['item_id'] ?? '').toString(),
        itemType: (j['item_type'] ?? '').toString(),
        userName: (j['user_name'] ?? '').toString(),
        rating: _doubleFromDynamic(j['rating']),
        comment: (j['comment'] ?? '').toString(),
        createdAt: DateTime.tryParse((j['created_at'] ?? '').toString()) ??
            DateTime.now(),
      );
}
