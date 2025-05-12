import 'package:flutter/material.dart';

class PanicButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Trigger SOS functionality
      },
      child: const Text('SOS'),
    );
  }
}