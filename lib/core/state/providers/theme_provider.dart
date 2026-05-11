import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = true;

  bool get isDark => _isDark;

  String get authBackgroundAsset {
    return _isDark
        ? 'assets/images/kanban_bg_dark.png'
        : 'assets/images/kanban_bg.png';
  }

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    if (_isDark == isDark) return;
    _isDark = isDark;
    notifyListeners();
  }
}
