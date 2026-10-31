Map<String, dynamic> parseHotelLocationInput(String value) {
  final input = value.trim();
  if (input.isEmpty || input.length > 2048) {
    throw const FormatException('Invalid hotel location');
  }

  final decoded = Uri.decodeComponent(input);
  final parts = decoded
      .split(RegExp(r'[\r\n]+'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  final coordinateMatch = RegExp(
    r'!3d(-?\d{1,2}(?:\.\d+)?)!4d(-?\d{1,3}(?:\.\d+)?)|@?(-?\d{1,2}(?:\.\d+)?)\s*,\s*(-?\d{1,3}(?:\.\d+)?)',
  ).firstMatch(decoded);
  final placeMatch = RegExp(
    r'(?:place_id|query_place_id)=([^&!]+)|!1s(ChIJ[A-Za-z0-9_-]+)',
    caseSensitive: false,
  ).firstMatch(decoded);

  if (coordinateMatch != null) {
    final latitude = double.tryParse(
      coordinateMatch.group(1) ?? coordinateMatch.group(3)!,
    );
    final longitude = double.tryParse(
      coordinateMatch.group(2) ?? coordinateMatch.group(4)!,
    );
    if (latitude == null ||
        longitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw const FormatException('Invalid hotel coordinates');
    }
    return {
      'location_input': input,
      'latitude': latitude,
      'longitude': longitude,
      if (placeMatch != null)
        'google_place_id':
            (placeMatch.group(1) ?? placeMatch.group(2))!.trim(),
    };
  }

  var placeId = placeMatch?.group(1) ?? placeMatch?.group(2);
  if (placeId == null && decoded.toLowerCase().startsWith('place_id:')) {
    placeId = decoded.substring('place_id:'.length);
  }
  if (placeId == null &&
      RegExp(r'^[A-Za-z0-9_-]{10,255}$').hasMatch(decoded)) {
    placeId = decoded;
  }
  if (placeId != null && placeId.trim().isNotEmpty && placeId.length <= 255) {
    return {
      'location_input': input,
      'google_place_id': placeId.trim(),
    };
  }

  if (parts.any(_isGoogleMapsUrl) || _isPlusCodeLocation(decoded)) {
    return {'location_input': input};
  }
  throw const FormatException('Invalid hotel location');
}

bool _isGoogleMapsUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      !(uri.scheme == 'https' || uri.scheme == 'http') ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort) {
    return false;
  }
  final host = uri.host.toLowerCase();
  return host == 'maps.app.goo.gl' ||
      host == 'maps.google.com' ||
      ((host == 'google.com' || host == 'www.google.com') &&
          uri.path.startsWith('/maps'));
}

bool _isPlusCodeLocation(String value) => RegExp(
      r'^(?:[23456789CFGHJMPQRVWX]{2}|'
      r'[23456789CFGHJMPQRVWX]{4}|'
      r'[23456789CFGHJMPQRVWX]{6}|'
      r'[23456789CFGHJMPQRVWX]{8})'
      r'\+[23456789CFGHJMPQRVWX]{2,3}'
      r'(?:\s*,\s*.+)?$',
      caseSensitive: false,
    ).hasMatch(value.trim());
