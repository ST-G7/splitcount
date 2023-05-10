import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitcount/core/services/settings_service.dart';

class LocalSettingsService implements ISettingsService {
  static const modePreferenceKey = 'theme-mode-setting';
  static const localPreferenceKey = 'locale-setting';

  BehaviorSubject<ThemeMode> selectedTheme =
      BehaviorSubject.seeded(ThemeMode.system);

  BehaviorSubject<Locale?> localeStream = BehaviorSubject.seeded(null);

  late Future isInitialized;

  LocalSettingsService() {
    isInitialized = _init();
  }

  _init() async {
    final preferences = await SharedPreferences.getInstance();
    final startingModeIndex =
        preferences.getInt(modePreferenceKey) ?? ThemeMode.system.index;
    var startingMode = ThemeMode.values[startingModeIndex];
    selectedTheme.add(startingMode);

    final languageKey = preferences.getString(localPreferenceKey);
    final locale = languageKey != null ? Locale(languageKey) : null;

    selectedTheme.add(startingMode);
    localeStream.add(locale);
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
    await preferences.setInt(modePreferenceKey, mode.index);
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

  @override
  Stream<Locale?> getLocale() {
    return localeStream;
  }

  @override
  Locale? getCurrentLocale() {
    return localeStream.value;
  }

  @override
  Stream onSettingsChanged() {
    return Rx.merge([getThemeMode().skip(1), localeStream.skip(1)]);
  }

  @override
  Future setPreferredLocale(String? code) async {
    final preferences = await SharedPreferences.getInstance();
    if (code != null) {
      await preferences.setString(localPreferenceKey, code);
      localeStream.add(Locale(code));
    } else {
      await preferences.remove(localPreferenceKey);
      localeStream.add(null);
    }
  }
}
