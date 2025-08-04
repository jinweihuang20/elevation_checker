import 'package:flutter/material.dart';
import '../models/timezone_data.dart';

class TimezoneService extends ChangeNotifier {
  TimezoneData _currentTimezone = TimezoneData.defaultTimezone;

  TimezoneData get currentTimezone => _currentTimezone;

  void setTimezone(TimezoneData timezone) {
    _currentTimezone = timezone;
    notifyListeners();
  }

  String formatDateTime(DateTime dateTime) {
    // 將 UTC 時間轉換為選定時區的時間
    final adjustedDateTime = dateTime.toUtc().add(_currentTimezone.offset);

    return '${_formatDate(adjustedDateTime)} ${_formatTime(adjustedDateTime)} '
        '${_currentTimezone.code}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  String getTimezoneOffset() {
    final hours = _currentTimezone.offset.inHours;
    final minutes = _currentTimezone.offset.inMinutes % 60;
    final sign = hours >= 0 ? '+' : '';
    return 'UTC$sign$hours:${minutes.toString().padLeft(2, '0')}';
  }
}
