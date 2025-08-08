import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/analytics_consent_dialog.dart';
import 'screens/main_screen.dart';
import 'services/timezone_service.dart';
import 'services/elevation_service.dart';
import 'services/elevation_cache_service.dart';
import 'services/firebase_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.initialize();

  requestPermission();
  await FirebaseService.instance.getToken();
  await FirebaseService.instance.logEvent(name: 'user_open_app');
  final prefs = await SharedPreferences.getInstance();
  final cacheService = ElevationCacheService(prefs);
  await cacheService.init();
  final elevationService = ElevationService(cacheService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimezoneService()),
        Provider.value(value: elevationService),
        Provider.value(value: cacheService),
      ],
      child: const MyApp(),
    ),
  );
}

void requestPermission() async {
  if (!FirebaseService.instance.isAnalyticsEnabled) {
    return;
  }

  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ 使用者已授權通知');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          '🔔 前景推播通知: Title: ${message.notification} Body: ${message.notification?.body}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔓 使用者點了通知');
    });
  } else {
    print('❌ 使用者拒絕或未授權通知');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          // 在應用程序啟動後檢查是否需要顯示隱私同意對話框
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AnalyticsConsentDialog.showIfNeeded(context);
          });
          return const GradientBackground(child: MainScreen());
        },
      ),
      title: '海拔查詢',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50.withOpacity(1),
            Colors.blue.shade50.withOpacity(1),
            Colors.green.shade50.withOpacity(1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
