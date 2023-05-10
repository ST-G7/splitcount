import 'dart:io';

import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:splitcount/constants.dart';
import 'package:splitcount/core/services/settings_service.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Language {
  final String key;
  final String title;
  final String emoji = "🇩🇪";
  Language(this.key, this.title);
}

class SettingsPage extends StatefulWidget {
  SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPage();

  final avatars = appwrite.Avatars(appwriteClient);
  final List<Language> languages = [
    Language("en", "English"),
    Language("de", "Deutsch")
  ];
}

class _SettingsPage extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var settingsService = context.read<ISettingsService>();

    return StreamBuilder(
        stream: settingsService.onSettingsChanged(),
        builder: (context, snapshot) {
          final isDarkMode = settingsService.isCurrentlyDarkMode();
          final isSystemTheme =
              settingsService.getCurrentThemeMode() == ThemeMode.system;

          final selectedLocale = settingsService.getCurrentLocale();
          final language = selectedLocale != null
              ? widget.languages
                  .firstWhere((l) => l.key == selectedLocale.languageCode)
                  .title
              : 'System';

          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.settings),
            ),
            body: SettingsList(
              sections: [
                SettingsSection(
                  title: Text(AppLocalizations.of(context)!.common),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      leading: const Icon(Icons.language),
                      title: Text(AppLocalizations.of(context)!.language),
                      value: Text(language),
                      onPressed: (context) => {
                        showBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Row(children: [
                                  const Icon(Icons.language),
                                  Container(
                                    width: 8,
                                  ),
                                  Text(AppLocalizations.of(context)!.languages)
                                ]),
                                content: _createLanguageDialog(settingsService),
                              );
                            })
                      },
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
                      title:
                          Text(AppLocalizations.of(context)!.chooseCustomTheme),
                      description: Text(
                          AppLocalizations.of(context)!.themeDefaultModeNotice),
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
        });
  }

  Widget _createLanguageDialog(ISettingsService settingsService) {
    return StreamBuilder<Locale?>(
      stream: settingsService.getLocale(),
      builder: (BuildContext context, AsyncSnapshot<Locale?> snapshot) {
        final selectedLocale = snapshot.data;
        return SizedBox(
          height: 250.0,
          width: 300.0,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.languages.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return RadioListTile(
                    title: const Text("System"),
                    subtitle:
                        Text(Platform.localeName.split('_')[0].toUpperCase()),
                    value: null,
                    onChanged: (value) =>
                        settingsService.setPreferredLocale(null),
                    groupValue: selectedLocale?.languageCode,
                  );
                }

                final language = widget.languages[index - 1];
                return RadioListTile(
                  title: Text(language.title),
                  subtitle: Text(language.key.toUpperCase()),
                  value: language.key,
                  onChanged: (value) async {
                    settingsService.setPreferredLocale(language.key);
                  },
                  groupValue: selectedLocale?.languageCode,
                );
              }),
        );
      },
    );
  }
}
