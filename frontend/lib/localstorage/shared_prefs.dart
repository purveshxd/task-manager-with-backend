import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _themeKey = 'isDarkTheme';

  /// Save theme mode (true = Dark, false = Light)
  static Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  /// Get theme mode (default = false = Light)
  static Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}
