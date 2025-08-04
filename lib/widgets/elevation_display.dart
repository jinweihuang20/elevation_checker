import 'package:flutter/material.dart';
import '../models/location_data.dart';
import '../services/elevation_color_service.dart';

class ElevationDisplay extends StatelessWidget {
  final LocationData? locationData;
  final bool isLoading;

  const ElevationDisplay({
    super.key,
    this.locationData,
    this.isLoading = false,
  });

  Widget _buildDataSourceChip(BuildContext context, DataSource source) {
    final Map<DataSource, (Color, String, IconData)> sourceInfo = {
      DataSource.api: (
        Colors.blue.shade50,
        'API 數據',
        Icons.cloud_outlined,
      ),
      DataSource.cache: (
        Colors.green.shade50,
        '快取數據',
        Icons.storage_outlined,
      ),
      DataSource.none: (
        Colors.grey.shade50,
        '無數據',
        Icons.help_outline,
      ),
    };

    final (backgroundColor, label, icon) = sourceInfo[source]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.7),
        border: Border.all(
          color: backgroundColor.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildElevationLabel(BuildContext context, double elevation) {
    final (_, label) = ElevationColorService.getColorAndLabel(elevation);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final elevation = locationData?.elevation;
    final backgroundColor = elevation != null
        ? ElevationColorService.getBackgroundColor(elevation)
        : Theme.of(context).colorScheme.surface.withOpacity(0.7);
    final textColor = elevation != null
        ? ElevationColorService.getTextColor(elevation)
        : Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: elevation != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ElevationColorService.getColorAndLabel(elevation)
                      .$1
                      .withOpacity(0.3),
                  ElevationColorService.getColorAndLabel(elevation)
                      .$1
                      .withOpacity(0.1),
                ],
              )
            : null,
        color: elevation == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(16),
        border: elevation != null
            ? Border.all(
                color: ElevationColorService.getBorderColor(elevation),
                width: 1.5,
              )
            : Border.all(
                color: Colors.black12,
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '當前海拔',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (!isLoading && locationData?.elevation != null)
                _buildDataSourceChip(context, locationData!.dataSource),
            ],
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const CircularProgressIndicator()
          else
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        locationData?.elevation?.toStringAsFixed(1) ?? '--',
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 5,
                                ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '公尺',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: textColor.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
                if (locationData?.elevation != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '約 ${(locationData!.elevation! * 3.28084).toStringAsFixed(1)} 英尺',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor.withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildElevationLabel(context, locationData!.elevation!),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
