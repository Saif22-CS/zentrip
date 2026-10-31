import 'aircraft.dart';

/// ATR 72 economy map: 16 rows, four seats per row, 64 seats total.
const atr72 = Aircraft(
  id: 'atr72',
  name: 'ATR 72',
  seatLayout: '2-2',
  letters: ['A', 'B', 'C', 'D'],
  rowCount: 16,
  exitRows: {7, 8},
  legroomRows: {1, 7, 8},
);
