import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitcount/core/services/settings_service.dart';

class LocalSettingsService implements ISettingsService {
  static const modePreferenceKy = 'theme-mode';

  BehaviorSubject<ThemeMode> selectedTheme =
      BehaviorSubject.seeded(ThemeMode.system);

  late Future isInitialized;

  LocalSettingsService() {
    isInitialized = _init();
  }

  @override
  ThemeMode getCurrentThemeMode() {
    return selectedTheme.value;
  }

  @override
  Stream<ThemeMode> getThemeMode() {
    return selectedTheme.distinct().asBroadcastStream();
  }

  @override
  Future setThemeMode(ThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(modePreferenceKy, mode.index);
    selectedTheme.add(mode);
  }

  @override
  bool isCurrentlyDarkMode() {
    if (selectedTheme.value == ThemeMode.system) {
      return _isSystemThemeDarkMode();
    }

    return selectedTheme.value == ThemeMode.dark;
  }

  @override
  Stream<bool> isDarkMode() {
    return getThemeMode().map((event) => isCurrentlyDarkMode());
  }

  bool _isSystemThemeDarkMode() {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    return brightness == Brightness.dark;
  }

  _init() async {
    final preferences = await SharedPreferences.getInstance();
    final startingModeIndex =
        preferences.getInt(modePreferenceKy) ?? ThemeMode.system.index;
    var startingMode = ThemeMode.values[startingModeIndex];
    selectedTheme.add(startingMode);
  }
}
