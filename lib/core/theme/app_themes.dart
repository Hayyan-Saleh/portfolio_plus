import 'package:flutter/material.dart';

const pDarkColor = Colors.white;
const sDarkColor = Color.fromARGB(255, 55, 79, 216);
const pLightColor = Colors.black;
const sLightColor = Colors.indigo;
final darkTheme = ThemeData(
  primarySwatch: Colors.indigo,
  colorScheme: const ColorScheme.dark(
      background: Color.fromARGB(255, 0, 14, 44),
      primary: pDarkColor,
      secondary: sDarkColor),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: pDarkColor),
);
final lightTheme = ThemeData(
  primarySwatch: Colors.indigo,
  colorScheme: const ColorScheme.dark(
      background: Color.fromARGB(242, 255, 255, 255),
      primary: pLightColor,
      secondary: sLightColor),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: pLightColor),
);
