import 'package:flutter/material.dart';

class CustomNavBarShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    const notchRadius = 35.0; // Radius of the circular notch

    // Start from the left
    path.lineTo(centerX - notchRadius, 0);

    // Create a semicircular notch
    path.arcToPoint(
      Offset(centerX + notchRadius, 0),
      radius: const Radius.circular(35),
      clockwise: false,
    );

    // Continue to the end of the bar
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
