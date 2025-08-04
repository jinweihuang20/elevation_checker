import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/elevation_service.dart';
import 'settings_screen.dart';

class QueryScreen extends StatefulWidget {
  final ElevationService elevationService;

  const QueryScreen({
    super.key,
    required this.elevationService,
  });

  @override
  State<QueryScreen> createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  double? _elevation;
  bool _isLoadingElevation = false;

  // 驗證緯度範圍
  bool isValidLatitude(double lat) => lat >= -90 && lat <= 90;

  // 驗證經度範圍
  bool isValidLongitude(double lng) => lng >= -180 && lng <= 180;

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _updateSelectedLocation(LatLng location) async {
    if (!isValidLatitude(location.latitude) ||
        !isValidLongitude(location.longitude)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('無效的經緯度範圍'),
          ),
        );
      }
      return;
    }

    setState(() {
      _selectedLocation = location;
      _latController.text = location.latitude.toStringAsFixed(6);
      _lngController.text = location.longitude.toStringAsFixed(6);
      _isLoadingElevation = true;
      _elevation = null;
    });

    try {
      final result = await widget.elevationService.getElevation(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      if (mounted) {
        setState(() {
          _isLoadingElevation = false;
          _elevation = result?.$1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingElevation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('無法獲取海拔資料'),
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // 檢查位置權限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // 獲取當前位置
      setState(() => _isLoadingElevation = true);
      final position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);

      // 更新地圖位置
      _mapController.move(location, 15);

      // 更新位置並查詢海拔
      await _updateSelectedLocation(location);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('無法獲取當前位置')),
        );
      }
    }
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('海拔查詢'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.my_location),
            tooltip: '使用當前位置',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          )
        ],
      ),
      backgroundColor: Color.fromARGB(255, 53, 53, 53),
      body: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latController,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                        decoration: const InputDecoration(
                          labelText: '緯度',
                          hintText: '請輸入緯度',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 110, 110, 110),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _lngController,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                        decoration: const InputDecoration(
                          labelText: '經度',
                          hintText: '請輸入經度',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 110, 110, 110),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final lat = double.tryParse(_latController.text);
                        final lng = double.tryParse(_lngController.text);
                        if (lat != null && lng != null) {
                          if (!isValidLatitude(lat) || !isValidLongitude(lng)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('請輸入有效的經緯度範圍（緯度：-90~90，經度：-180~180）'),
                              ),
                            );
                            return;
                          }
                          final location = LatLng(lat, lng);
                          _mapController.move(location, 15);
                          _updateSelectedLocation(location);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('請輸入有效的數字格式'),
                            ),
                          );
                        }
                      },
                      child: const Text('查詢'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _isLoadingElevation
                    ? const CircularProgressIndicator()
                    : Text(
                        _elevation == null
                            ? '發生錯誤，請重試'
                            : '海拔：${_elevation!.toStringAsFixed(1)} 公尺',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
              ),
            ],
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(23.973875, 120.982024), // 台灣中心點
                initialZoom: 7,
                onTap: (tapPosition, point) => _updateSelectedLocation(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.elevation_checker',
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40,
                        height: 40,
                        point: _selectedLocation!,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
