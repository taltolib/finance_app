import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'is_dark_theme';

  bool _isDark = true;

  bool get isDark => _isDark;

  String get authBackgroundAsset {
    return _isDark
        ? 'assets/images/kanban_bg_dark.png'
        : 'assets/images/kanban_bg.png';
  }

  /// Загрузить тему из SharedPreferences при старте
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_themeKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDark);
  }

  Future<void> setTheme(bool isDark) async {
    if (_isDark == isDark) return;
    _isDark = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDark);
  }
}