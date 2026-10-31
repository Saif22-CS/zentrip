class AdminDashboardData {
  final int customerCount;
  final int newCustomers;
  final int reservationCount;
  final int flightCount;
  final int serviceBookingCount;
  final int transferCount;
  final double bookedValue;
  final List<AdminReservation> recentReservations;

  const AdminDashboardData({
    required this.customerCount,
    required this.newCustomers,
    required this.reservationCount,
    required this.flightCount,
    required this.serviceBookingCount,
    required this.transferCount,
    required this.bookedValue,
    required this.recentReservations,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>;
    final reservations = json['recent_reservations'] as List? ?? const [];
    return AdminDashboardData(
      customerCount: _asInt(summary['customer_count']),
      newCustomers: _asInt(summary['new_customers_30d']),
      reservationCount: _asInt(summary['reservation_count']),
      flightCount: _asInt(summary['flight_count']),
      serviceBookingCount: _asInt(summary['service_booking_count']),
      transferCount: _asInt(summary['transfer_count']),
      bookedValue: _asDouble(summary['booked_value']),
      recentReservations: reservations
          .map((item) =>
              AdminReservation.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdminReservation {
  final String id;
  final String type;
  final String title;
  final String customerName;
  final DateTime? reservationDate;
  final double amount;
  final String status;

  const AdminReservation({
    required this.id,
    required this.type,
    required this.title,
    required this.customerName,
    required this.reservationDate,
    required this.amount,
    required this.status,
  });

  factory AdminReservation.fromJson(Map<String, dynamic> json) =>
      AdminReservation(
        id: '${json['id'] ?? ''}',
        type: '${json['type'] ?? ''}',
        title: '${json['title'] ?? ''}',
        customerName: '${json['customer_name'] ?? ''}',
        reservationDate: DateTime.tryParse('${json['reservation_date'] ?? ''}'),
        amount: _asDouble(json['amount']),
        status: '${json['status'] ?? ''}',
      );
}

class AdminCustomer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime? joinedAt;
  final int reservationCount;

  const AdminCustomer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.joinedAt,
    required this.reservationCount,
  });

  factory AdminCustomer.fromJson(Map<String, dynamic> json) => AdminCustomer(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        email: '${json['email'] ?? ''}',
        phone: '${json['phone'] ?? ''}',
        joinedAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
        reservationCount: _asInt(json['reservation_count']),
      );
}

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}
