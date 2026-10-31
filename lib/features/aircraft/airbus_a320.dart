import 'aircraft.dart';

/// Airbus A320 economy map: 30 rows, six seats per row, 180 seats total.
const airbusA320 = Aircraft(
  id: 'airbus_a320',
  name: 'Airbus A320',
  seatLayout: '3-3',
  letters: ['A', 'B', 'C', 'D', 'E', 'F'],
  rowCount: 30,
  exitRows: {11, 12},
  legroomRows: {1, 11, 12},
);
