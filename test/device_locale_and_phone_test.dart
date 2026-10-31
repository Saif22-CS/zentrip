import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zentrip/features/auth/presentation/models/country_phone_option.dart';
import 'package:zentrip/global_widgets/locale_controller.dart';

void main() {
  test('country phone lengths accept only valid national digit counts', () {
    final libya = CountryPhoneOption.supported.first;
    final egypt = CountryPhoneOption.supported[1];

    expect(libya.accepts('912345678'), isTrue);
    expect(libya.accepts('91234567'), isFalse);
    expect(libya.accepts('9123456780'), isFalse);
    expect(libya.accepts('91234abcd'), isFalse);
    expect(egypt.accepts('1012345678'), isTrue);
    expect(egypt.accepts('101234567'), isFalse);
  });

  test('locale resolution matches device language and falls back to English',
      () {
    const supported = [Locale('ar'), Locale('en')];

    expect(
      LocaleController.resolveSupportedLocale(
          const Locale('ar', 'EG'), supported),
      const Locale('ar'),
    );
    expect(
      LocaleController.resolveSupportedLocale(
          const Locale('fr', 'FR'), supported),
      const Locale('en'),
    );
    expect(
      LocaleController.resolveSupportedLocale(null, supported),
      const Locale('en'),
    );
  });
}
