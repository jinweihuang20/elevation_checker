class CachedElevation {
  final double latitude;
  final double longitude;
  final double elevation;
  final DateTime timestamp;

  const CachedElevation({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.timestamp,
  });

  // 檢查給定的座標是否在誤差範圍內
  // 誤差設定為 0.0001 度（約等於 11 公尺）
  bool isWithinRange(double lat, double lon) {
    const double tolerance = 0.0001;
    return (latitude - lat).abs() <= tolerance &&
        (longitude - lon).abs() <= tolerance;
  }

  // 將快取數據轉換為 Map 以便存儲
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // 從 Map 創建快取數據
  factory CachedElevation.fromJson(Map<String, dynamic> json) {
    return CachedElevation(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      elevation: json['elevation'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
