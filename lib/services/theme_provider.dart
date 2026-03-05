import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (saved == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final value = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.light
            ? 'light'
            : 'system';
    await prefs.setString(_key, value);
  }

  Future<void> toggleTheme(BuildContext context) async {
    // If currently dark → switch to light, else → switch to dark
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}
