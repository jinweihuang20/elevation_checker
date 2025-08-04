enum DataSource { api, cache, none }

class LocationData {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? elevation;
  final DataSource dataSource;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.elevation,
    this.dataSource = DataSource.none,
  });

  LocationData copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? elevation,
    DataSource? dataSource,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      elevation: elevation ?? this.elevation,
      dataSource: dataSource ?? this.dataSource,
    );
  }
}
