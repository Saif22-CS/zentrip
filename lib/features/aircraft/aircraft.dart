/// Describes the seat layout of one aircraft.
/// Each aircraft lives in its own file (see atr72.dart, airbus_a320.dart).
class Aircraft {
  final String id;
  final String name;
  final String seatLayout;

  /// Seat letters in order: first half is left of the aisle, second half right.
  final List<String> letters;

  final int rowCount;

  /// Emergency exit rows (shown with an EXIT mark). Empty = none.
  final Set<int> exitRows;

  /// Rows with extra legroom and a seat surcharge.
  final Set<int> legroomRows;

  const Aircraft({
    required this.id,
    required this.name,
    required this.seatLayout,
    required this.letters,
    required this.rowCount,
    this.exitRows = const {},
    this.legroomRows = const {},
  });

  int get seatCapacity => rowCount * letters.length;
  int get seatsPerSide => letters.length ~/ 2;
  double get seatSize => letters.length > 4 ? 30 : 36;
}
