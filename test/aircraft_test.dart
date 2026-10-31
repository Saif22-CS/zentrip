import 'package:flutter_test/flutter_test.dart';
import 'package:zentrip/features/aircraft/airbus_a320.dart';
import 'package:zentrip/features/aircraft/atr72.dart';

void main() {
  test('Airbus A320 exposes its 3-3 180-seat cabin', () {
    expect(airbusA320.seatLayout, '3-3');
    expect(airbusA320.rowCount, 30);
    expect(airbusA320.seatCapacity, 180);
    expect(airbusA320.exitRows, {11, 12});
  });

  test('ATR 72 exposes its 2-2 64-seat cabin', () {
    expect(atr72.seatLayout, '2-2');
    expect(atr72.rowCount, 16);
    expect(atr72.seatCapacity, 64);
    expect(atr72.exitRows, {7, 8});
  });
}
