import 'package:flutter/material.dart';
import '../models/church_theme.dart';
import '../services/church_service.dart';

class ThemeProvider with ChangeNotifier {
  ChurchTheme _currentTheme = ChurchThemes.ekklesiaLight;
  final ChurchService _churchService = ChurchService();

  ChurchTheme get currentTheme => _currentTheme;
  ThemeData get themeData => _currentTheme.toThemeData();

  /// Load theme from user's church
  Future<void> loadChurchTheme(String userId) async {
    try {
      final churches = await _churchService.getUserChurches(userId);

      if (churches.isNotEmpty) {
        // Use the theme from the first church (primary church)
        final church = churches.first;
        _currentTheme = ChurchTheme.fromValue(church.theme);
        notifyListeners();
      }
    } catch (e) {
      // If error, keep default theme
      debugPrint('Error loading church theme: $e');
    }
  }

  /// Set theme manually (for preview or testing)
  void setTheme(ChurchTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  /// Set theme by value string
  void setThemeByValue(String value) {
    _currentTheme = ChurchTheme.fromValue(value);
    notifyListeners();
  }

  /// Reset to default theme
  void resetToDefault() {
    _currentTheme = ChurchThemes.ekklesiaLight;
    notifyListeners();
  }
}
