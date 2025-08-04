import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../widgets/elevation_display.dart';
import '../widgets/location_info.dart';
import '../services/location_service.dart';
import '../services/elevation_service.dart';
import '../models/location_data.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationData? _locationData;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        // 先更新位置信息
        final locationData = LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
        );

        setState(() {
          _locationData = locationData;
        });

        // 獲取海拔數據
        final elevationResult =
            await context.read<ElevationService>().getElevation(
                  latitude: position.latitude,
                  longitude: position.longitude,
                );

        if (elevationResult != null) {
          final (elevation, source) = elevationResult;
          if (elevation != null) {
            setState(() {
              _locationData = locationData.copyWith(
                elevation: elevation,
                dataSource: source,
              );
              _errorMessage = null;
            });
          } else {
            setState(() {
              _errorMessage = '無法獲取海拔數據';
            });
          }
        } else {
          setState(() {
            _errorMessage = '無法獲取海拔數據';
          });
        }
      } else {
        setState(() {
          _errorMessage = '無法獲取位置信息，請確認已授予權限並開啟位置服務';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '獲取位置時發生錯誤';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('海拔查詢'),
        centerTitle: true,
        backgroundColor:
            const Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _getCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevationDisplay(
                locationData: _locationData,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
              LocationInfo(
                locationData: _locationData,
                errorMessage: _errorMessage,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
