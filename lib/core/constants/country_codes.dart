/// قائمة الدول المدعومة في حقل اختيار كود الدولة لرقم الهاتف.
/// كل دولة ليها: اسمها بالإنجليزية، كود ISO (حرفين)، وكود الاتصال الدولي.
/// علم الدولة (الإيموجي) بيتحسب تلقائيًا من كود الـ ISO.
class Country {
  final String name;
  final String isoCode;
  final String dialCode;

  const Country({required this.name, required this.isoCode, required this.dialCode});

  /// إيموجي العلم — بيتبني من حروف كود الـ ISO (Regional Indicator Symbols).
  String get flag => isoCode.toUpperCase().split('').map((c) {
        return String.fromCharCode(0x1F1E6 + c.codeUnitAt(0) - 'A'.codeUnitAt(0));
      }).join();

  @override
  String toString() => '$flag $name ($dialCode)';
}

abstract class CountryCodes {
  /// الدولة الافتراضية لو مفيش رقم متبت مسبقًا.
  static const Country defaultCountry = Country(name: 'Egypt', isoCode: 'EG', dialCode: '+20');

  static const List<Country> all = [
    Country(name: 'Egypt', isoCode: 'EG', dialCode: '+20'),
    Country(name: 'Saudi Arabia', isoCode: 'SA', dialCode: '+966'),
    Country(name: 'United Arab Emirates', isoCode: 'AE', dialCode: '+971'),
    Country(name: 'Kuwait', isoCode: 'KW', dialCode: '+965'),
    Country(name: 'Qatar', isoCode: 'QA', dialCode: '+974'),
    Country(name: 'Bahrain', isoCode: 'BH', dialCode: '+973'),
    Country(name: 'Oman', isoCode: 'OM', dialCode: '+968'),
    Country(name: 'Jordan', isoCode: 'JO', dialCode: '+962'),
    Country(name: 'Lebanon', isoCode: 'LB', dialCode: '+961'),
    Country(name: 'Iraq', isoCode: 'IQ', dialCode: '+964'),
    Country(name: 'Syria', isoCode: 'SY', dialCode: '+963'),
    Country(name: 'Yemen', isoCode: 'YE', dialCode: '+967'),
    Country(name: 'Palestine', isoCode: 'PS', dialCode: '+970'),
    Country(name: 'Libya', isoCode: 'LY', dialCode: '+218'),
    Country(name: 'Tunisia', isoCode: 'TN', dialCode: '+216'),
    Country(name: 'Algeria', isoCode: 'DZ', dialCode: '+213'),
    Country(name: 'Morocco', isoCode: 'MA', dialCode: '+212'),
    Country(name: 'Sudan', isoCode: 'SD', dialCode: '+249'),
    Country(name: 'Turkey', isoCode: 'TR', dialCode: '+90'),
    Country(name: 'United States', isoCode: 'US', dialCode: '+1'),
    Country(name: 'Canada', isoCode: 'CA', dialCode: '+1'),
    Country(name: 'United Kingdom', isoCode: 'GB', dialCode: '+44'),
    Country(name: 'France', isoCode: 'FR', dialCode: '+33'),
    Country(name: 'Germany', isoCode: 'DE', dialCode: '+49'),
    Country(name: 'Italy', isoCode: 'IT', dialCode: '+39'),
    Country(name: 'Spain', isoCode: 'ES', dialCode: '+34'),
    Country(name: 'Portugal', isoCode: 'PT', dialCode: '+351'),
    Country(name: 'Netherlands', isoCode: 'NL', dialCode: '+31'),
    Country(name: 'Belgium', isoCode: 'BE', dialCode: '+32'),
    Country(name: 'Switzerland', isoCode: 'CH', dialCode: '+41'),
    Country(name: 'Austria', isoCode: 'AT', dialCode: '+43'),
    Country(name: 'Sweden', isoCode: 'SE', dialCode: '+46'),
    Country(name: 'Norway', isoCode: 'NO', dialCode: '+47'),
    Country(name: 'Denmark', isoCode: 'DK', dialCode: '+45'),
    Country(name: 'Finland', isoCode: 'FI', dialCode: '+358'),
    Country(name: 'Poland', isoCode: 'PL', dialCode: '+48'),
    Country(name: 'Greece', isoCode: 'GR', dialCode: '+30'),
    Country(name: 'Ireland', isoCode: 'IE', dialCode: '+353'),
    Country(name: 'Czechia', isoCode: 'CZ', dialCode: '+420'),
    Country(name: 'Ukraine', isoCode: 'UA', dialCode: '+380'),
    Country(name: 'Russia', isoCode: 'RU', dialCode: '+7'),
    Country(name: 'Israel', isoCode: 'IL', dialCode: '+972'),
    Country(name: 'China', isoCode: 'CN', dialCode: '+86'),
    Country(name: 'Japan', isoCode: 'JP', dialCode: '+81'),
    Country(name: 'South Korea', isoCode: 'KR', dialCode: '+82'),
    Country(name: 'India', isoCode: 'IN', dialCode: '+91'),
    Country(name: 'Pakistan', isoCode: 'PK', dialCode: '+92'),
    Country(name: 'Bangladesh', isoCode: 'BD', dialCode: '+880'),
    Country(name: 'Indonesia', isoCode: 'ID', dialCode: '+62'),
    Country(name: 'Malaysia', isoCode: 'MY', dialCode: '+60'),
    Country(name: 'Singapore', isoCode: 'SG', dialCode: '+65'),
    Country(name: 'Thailand', isoCode: 'TH', dialCode: '+66'),
    Country(name: 'Philippines', isoCode: 'PH', dialCode: '+63'),
    Country(name: 'Vietnam', isoCode: 'VN', dialCode: '+84'),
    Country(name: 'Australia', isoCode: 'AU', dialCode: '+61'),
    Country(name: 'New Zealand', isoCode: 'NZ', dialCode: '+64'),
    Country(name: 'Brazil', isoCode: 'BR', dialCode: '+55'),
    Country(name: 'Mexico', isoCode: 'MX', dialCode: '+52'),
    Country(name: 'Argentina', isoCode: 'AR', dialCode: '+54'),
    Country(name: 'South Africa', isoCode: 'ZA', dialCode: '+27'),
    Country(name: 'Nigeria', isoCode: 'NG', dialCode: '+234'),
    Country(name: 'Kenya', isoCode: 'KE', dialCode: '+254'),
    Country(name: 'Ethiopia', isoCode: 'ET', dialCode: '+251'),
    Country(name: 'Ghana', isoCode: 'GH', dialCode: '+233'),
  ];

  /// بيدور على أطول كود اتصال بيطابق بداية الرقم الكامل (مفيد لتفكيك رقم
  /// محفوظ زي "+201001234567" لمعرفة الدولة والرقم المحلي).
  static (Country country, String nationalNumber) splitFullNumber(String fullNumber) {
    final trimmed = fullNumber.trim();
    Country? best;
    for (final c in all) {
      if (trimmed.startsWith(c.dialCode) && (best == null || c.dialCode.length > best.dialCode.length)) {
        best = c;
      }
    }
    if (best == null) return (defaultCountry, trimmed.replaceFirst('+', ''));
    return (best, trimmed.substring(best.dialCode.length));
  }
}
