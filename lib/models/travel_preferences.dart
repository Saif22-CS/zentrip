class TravelPreferences {
  final String budgetLevel;
  final String travelPace;
  final int tripDurationDays;
  final int travelers;
  final List<String> interests;
  final String preferredDestination;

  const TravelPreferences({
    this.budgetLevel = 'balanced',
    this.travelPace = 'balanced',
    this.tripDurationDays = 7,
    this.travelers = 1,
    this.interests = const [],
    this.preferredDestination = '',
  });

  factory TravelPreferences.fromJson(Map<String, dynamic> json) {
    int number(dynamic value, int fallback) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

    return TravelPreferences(
      budgetLevel: json['budget_level']?.toString() ?? 'balanced',
      travelPace: json['travel_pace']?.toString() ?? 'balanced',
      tripDurationDays: number(json['trip_duration_days'], 7),
      travelers: number(json['travelers'], 1),
      interests: (json['interests'] as List? ?? const [])
          .map((value) => value.toString())
          .toList(),
      preferredDestination: json['preferred_destination']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'budget_level': budgetLevel,
        'travel_pace': travelPace,
        'trip_duration_days': tripDurationDays,
        'travelers': travelers,
        'interests': interests,
        'preferred_destination': preferredDestination,
      };

  TravelPreferences copyWith({
    String? budgetLevel,
    String? travelPace,
    int? tripDurationDays,
    int? travelers,
    List<String>? interests,
    String? preferredDestination,
  }) =>
      TravelPreferences(
        budgetLevel: budgetLevel ?? this.budgetLevel,
        travelPace: travelPace ?? this.travelPace,
        tripDurationDays: tripDurationDays ?? this.tripDurationDays,
        travelers: travelers ?? this.travelers,
        interests: interests ?? this.interests,
        preferredDestination: preferredDestination ?? this.preferredDestination,
      );
}
