import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';

class AnalyticsConsentDialog extends StatelessWidget {
  static const String _firstLaunchKey = 'first_launch';

  const AnalyticsConsentDialog({super.key});

  static Future<void> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = !prefs.containsKey(_firstLaunchKey);

    if (isFirstLaunch && context.mounted) {
      await prefs.setBool(_firstLaunchKey, false);
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AnalyticsConsentDialog(),
        );
      }
    }
  }

  Future<void> _handleConsent(BuildContext context, bool consent) async {
    await FirebaseService.instance.setAnalyticsEnabled(consent);

    if (consent) {
      await FirebaseService.instance.logEvent(
        name: 'analytics_consent_changed',
        parameters: {'status': 'enabled', 'source': 'first_launch_dialog'},
      );
    }

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('隱私設置'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '為了提供更好的服務體驗，我們希望收集使用數據來改進應用程序。',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('我們會收集：', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• 功能使用情況'),
            Text('• 性能數據'),
            Text('• 錯誤報告'),
            SizedBox(height: 16),
            Text(
              '所有數據都是匿名的，不會包含任何個人識別信息。',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '您可以隨時在設置中更改此選項。',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _handleConsent(context, false),
          child: const Text('不同意'),
        ),
        FilledButton(
          onPressed: () => _handleConsent(context, true),
          child: const Text('同意'),
        ),
      ],
    );
  }
}
