class WeatherInfo {
  final double tempCelsius;
  final String condition; // 'sunny' | 'cloudy' | 'rainy' | 'clear'
  final String cityName;

  const WeatherInfo(
      {required this.tempCelsius,
      required this.condition,
      required this.cityName});

  static double _doubleFromDynamic(dynamic value, [double fallback = 0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  factory WeatherInfo.fromJson(Map<String, dynamic> j) => WeatherInfo(
        tempCelsius: _doubleFromDynamic(j['temp_c']),
        condition: (j['condition'] ?? '').toString(),
        cityName: (j['city'] ?? '').toString(),
      );
}

class VisaInfo {
  final String
      requirement; // 'visa_free' | 'visa_on_arrival' | 'e_visa' | 'visa_required'
  final String notes;

  const VisaInfo({required this.requirement, required this.notes});

  factory VisaInfo.fromJson(Map<String, dynamic> j) => VisaInfo(
        requirement: (j['requirement'] ?? '').toString(),
        notes: (j['notes'] ?? '').toString(),
      );
}
