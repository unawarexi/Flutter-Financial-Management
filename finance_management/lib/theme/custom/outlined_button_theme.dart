import 'package:flutter/material.dart';

class TOutlineButtonTheme {
  static OutlinedButtonThemeData lightOutlinedButtonTheme =
      OutlinedButtonThemeData(
    style: ButtonStyle(
      side: WidgetStateProperty.all(const BorderSide(color: Colors.blue)),
      foregroundColor: WidgetStateProperty.all(Colors.blue),
      padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
    ),
  );

  static OutlinedButtonThemeData darkOutlinedButtonTheme =
      OutlinedButtonThemeData(
    style: ButtonStyle(
      side: WidgetStateProperty.all(const BorderSide(color: Colors.blueGrey)),
      foregroundColor: WidgetStateProperty.all(Colors.blueGrey),
      padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
    ),
  );
}
