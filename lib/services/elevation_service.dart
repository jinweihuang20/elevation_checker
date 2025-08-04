import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_data.dart';
import 'elevation_cache_service.dart';

class ElevationService {
  static const String _baseUrl = 'https://api.opentopodata.org/v1/srtm90m';
  final ElevationCacheService _cacheService;

  ElevationService(this._cacheService);

  Future<(double?, DataSource)?> getElevation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // 先檢查快取
      final cachedData = _cacheService.getElevation(latitude, longitude);
      if (cachedData != null) {
        print('使用快取的海拔數據');
        return (cachedData.elevation, DataSource.cache);
      }

      // 如果快取中沒有，則從 API 獲取
      print('從 API 獲取海拔數據');
      final response = await http.get(
        Uri.parse('$_baseUrl?locations=$latitude,$longitude'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final elevation = data['results'][0]['elevation'] as num;

          // 將新數據添加到快取
          await _cacheService.addElevation(
            latitude,
            longitude,
            elevation.toDouble(),
          );

          return (elevation.toDouble(), DataSource.api);
        }
      }
      return null;
    } catch (e) {
      print('獲取海拔數據時發生錯誤: $e');
      return null;
    }
  }
}
