import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';
import 'package:night_walkers_app/services/flashlight_service.dart';
import 'package:night_walkers_app/services/sound_service.dart';
import 'package:night_walkers_app/services/sms_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'dart:convert';

class PanicButton extends StatefulWidget {
  const PanicButton({super.key});

  @override
  State<PanicButton> createState() => _PanicButtonState();
}

class _PanicButtonState extends State<PanicButton> {
  bool _isBlinking = false;
  bool _isRed = true;
  Timer? _blinkTimer;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  _snackBarController;

  final Color neonRed = Colors.redAccent.shade100;
  final Color dimRed = Colors.redAccent.shade100.withAlpha(51);

  final Telephony telephony = Telephony.instance;

  void _startBlinking() async {
    setState(() {
      _isBlinking = true;
      _isRed = true;
    });

    await FlashlightService.turnOn();
    SoundService.playAlarm();

    _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Long press the button to stop the alarm!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        duration: const Duration(days: 1),
      ),
    );

    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 167), (
      timer,
    ) async {
      setState(() {
        _isRed = !_isRed;
      });
      await FlashlightService.toggle(_isRed);
    });

    _vibrate();

    final position = await _getCurrentLocation();
    if (position != null) {
      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');

      // Send SMS with location to emergency contacts
      try {
        await SmsService.sendLocationSms(position.latitude, position.longitude);
        // Also send a generic emergency SMS to all contacts
        await _sendEmergencySmsToAllContacts(
          'This is an emergency! Please help me immediately! My location: https://maps.google.com/?q=${position.latitude},${position.longitude}',
        );

        // Show success notification, but don't dismiss the emergency snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency SMS sent to contacts'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
          ),
        );
      } catch (e) {
        print('Failed to send SMS: $e');
      }
    }
  }

  void _stopBlinking() {
    _blinkTimer?.cancel();
    setState(() {
      _isBlinking = false;
      _isRed = true;
      Vibration.cancel();
    });

    FlashlightService.turnOff();
    SoundService.stopAlarm();

    _snackBarController?.close();
    _snackBarController = null;
  }

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 500, 500, 500, 500, 500], repeat: 0);
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission permanently denied.'),
        ),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _sendEmergencySmsToAllContacts(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getString('emergency_contacts');
    if (contactsJson == null) return;
    final contacts = (jsonDecode(contactsJson) as List)
        .map((item) => {
              'name': item['name'].toString(),
              'number': item['number'].toString(),
            })
        .toList();
    final bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted == true) {
      for (var contact in contacts) {
        final number = contact['number'];
        if (number != null) {
          await telephony.sendSms(
            to: number,
            message: message,
          );
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Emergency SMS sent to all contacts")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("SMS permission denied")),
        );
      }
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _snackBarController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color activeNeon = Colors.redAccent.shade100;
    final Color currentColor =
        _isBlinking
            ? (_isRed ? activeNeon : const Color.fromARGB(255, 255, 0, 0))
            : Colors.white;

    final List<Shadow> glow =
        _isBlinking && _isRed
            ? [
              const Shadow(
                color: Color.fromARGB(255, 215, 25, 25),
                blurRadius: 30,
              ),
            ]
            : [];

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow:
              _isBlinking && _isRed
                  ? [
                    BoxShadow(
                      color: Colors.redAccent.withAlpha(153),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ]
                  : [],
        ),
        child: GestureDetector(
          onLongPress: _isBlinking ? _stopBlinking : null,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
              shape: WidgetStateProperty.all(const CircleBorder()),
              padding: WidgetStateProperty.all(const EdgeInsets.all(60)),
            ),
            onPressed: _isBlinking ? null : _startBlinking,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.warning,
                    key: ValueKey<String>(
                      '${_isBlinking}_${_isRed.toString()}',
                    ),
                    color: currentColor,
                    size: 90,
                    shadows: glow,
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    color: currentColor,
                    fontSize: 90,
                    fontWeight: FontWeight.bold,
                    shadows: glow,
                  ),
                  child: const Text('SOS'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
