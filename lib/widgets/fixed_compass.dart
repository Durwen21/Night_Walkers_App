import 'dart:math';
import 'package:flutter/material.dart';

class FixedCompass extends StatelessWidget {
  final double heading; // in degrees

  const FixedCompass({Key? key, required this.heading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Compass background and markings
          Center(
            child: Transform.rotate(
              // Rotate the compass background so North is always at the top
              angle: 0, // Compass rose itself does not rotate based on heading
              child: Stack(
                children: [
                  // Base circle
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                  ),
                  // North indicator
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'N',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // South indicator
                   Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'S',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // East indicator
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Text(
                        'E',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // West indicator
                   Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Text(
                        'W',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // Add tick marks if desired (more complex positioning)
                ],
              ),
            ),
          ),
          // Rotating needle/indicator pointing to current heading
          Center(
            child: Transform.rotate(
              // Rotate the needle based on the heading
              angle: (heading * pi / 180), // Convert degrees to radians
              child: Icon(
                Icons.navigation,
                color: Colors.blueAccent, // Color for the needle
                size: 40, // Size for the needle
              ),
            ),
          ),
        ],
      ),
    );
  }
} 