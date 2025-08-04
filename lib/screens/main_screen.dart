import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/elevation_service.dart';
import 'home_screen.dart';
import 'query_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screens = [
      const HomeScreen(),
      QueryScreen(elevationService: context.read<ElevationService>()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Color.fromARGB(255, 10, 61, 83),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(color: Colors.white),
        ),
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home, color: Color.fromARGB(255, 126, 126, 126)),
            selectedIcon: Icon(Icons.home_outlined),
            label: '首頁',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_sharp,
                color: Color.fromARGB(255, 126, 126, 126)),
            selectedIcon: Icon(Icons.map_rounded),
            label: '查詢',
          ),
        ],
      ),
    );
  }
}
