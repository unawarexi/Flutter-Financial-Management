import 'package:flutter/material.dart';

class TElevatedButtonTheme {
  static ElevatedButtonThemeData lightElevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.blue),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
    ),
  );

  static ElevatedButtonThemeData darkElevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.blueGrey),
      foregroundColor: WidgetStateProperty.all(Colors.black),
      padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
    ),
  );
}
