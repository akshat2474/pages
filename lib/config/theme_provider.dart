import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadThemeFromPrefs();
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeToPrefs();
    notifyListeners();
  }
  
  void _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_theme') ?? false;
    notifyListeners();
  }
  
  void _saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('dark_theme', _isDarkMode);
  }
}