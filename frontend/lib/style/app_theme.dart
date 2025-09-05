import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(Color seedColor) => ThemeData(
    fontFamily: 'Poppins',
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      surface: Colors.grey.shade100,
      surfaceContainer: Colors.black,
      secondary: Colors.grey.shade700,
      onSurface: Colors.grey.shade300,
      onSurfaceVariant: Colors.grey.shade900,
      brightness: Brightness.light,
      seedColor: seedColor,
      // seedColor: Color(0xFF0026FF),
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ),
  );
  static ThemeData darkTheme(Color seedColor) => ThemeData(
    fontFamily: 'Poppins',
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      secondary: Colors.grey.shade500,
      surface: Colors.black,
      surfaceContainer: Colors.grey.shade900,
      onSurface: Colors.grey.shade800,
      onSurfaceVariant: Colors.grey.shade100,
      brightness: Brightness.dark,
      seedColor: seedColor,
      // seedColor: Color(0xFF0026FF),
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ),
  );
}

extension ThemeColors on BuildContext {
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get onPrimaryColor => Theme.of(this).colorScheme.onPrimary;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get onSecondaryColor => Theme.of(this).colorScheme.onSecondary;
  Color get tertiaryColor => Theme.of(this).colorScheme.tertiary;
  Color get onTertiaryColor => Theme.of(this).colorScheme.onTertiary;
  Color get backgroundColor => Theme.of(this).colorScheme.surface;
  Color get onBackground => Theme.of(this).colorScheme.onSurface;
  Color get surfaceContainer => Theme.of(this).colorScheme.surfaceContainer;
  Color get onSurfaceVariant => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get outlineColor => Theme.of(this).colorScheme.outline;
  // Color get errorColor => Theme.of(this).colorScheme.error;
}
