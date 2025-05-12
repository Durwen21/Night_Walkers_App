import 'package:flutter/material.dart';

class PanicButton extends StatelessWidget {
  const PanicButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(), backgroundColor: Colors.red,
        padding: const EdgeInsets.all(60), 
      ),
      onPressed: () {
        // Trigger SOS functionality
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning,
            color: Colors.white,
            size: 90,
          ),
          const SizedBox(height: 10),
          const Text(
            'SOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 90,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}