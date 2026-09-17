class QiblaInfo {
  final double direction; // Degrees from True North (0–360)
  final double latitude;
  final double longitude;
  final String cityName;

  QiblaInfo({
    required this.direction,
    required this.latitude,
    required this.longitude,
    this.cityName = '',
  });

  factory QiblaInfo.fromJson(Map<String, dynamic> json, double lat, double lon) {
    // API MyQuran: https://api.myquran.com/v3/qibla/-6.200000,106.816666
    // Response format:
    // { "status": true, "data": { "direction": 295.15, ... } } or similar
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    final dir = (data['direction'] as num?)?.toDouble() ??
        (data['qibla_direction'] as num?)?.toDouble() ??
        (data['derajat'] as num?)?.toDouble() ??
        295.0;
    return QiblaInfo(
      direction: dir,
      latitude: lat,
      longitude: lon,
      cityName: data['city'] as String? ?? data['kabupaten'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'direction': direction,
        'latitude': latitude,
        'longitude': longitude,
        'cityName': cityName,
      };

  factory QiblaInfo.fromCache(Map<String, dynamic> json) => QiblaInfo(
        direction: (json['direction'] as num).toDouble(),
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        cityName: json['cityName'] as String? ?? '',
      );

  /// Default (Jakarta / Indonesia standard fallback ~ 295°)
  factory QiblaInfo.defaultInfo() => QiblaInfo(
        direction: 295.15,
        latitude: -6.200000,
        longitude: 106.816666,
        cityName: 'Jakarta (Default)',
      );
}
