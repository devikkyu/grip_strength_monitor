import 'package:flutter/material.dart';
import 'package:grip_strength_monitor/services/persistence_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  final PersistenceService _persistence = PersistenceService();

  ThemeMode get themeMode {
    return _themeMode;
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = _persistence.get('settings', 'theme_mode');
    if (savedTheme != null) {
      _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _persistence.save('settings', 'theme_mode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}
