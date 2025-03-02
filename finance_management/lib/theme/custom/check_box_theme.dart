import 'package:flutter/material.dart';

class TCheckBoxTheme {
  static CheckboxThemeData lightCheckBoxTheme = CheckboxThemeData(
    checkColor: WidgetStateProperty.all(Colors.white),
    fillColor: WidgetStateProperty.all(Colors.blue),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  );

  static CheckboxThemeData darkCheckBoxTheme = CheckboxThemeData(
    checkColor: WidgetStateProperty.all(Colors.black),
    fillColor: WidgetStateProperty.all(Colors.blueGrey),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  );
}
