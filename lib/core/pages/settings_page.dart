import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:splitcount/core/services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var settingsService = context.read<ISettingsService>();
    final isDarkMode = settingsService.isCurrentlyDarkMode();
    final isSystemTheme =
        settingsService.getCurrentThemeMode() == ThemeMode.system;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Common'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                value: const Text('English'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    if (value) {
                      settingsService.setThemeMode(
                          isDarkMode ? ThemeMode.dark : ThemeMode.light);
                    } else {
                      settingsService.setThemeMode(ThemeMode.system);
                    }
                  });
                },
                initialValue: !isSystemTheme,
                leading: const Icon(Icons.format_paint),
                title: const Text('Choose custom theme'),
                description: const Text('Leave disabled to use system theme'),
              ),
              SettingsTile.switchTile(
                enabled: !isSystemTheme,
                onToggle: !isSystemTheme
                    ? (value) {
                        setState(() {
                          settingsService.setThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light);
                        });
                      }
                    : null,
                initialValue: isDarkMode,
                leading: Icon(isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded),
                title: const Text('Dark mode'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
