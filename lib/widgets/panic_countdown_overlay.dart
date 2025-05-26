import 'package:flutter/material.dart';
import 'dart:async';

class PanicCountdownOverlay extends StatefulWidget {
  final VoidCallback onCountdownComplete;
  final VoidCallback onCancel;

  const PanicCountdownOverlay({
    super.key,
    required this.onCountdownComplete,
    required this.onCancel,
  });

  @override
  State<PanicCountdownOverlay> createState() => _PanicCountdownOverlayState();
}

class _PanicCountdownOverlayState extends State<PanicCountdownOverlay> {
  static const int _countdownSeconds = 5;
  int _currentCountdown = _countdownSeconds;
  Timer? _timer;
  double _sliderValue = 0.0; 

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCountdown == 1) {
        timer.cancel();
        widget.onCountdownComplete();
      } else {
        setState(() {
          _currentCountdown--;
        });
      }
    });
  }

  void _cancelCountdown() {
    _timer?.cancel();
    widget.onCancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Activating in $_currentCountdown...',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: _currentCountdown / _countdownSeconds,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                      ),
                    ),
                    Text(
                      '$_currentCountdown',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Slide to Cancel button placeholder - will refine this
                 Slider(
                    value: _sliderValue,
                    min: 0,
                    max: 1,
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                      });
                    },
                    onChangeEnd: (value) {
                      if (value > 0.9) { // Threshold for successful slide
                        _cancelCountdown();
                      } else {
                        // Snap back if not slid enough
                        setState(() {
                          _sliderValue = 0.0;
                        });
                      }
                    },
                  ),
                 const Text(
                    'Slide to Cancel',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 