import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_data.dart';
import '../services/timezone_service.dart';

class LocationInfo extends StatelessWidget {
  final LocationData? locationData;
  final String? errorMessage;

  const LocationInfo({
    super.key,
    this.locationData,
    this.errorMessage,
  });

  String _formatCoordinates(double value, {bool isLatitude = true}) {
    final direction =
        isLatitude ? (value >= 0 ? 'N' : 'S') : (value >= 0 ? 'E' : 'W');
    return '${value.abs().toStringAsFixed(6)}°$direction';
  }

  @override
  Widget build(BuildContext context) {
    final timezoneService = context.watch<TimezoneService>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.location_on,
            label: '緯度',
            value: locationData != null
                ? _formatCoordinates(locationData!.latitude, isLatitude: true)
                : '尚未取得',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.location_on,
            label: '經度',
            value: locationData != null
                ? _formatCoordinates(locationData!.longitude, isLatitude: false)
                : '尚未取得',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.access_time,
            label: '更新時間',
            value: locationData != null
                ? timezoneService.formatDateTime(locationData!.timestamp)
                : '--',
          ),
          if (locationData != null) ...[
            const SizedBox(height: 4),
            Text(
              '時區: ${timezoneService.currentTimezone.name} '
              '(${timezoneService.getTimezoneOffset()})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}
