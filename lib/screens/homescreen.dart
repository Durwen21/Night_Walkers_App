import 'package:flutter/material.dart';
import 'package:night_walkers_app/widgets/panic_button.dart';
import 'package:night_walkers_app/widgets/status_dashboard.dart';
import 'package:night_walkers_app/screens/contacts_screen.dart';
import 'package:night_walkers_app/screens/map_screen.dart';
import 'package:night_walkers_app/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    Column(
      children: [
        StatusDashboard(),
        Expanded(child: Center(child: PanicButton())),
      ],
    ),
    MapScreen(),
    ContactsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0
            ? const Text('Night Walkers App')
            : _selectedIndex == 1
                ? const Text('Map')
                : _selectedIndex == 2
                    ? const Text('Contacts')
                    : const Text('Settings'),
      ),
      body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.black,
          selectedItemColor: const Color.fromARGB(255, 10, 209, 106),
          unselectedItemColor: const Color.fromARGB(179, 0, 0, 0),
          selectedIconTheme: IconThemeData(size: 28),
          unselectedIconTheme: IconThemeData(size: 24),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.contact_emergency), label: 'Contacts'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ],
),
    );
  }
}
