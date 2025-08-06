import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/analytics_consent_switch.dart';
import '../services/timezone_service.dart';
import '../models/timezone_data.dart';
import '../services/elevation_cache_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showTimezonePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇時區'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: TimezoneData.commonTimezones.length,
            itemBuilder: (context, index) {
              final timezone = TimezoneData.commonTimezones[index];
              final timezoneService = context.read<TimezoneService>();
              final isSelected =
                  timezone.code == timezoneService.currentTimezone.code;

              return ListTile(
                title: Text(timezone.name),
                subtitle: Text('${timezone.code} '
                    '(UTC${timezone.offset.inHours >= 0 ? '+' : ''}'
                    '${timezone.offset.inHours}:00)'),
                trailing: isSelected ? const Icon(Icons.check) : null,
                selected: isSelected,
                onTap: () {
                  context.read<TimezoneService>().setTimezone(timezone);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        final result = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );

        if (!result) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('無法開啟連結：瀏覽器啟動失敗'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('無法開啟連結：${url.toString()}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('開啟連結時發生錯誤：${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _showClearCacheConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除快取資料'),
        content: const Text('確定要清除所有已儲存的海拔資料嗎？\n這個動作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('清除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final cacheService = context.read<ElevationCacheService>();
      await cacheService.clearAll();
      FirebaseAnalytics.instance.logEvent(name: 'user_clear_cache');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已清除所有快取資料'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timezoneService = context.watch<TimezoneService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 231, 231, 231),
      body: ListView(
        children: [
          const _SettingSection(
            title: '一般設定',
            children: [
              _SettingTile(
                icon: Icons.language,
                title: '語言',
                subtitle: '繁體中文',
                enabled: false,
              ),
            ],
          ),
          _SettingSection(
            title: '時區設定',
            children: [
              _SettingTile(
                icon: Icons.schedule,
                title: '時區',
                subtitle: '${timezoneService.currentTimezone.name} '
                    '(${timezoneService.getTimezoneOffset()})',
                onTap: () => _showTimezonePicker(context),
              ),
            ],
          ),
          const _SettingSection(
            title: '隱私設定',
            children: [
              AnalyticsConsentSwitch(),
            ],
          ),
          _SettingSection(
            title: '資料設定',
            children: [
              _SettingTile(
                icon: Icons.storage,
                title: '清除快取資料',
                subtitle: '清除所有已儲存的海拔資料',
                showDivider: false,
                onTap: () => _showClearCacheConfirmation(context),
              ),
            ],
          ),
          _SettingSection(
            title: '關於',
            children: [
              const _SettingTile(
                icon: Icons.info_outline,
                title: '版本',
                subtitle: '1.0.0',
                enabled: false,
              ),
              const _SettingTile(
                icon: Icons.description_outlined,
                title: '開放原始碼授權',
              ),
              _SettingTile(
                icon: Icons.person_outline,
                title: '開發者網站',
                subtitle: 'Jinwei Huang',
                onTap: () =>
                    _launchURL(context, 'https://github.com/jinwei-huang'),
                enabled: false,
                showDivider: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.7),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool enabled;
  final bool showDivider;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.enabled = true,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
          ),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          trailing: enabled
              ? const Icon(Icons.chevron_right, color: Colors.black26)
              : null,
          enabled: enabled,
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1, indent: 56),
      ],
    );
  }
}
