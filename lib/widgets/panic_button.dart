import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';
import 'package:night_walkers_app/services/flashlight_service.dart';
import 'package:night_walkers_app/services/sound_service.dart';

class PanicButton extends StatefulWidget {
  const PanicButton({super.key});

  @override
  State<PanicButton> createState() => _PanicButtonState();
}

class _PanicButtonState extends State<PanicButton> {
  bool _isBlinking = false;
  bool _isRed = true;
  Timer? _blinkTimer;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _snackBarController;

  final Color neonRed = Colors.redAccent.shade100;
  final Color dimRed = Colors.redAccent.shade100.withAlpha(51);

  void _startBlinking() async {
    setState(() {
      _isBlinking = true;
      _isRed = true;
    });

    // Turn on flashlight when alarm starts
    await FlashlightService.turnOn();
    SoundService.playAlarm(); // Start alarm sound

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        duration: const Duration(days: 1), // para yawan sa HAAHHAHA
      ),
    );

    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 167), (timer) async {
      setState(() {
        _isRed = !_isRed;
      });
      // Blink the flashlight in sync with the button
      await FlashlightService.toggle(_isRed);
    });

    _vibrate();
  }

  void _stopBlinking() {
    _blinkTimer?.cancel();
    setState(() {
      _isBlinking = false;
      _isRed = true;
      Vibration.cancel();
    });

    // Ensure flashlight is off when stopping
    FlashlightService.turnOff();
    SoundService.stopAlarm(); // Stop alarm sound

    _snackBarController?.close();
    _snackBarController = null;
  }

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 500, 500, 500, 500, 500], repeat: 0);
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
    final Color currentColor = _isBlinking
        ? (_isRed ? activeNeon : const Color.fromARGB(255, 255, 0, 0))
        : Colors.white;

    final List<Shadow> glow = _isBlinking && _isRed
        ? [
            Shadow(
              color: const Color.fromARGB(255, 215, 25, 25),
              blurRadius: 30,
            )
          ]
        : [];

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: _isBlinking && _isRed
              ? [
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 153),
                    blurRadius: 40,
                    spreadRadius: 10,
                  )
                ]
              : [],
        ),
        child: GestureDetector(
          onLongPress: _isBlinking ? _stopBlinking : null,
          child: ElevatedButton(
            style: ButtonStyle(
              // ignore: deprecated_member_use
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  // Always return red, even when disabled
                  return Colors.red;
                },
              ),
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
                        '${_isBlinking}_${_isRed.toString()}'),
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
