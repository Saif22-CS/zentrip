class BookingData {
  final String cabinClass;
  final int farePrice;
  final String aircraft;
  final String seat;
  final List<String> extras;
  final int total;
  final String reference;
  final String passenger;

  const BookingData({
    required this.cabinClass,
    required this.farePrice,
    required this.aircraft,
    required this.seat,
    required this.extras,
    required this.total,
    required this.reference,
    required this.passenger,
  });
}
