class CountryPhoneOption {
  final String name;
  final String flag;
  final String dialCode;
  final int minNationalDigits;
  final int maxNationalDigits;

  const CountryPhoneOption({
    required this.name,
    required this.flag,
    required this.dialCode,
    required this.minNationalDigits,
    required this.maxNationalDigits,
  });

  bool accepts(String nationalNumber) =>
      RegExp(r'^[0-9]+$').hasMatch(nationalNumber) &&
      nationalNumber.length >= minNationalDigits &&
      nationalNumber.length <= maxNationalDigits;

  static const supported = <CountryPhoneOption>[
    CountryPhoneOption(
        name: 'Libya',
        flag: '🇱🇾',
        dialCode: '218',
        minNationalDigits: 9,
        maxNationalDigits: 9),
    CountryPhoneOption(
        name: 'Egypt',
        flag: '🇪🇬',
        dialCode: '20',
        minNationalDigits: 10,
        maxNationalDigits: 10),
    CountryPhoneOption(
        name: 'Tunisia',
        flag: '🇹🇳',
        dialCode: '216',
        minNationalDigits: 8,
        maxNationalDigits: 8),
    CountryPhoneOption(
        name: 'Algeria',
        flag: '🇩🇿',
        dialCode: '213',
        minNationalDigits: 9,
        maxNationalDigits: 9),
    CountryPhoneOption(
        name: 'Morocco',
        flag: '🇲🇦',
        dialCode: '212',
        minNationalDigits: 9,
        maxNationalDigits: 9),
    CountryPhoneOption(
        name: 'Sudan',
        flag: '🇸🇩',
        dialCode: '249',
        minNationalDigits: 9,
        maxNationalDigits: 9),
    CountryPhoneOption(
        name: 'Jordan',
        flag: '🇯🇴',
        dialCode: '962',
        minNationalDigits: 9,
        maxNationalDigits: 9),
    CountryPhoneOption(
        name: 'Saudi Arabia',
        flag: '🇸🇦',
        dialCode: '966',
        minNationalDigits: 9,
        maxNationalDigits: 9),
    CountryPhoneOption(
        name: 'United Arab Emirates',
        flag: '🇦🇪',
        dialCode: '971',
        minNationalDigits: 9,
        maxNationalDigits: 9),
    CountryPhoneOption(
        name: 'Qatar',
        flag: '🇶🇦',
        dialCode: '974',
        minNationalDigits: 8,
        maxNationalDigits: 8),
    CountryPhoneOption(
        name: 'Kuwait',
        flag: '🇰🇼',
        dialCode: '965',
        minNationalDigits: 8,
        maxNationalDigits: 8),
    CountryPhoneOption(
        name: 'Oman',
        flag: '🇴🇲',
        dialCode: '968',
        minNationalDigits: 8,
        maxNationalDigits: 8),
    CountryPhoneOption(
        name: 'Turkey',
        flag: '🇹🇷',
        dialCode: '90',
        minNationalDigits: 10,
        maxNationalDigits: 10),
    CountryPhoneOption(
        name: 'United Kingdom',
        flag: '🇬🇧',
        dialCode: '44',
        minNationalDigits: 10,
        maxNationalDigits: 10),
    CountryPhoneOption(
        name: 'United States',
        flag: '🇺🇸',
        dialCode: '1',
        minNationalDigits: 10,
        maxNationalDigits: 10),
    CountryPhoneOption(
        name: 'Canada',
        flag: '🇨🇦',
        dialCode: '1',
        minNationalDigits: 10,
        maxNationalDigits: 10),
    CountryPhoneOption(
        name: 'France',
        flag: '🇫🇷',
        dialCode: '33',
        minNationalDigits: 9,
        maxNationalDigits: 9),
    CountryPhoneOption(
        name: 'Germany',
        flag: '🇩🇪',
        dialCode: '49',
        minNationalDigits: 7,
        maxNationalDigits: 11),
    CountryPhoneOption(
        name: 'India',
        flag: '🇮🇳',
        dialCode: '91',
        minNationalDigits: 10,
        maxNationalDigits: 10),
    CountryPhoneOption(
        name: 'Pakistan',
        flag: '🇵🇰',
        dialCode: '92',
        minNationalDigits: 10,
        maxNationalDigits: 10),
  ];
}
