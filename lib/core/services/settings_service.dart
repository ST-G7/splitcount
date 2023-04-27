import 'package:flutter/material.dart';

abstract class ISettingsService {
  ThemeMode getCurrentThemeMode();

  Stream<ThemeMode> getThemeMode();

  bool isCurrentlyDarkMode();

  Stream<bool> isDarkMode();

  Future setThemeMode(ThemeMode mode);
}
