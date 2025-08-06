import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'services/timezone_service.dart';
import 'services/elevation_service.dart';
import 'services/elevation_cache_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final analytics = FirebaseAnalytics.instance;
  analytics.logEvent(name: 'user_open_app');
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '海拔查詢',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: const GradientBackground(child: MainScreen()),
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
