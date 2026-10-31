class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final int? partnerId;
  final String? partnerName;
  final String? partnerServiceType;
  final String? photoUrl;
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'customer',
    this.partnerId,
    this.partnerName,
    this.partnerServiceType,
    this.photoUrl,
    this.token,
  });

  static int _intFromDynamic(dynamic value, [int fallback = 0]) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
    }
    return fallback;
  }

  static String _stringFromDynamic(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return value.toString();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: _intFromDynamic(json['id']),
        name: _stringFromDynamic(json['name']),
        email: _stringFromDynamic(json['email']),
        phone: _stringFromDynamic(json['phone']),
        role: _stringFromDynamic(json['role'], 'customer'),
        partnerId: json['partner_id'] == null
            ? null
            : _intFromDynamic(json['partner_id']),
        partnerName: json['partner_name']?.toString(),
        partnerServiceType: json['partner_service_type']?.toString(),
        photoUrl: json['photo_url'] == null
            ? null
            : _stringFromDynamic(json['photo_url']),
        token: json['token'] == null ? null : _stringFromDynamic(json['token']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'partner_id': partnerId,
        'partner_name': partnerName,
        'partner_service_type': partnerServiceType,
        'photo_url': photoUrl,
      };

  UserModel copyWith({String? name, String? phone, String? photoUrl}) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        role: role,
        partnerId: partnerId,
        partnerName: partnerName,
        partnerServiceType: partnerServiceType,
        photoUrl: photoUrl ?? this.photoUrl,
        token: token,
      );

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isPartner => role.toLowerCase() == 'partner' && partnerId != null;
}
