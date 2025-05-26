import 'package:flutter/material.dart';
import 'package:night_walkers_app/screens/contacts_screen.dart';
import 'package:night_walkers_app/screens/settings_screen.dart';
import 'package:night_walkers_app/widgets/panic_button.dart';
import 'package:night_walkers_app/widgets/status_dashboard.dart';
import 'package:night_walkers_app/screens/map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:night_walkers_app/services/flashlight_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Settings state
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _flashlightEnabled = true;
  bool _autoLocationShare = true;
  bool _quickActivation = false;
  double _flashlightBlinkSpeed = 167.0;
  String _customMessage = 'This is an emergency! Please help me immediately!';
  String _selectedRingtone = 'Default Alarm';
  bool _confirmBeforeActivation = true;
  bool _flashlightOn = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _flashlightEnabled = prefs.getBool('flashlight_enabled') ?? true;
      _autoLocationShare = prefs.getBool('auto_location_share') ?? true;
      _quickActivation = prefs.getBool('quick_activation') ?? false;
      _flashlightBlinkSpeed = prefs.getDouble('flashlight_blink_speed') ?? 167.0;
      _customMessage = prefs.getString('custom_message') ?? 'This is an emergency! Please help me immediately!';
      _selectedRingtone = prefs.getString('selected_ringtone') ?? 'Default Alarm';
      _confirmBeforeActivation = prefs.getBool('confirm_before_activation') ?? true;
    });
  }

  List<Widget> get _screens => <Widget>[
    Column(
      children: [
        StatusDashboard(),
        Expanded(
          child: Center(
            child: PanicButton(
              soundEnabled: _soundEnabled,
              vibrationEnabled: _vibrationEnabled,
              flashlightEnabled: _flashlightEnabled,
              flashlightBlinkSpeed: _flashlightBlinkSpeed,
              selectedRingtone: _selectedRingtone,
              autoLocationShare: _autoLocationShare,
              customMessage: _customMessage,
              quickActivation: _quickActivation,
              confirmBeforeActivation: _confirmBeforeActivation,
            ),
          ),
        ),
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
    
    if (index == 0) {
      _loadSettings();
    }
  }

  Future<void> _toggleFlashlight() async {
    if (_flashlightOn) {
      await FlashlightService.turnOff();
    } else {
      await FlashlightService.turnOn();
    }
    setState(() {
      _flashlightOn = !_flashlightOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color unselectedColor = Colors.black;
    const Color selectedColor = Color(0xFFB39DDB); // Light purple

    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0 ? const Text('Night Walkers App') : null,
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 70.0), // just above the menu
              child: FloatingActionButton(
                onPressed: _toggleFlashlight,
                backgroundColor: _flashlightOn ? Colors.yellow : Colors.grey[800],
                tooltip: _flashlightOn ? 'Turn Flashlight Off' : 'Turn Flashlight On',
                child: Icon(
                  _flashlightOn ? Icons.flashlight_on : Icons.flashlight_off,
                  color: _flashlightOn ? Colors.black : Colors.white,
                ),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.maps_home_work_outlined), label: 'Map'),BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings_applications), label: 'settings'),
        ],
      ),
    );
  }
}
