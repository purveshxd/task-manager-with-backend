import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _themeKey = 'themeModeSaved';
  static const String _accentColor = 'accentColor';

  /// Save theme mode (true = Dark, false = Light)
  static Future<bool> setTheme(ThemeMode currentTheme) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(_themeKey, currentTheme.index);
  }

  /// Get theme mode (default = false = Light)
  static Future<int> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_themeKey) ??
        ThemeMode.values.indexOf(ThemeMode.system);
  }

  static Future<bool> setAccentColor(int accentColorIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(_accentColor, accentColorIndex);
  }

  static Future<int> getAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_accentColor) ?? 0;
  }
}
