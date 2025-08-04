import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timezone_data.dart';
import '../services/timezone_service.dart';

class TimezoneSelector extends StatelessWidget {
  const TimezoneSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.schedule),
      onPressed: () => _showTimezonePicker(context),
    );
  }

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
}
