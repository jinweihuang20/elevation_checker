import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/elevation_cache.dart';

class ElevationCacheService {
  static const String _cacheKey = 'elevation_cache';
  static const int _maxCacheSize = 100; // 最大快取數量
  static const Duration _cacheExpiration = Duration(days: 7); // 快取過期時間

  final SharedPreferences _prefs;
  List<CachedElevation> _cache = [];
  bool _isInitialized = false;

  ElevationCacheService(this._prefs);

  // 初始化快取
  Future<void> init() async {
    if (_isInitialized) return;

    final String? cachedData = _prefs.getString(_cacheKey);
    if (cachedData != null) {
      final List<dynamic> cacheList = json.decode(cachedData);
      _cache = cacheList
          .map((item) => CachedElevation.fromJson(item))
          .where((cache) => !_isExpired(cache)) // 過濾過期數據
          .toList();
    }
    _isInitialized = true;
  }

  // 檢查快取是否過期
  bool _isExpired(CachedElevation cache) {
    final now = DateTime.now();
    return now.difference(cache.timestamp) > _cacheExpiration;
  }

  // 從快取中獲取海拔數據
  CachedElevation? getElevation(double latitude, double longitude) {
    final cachedData = _cache.where(
      (cache) => cache.isWithinRange(latitude, longitude),
    );

    if (cachedData.isEmpty) return null;

    // 返回最新的快取數據
    return cachedData
        .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }

  // 添加新的快取數據
  Future<void> addElevation(
    double latitude,
    double longitude,
    double elevation, {
    bool isFromHomeScreen = false,
  }) async {
    print(
        '[ElevationCacheService-addElevation] isFromHomeScreen: $isFromHomeScreen');
    // 移除相同位置的舊數據
    _cache.removeWhere(
      (cache) => cache.isWithinRange(latitude, longitude),
    );

    // 添加新數據
    _cache.add(CachedElevation(
      latitude: latitude,
      longitude: longitude,
      elevation: elevation,
      timestamp: DateTime.now(),
      isFromHomeScreen: isFromHomeScreen,
    ));

    // 如果超過最大快取數量，移除最舊的數據
    if (_cache.length > _maxCacheSize) {
      _cache.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      _cache = _cache.sublist(_cache.length - _maxCacheSize);
    }

    // 保存快取到持久化存儲
    await _saveCache();
  }

  // 清除過期的快取
  Future<void> clearExpiredCache() async {
    _cache.removeWhere((cache) => _isExpired(cache));
    await _saveCache();
  }

  // 保存快取到 SharedPreferences
  Future<void> _saveCache() async {
    final cacheJson = _cache.map((cache) => cache.toJson()).toList();
    await _prefs.setString(_cacheKey, json.encode(cacheJson));
  }

  // 獲取首頁的歷史海拔記錄
  List<CachedElevation> getHomeScreenElevations() {
    return _cache.where((cache) => cache.isFromHomeScreen).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // 按時間降序排序
  }

  // 清除首頁的歷史海拔記錄
  Future<void> clearHomeScreenElevations() async {
    _cache.removeWhere((cache) => cache.isFromHomeScreen);
    await _saveCache();
  }

  // 清除所有快取
  Future<void> clearAll() async {
    _cache.clear();
    await _prefs.remove(_cacheKey);
  }
}
