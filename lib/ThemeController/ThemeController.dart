import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark }

class ThemeController with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences prefs;

  AppThemeMode _themeMode = AppThemeMode.light;

  ThemeController({required this.prefs}) {
    _loadTheme();
  }

  AppThemeMode get themeMode => _themeMode;

  ThemeData get currentTheme {
    switch (_themeMode) {
      case AppThemeMode.dark:
        return ThemeData.dark();
      case AppThemeMode.light:
      default:
        return ThemeData.light();
    }
  }

  Future<void> _loadTheme() async {
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      _themeMode = AppThemeMode.values.firstWhere(
            (e) => e.toString() == savedTheme,
        orElse: () => AppThemeMode.light,
      );
      notifyListeners();
    }
  }

  Future<void> updateThemeMode(AppThemeMode newMode) async {
    _themeMode = newMode;
    await prefs.setString(_themeKey, newMode.toString());
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    await prefs.setString(_themeKey, _themeMode.toString());
    notifyListeners();
  }
}