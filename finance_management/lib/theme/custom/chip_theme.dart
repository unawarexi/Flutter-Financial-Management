import 'package:flutter/material.dart';

class TChipTheme {
  static ChipThemeData lightChipTheme = ChipThemeData(
    backgroundColor: Colors.grey[300],
    labelStyle: const TextStyle(color: Colors.black),
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    backgroundColor: Colors.grey[700],
    labelStyle: const TextStyle(color: Colors.white),
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  );
}
