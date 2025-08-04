import 'package:flutter/material.dart';

class _ElevationColorRange {
  final double max;
  final Color color;
  final String label;

  const _ElevationColorRange({
    required this.max,
    required this.color,
    required this.label,
  });
}

class ElevationColorService {
  static const List<_ElevationColorRange> _colorRanges = [
    _ElevationColorRange(
      max: -1,
      color: Color(0xFF90CAF9), // 淺藍色 - 深海
      label: '深海',
    ),
    _ElevationColorRange(
      max: 200,
      color: Color(0xFFBBDEFB), // 更淺的藍色 - 海岸平原
      label: '海岸平原',
    ),
    _ElevationColorRange(
      max: 500,
      color: Color(0xFFC8E6C9), // 淺綠色 - 平地
      label: '平地',
    ),
    _ElevationColorRange(
      max: 1000,
      color: Color(0xFF81C784), // 中等綠色 - 丘陵
      label: '丘陵',
    ),
    _ElevationColorRange(
      max: 2000,
      color: Color.fromARGB(255, 167, 144, 111), // 淺橘色 - 中高山
      label: '中高山',
    ),
    _ElevationColorRange(
      max: 3000,
      color: Color.fromARGB(255, 247, 200, 130), // 中等橘色 - 高山
      label: '高山',
    ),
    _ElevationColorRange(
      max: double.infinity,
      color: Color.fromARGB(255, 255, 255, 255), // 淺棕色 - 極高山
      label: '極高山',
    ),
  ];

  static (Color color, String label) getColorAndLabel(double elevation) {
    for (final range in _colorRanges) {
      if (elevation <= range.max) {
        return (range.color, range.label);
      }
    }
    return (_colorRanges.last.color, _colorRanges.last.label);
  }

  static Color getBackgroundColor(double elevation) {
    final (color, _) = getColorAndLabel(elevation);
    return color.withOpacity(0.2);
  }

  static Color getTextColor(double elevation) {
    final (color, _) = getColorAndLabel(elevation);
    final luminance = color.computeLuminance();
    return luminance > 0.5
        ? Colors.black87.withOpacity(0.8)
        : Colors.white.withOpacity(0.9);
  }

  static Color getBorderColor(double elevation) {
    final (color, _) = getColorAndLabel(elevation);
    return color.withOpacity(0.3);
  }
}
