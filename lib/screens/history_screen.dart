import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:math' show log;
import 'dart:async';
import '../services/elevation_cache_service.dart';
import '../models/elevation_cache.dart';
import '../widgets/app_bar_icon.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  List<CachedElevation> _homeScreenElevations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      setState(() => _isLoading = true);

      // 等待地圖初始化完成
      final completer = Completer<void>();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      await completer.future;
      await _loadHomeScreenElevations();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadHomeScreenElevations() async {
    final elevationCacheService = context.read<ElevationCacheService>();
    final homeScreenElevations =
        elevationCacheService.getHomeScreenElevations();

    if (!mounted) return;

    setState(() {
      _homeScreenElevations = homeScreenElevations;
      _updateMarkers();
    });

    if (homeScreenElevations.isNotEmpty) {
      _centerMapOnMarkers();
    }
  }

  void _updateMarkers() {
    _markers = _homeScreenElevations.map((elevation) {
      return Marker(
        point: LatLng(elevation.latitude, elevation.longitude),
        width: 200,
        height: 105,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _mapController.move(
                LatLng(elevation.latitude, elevation.longitude),
                15,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 30,
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${elevation.elevation.toStringAsFixed(1)}m',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${elevation.latitude.abs().toStringAsFixed(4)}°${elevation.latitude >= 0 ? 'N' : 'S'}\n'
                        '${elevation.longitude.abs().toStringAsFixed(4)}°${elevation.longitude >= 0 ? 'E' : 'W'}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        elevation.timestamp.toLocal().toString().split('.')[0],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _centerMapOnMarkers() {
    if (_markers.isEmpty) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final marker in _markers) {
      final lat = marker.point.latitude;
      final lng = marker.point.longitude;
      minLat = minLat < lat ? minLat : lat;
      maxLat = maxLat > lat ? maxLat : lat;
      minLng = minLng < lng ? minLng : lng;
      maxLng = maxLng > lng ? maxLng : lng;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    final latSpan = maxLat - minLat;
    final lngSpan = maxLng - minLng;
    final zoom = _calculateZoomLevel(latSpan, lngSpan);

    _mapController.move(LatLng(centerLat, centerLng), zoom);
  }

  double _calculateZoomLevel(double latSpan, double lngSpan) {
    const minZoom = 3.0;
    const maxZoom = 18.0;
    const padding = 0.5; // 增加一些邊距

    final maxSpan = latSpan > lngSpan ? latSpan : lngSpan;
    final zoom = 360 / (maxSpan * (1 + padding));
    final zoomLevel = log(zoom) / log(2);

    return (zoomLevel.clamp(minZoom, maxZoom));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('歷史海拔查詢'),
        leading: const AppBarIcon(size: 28),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHomeScreenElevations,
            tooltip: '重新載入',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 4,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(23.5, 121.0), // 台灣中心點
                    initialZoom: 7,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.elevation_checker',
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
              ),
              if (!_isLoading && _homeScreenElevations.isNotEmpty)
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, -2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.emoji_events,
                                  color: Colors.amber),
                              const SizedBox(width: 8),
                              const Text(
                                '海拔排行榜',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '共 ${_homeScreenElevations.length} 筆紀錄',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: _homeScreenElevations.length,
                            itemBuilder: (context, index) {
                              final sortedElevations =
                                  List<CachedElevation>.from(
                                      _homeScreenElevations)
                                    ..sort((a, b) =>
                                        b.elevation.compareTo(a.elevation));
                              final elevation = sortedElevations[index];
                              final rank = index + 1;
                              final isTop3 = rank <= 3;

                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                color: isTop3
                                    ? Colors.amber.withOpacity(0.1)
                                    : null,
                                child: InkWell(
                                  onTap: () {
                                    _mapController.move(
                                      LatLng(elevation.latitude,
                                          elevation.longitude),
                                      15,
                                    );
                                  },
                                  child: Container(
                                    width: 130,
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: isTop3
                                                    ? Colors.amber
                                                    : Colors.grey.shade200,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$rank',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: isTop3
                                                        ? Colors.white
                                                        : Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${elevation.elevation.toStringAsFixed(1)}m',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${elevation.latitude.abs().toStringAsFixed(4)}°${elevation.latitude >= 0 ? 'N' : 'S'}\n'
                                          '${elevation.longitude.abs().toStringAsFixed(4)}°${elevation.longitude >= 0 ? 'E' : 'W'}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_homeScreenElevations.isEmpty && !_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      '尚無歷史紀錄',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
