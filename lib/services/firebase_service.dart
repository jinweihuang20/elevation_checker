import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static FirebaseService? _instance;
  late final FirebaseAnalytics _analytics;
  bool _initialized = false;
  bool _analyticsEnabled = true;

  // 私有構造函數
  FirebaseService._();

  // 單例模式獲取實例
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  // 初始化 Firebase
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Error initializing Firebase: $e');
      _analyticsEnabled = false;
      return;
    }
    _analytics = FirebaseAnalytics.instance;

    // 從 SharedPreferences 讀取用戶分析同意狀態
    final prefs = await SharedPreferences.getInstance();
    _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;

    _initialized = true;
  }

  Future<void> getToken() async {
    if (!_initialized) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print('Firebase token: $token');
    } catch (e) {
      print('Error getting Firebase token: $e');
    }
  }

  // 記錄事件
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_initialized) {
      print('FirebaseService not initialized');
      return;
    }

    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // 設置分析功能啟用狀態
  Future<void> setAnalyticsEnabled(bool enabled) async {
    _analyticsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('analytics_enabled', enabled);
  }

  // 獲取分析功能啟用狀態
  bool get isAnalyticsEnabled => _analyticsEnabled;

  // 獲取 FirebaseAnalytics 實例
  FirebaseAnalytics get analytics {
    if (!_initialized) {
      print('FirebaseService not initialized');
      return FirebaseAnalytics.instance;
    }
    return _analytics;
  }
}
