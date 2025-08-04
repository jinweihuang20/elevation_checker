class TimezoneData {
  final String name;
  final String code;
  final Duration offset;

  const TimezoneData({
    required this.name,
    required this.code,
    required this.offset,
  });

  // 預設時區列表
  static const List<TimezoneData> commonTimezones = [
    TimezoneData(
      name: '中原標準時間',
      code: 'CST',
      offset: Duration(hours: 8),
    ),
    TimezoneData(
      name: '世界標準時間',
      code: 'UTC',
      offset: Duration(hours: 0),
    ),
    TimezoneData(
      name: '東京時間',
      code: 'JST',
      offset: Duration(hours: 9),
    ),
    TimezoneData(
      name: '太平洋時間',
      code: 'PST',
      offset: Duration(hours: -8),
    ),
  ];

  // 獲取預設時區（中原標準時間）
  static const TimezoneData defaultTimezone = TimezoneData(
    name: '中原標準時間',
    code: 'CST',
    offset: Duration(hours: 8),
  );
}
