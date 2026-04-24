class CountryPreview {
  const CountryPreview({required this.name, required this.flagUrl});

  final String name;
  final String flagUrl;

  static String _readString(dynamic value, {String fallback = ''}) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return fallback;
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  factory CountryPreview.fromJson(Map<String, dynamic> json) {
    final nameMap = _readMap(json['name']);
    final flagsMap = _readMap(json['flags']);

    return CountryPreview(
      name: _readString(nameMap['common'], fallback: 'Sem nome'),
      flagUrl: _readString(flagsMap['png']),
    );
  }
}

class Country {
  const Country({
    required this.name,
    required this.officialName,
    required this.region,
    required this.capitals,
    required this.population,
    required this.languages,
    required this.flagUrl,
    required this.googleMapsUrl,
    required this.openStreetMapsUrl,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String officialName;
  final String region;
  final List<String> capitals;
  final int population;
  final List<String> languages;
  final String flagUrl;
  final String googleMapsUrl;
  final String openStreetMapsUrl;
  final double? latitude;
  final double? longitude;

  static String _readString(dynamic value, {String fallback = ''}) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return fallback;
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    final nameMap = _readMap(json['name']);
    final flagsMap = _readMap(json['flags']);
    final mapsMap = _readMap(json['maps']);
    final languagesMap = _readMap(json['languages']);

    final safeName = _readString(nameMap['common'], fallback: 'Sem nome');
    final officialName = _readString(nameMap['official'], fallback: safeName);
    final safeRegion = _readString(json['region'], fallback: 'Sem regiao');
    final population = json['population'] is num
        ? (json['population'] as num).toInt()
        : 0;

    final flagUrl = _readString(flagsMap['png']);
    final googleMapsUrl = _readString(mapsMap['googleMaps']);
    final openStreetMapsUrl = _readString(mapsMap['openStreetMaps']);
    final languages = languagesMap.values
        .whereType<String>()
        .where((language) => language.trim().isNotEmpty)
        .toList();

    final capitalData = json['capital'];
    final capitals = capitalData is List
        ? capitalData.whereType<String>().toList()
        : const <String>[];
    final latLngData = json['latlng'];
    double? latitude;
    double? longitude;
    if (latLngData is List && latLngData.length >= 2) {
      final lat = latLngData[0];
      final lng = latLngData[1];
      if (lat is num && lng is num) {
        latitude = lat.toDouble();
        longitude = lng.toDouble();
      }
    }

    return Country(
      name: safeName,
      officialName: officialName,
      region: safeRegion,
      capitals: capitals,
      population: population,
      languages: languages,
      flagUrl: flagUrl,
      googleMapsUrl: googleMapsUrl,
      openStreetMapsUrl: openStreetMapsUrl,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
