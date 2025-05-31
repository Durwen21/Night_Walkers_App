import 'package:flutter/material.dart';

class UserLocationMarker extends StatelessWidget {
  final double heading;

  const UserLocationMarker({super.key, required this.heading});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: (heading * (3.14159 / 180)), // Converts degrees to radians
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Arrow indicating direction
          Icon(
            Icons.navigation,
            color: Colors.blueAccent,
            size: 30,
          ),
          // Blue circle for location with "ME" text
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withOpacity(0.5),
            ),
            child: Center(
              child: Text(
                'ME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 