import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
  
class AnalyticsConsentSwitch extends StatefulWidget {
  const AnalyticsConsentSwitch({super.key});

  @override
  State<AnalyticsConsentSwitch> createState() => _AnalyticsConsentSwitchState();
}

class _AnalyticsConsentSwitchState extends State<AnalyticsConsentSwitch> {
  static const String _consentKey = 'analytics_consent';
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadConsentStatus();
  }

  Future<void> _loadConsentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEnabled = prefs.getBool(_consentKey) ?? false;
    });
  }

  Future<void> _updateConsentStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, value);

    if (!FirebaseService.instance.isAnalyticsEnabled) {
      return;
    }

    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(value);

    if (value) {
      await FirebaseAnalytics.instance.logEvent(
        name: 'analytics_consent_changed',
        parameters: {'status': 'enabled'},
      );
    }

    setState(() {
      _isEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('允許數據收集'),
      subtitle: const Text(
        '匿名收集使用數據以改進應用程序。這包括功能使用情況、性能數據和錯誤報告。',
        style: TextStyle(fontSize: 12),
      ),
      value: _isEnabled,
      onChanged: _updateConsentStatus,
    );
  }
}
