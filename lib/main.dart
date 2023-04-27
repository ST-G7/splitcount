import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:splitcount/core/services/group_service.dart';
import 'package:splitcount/core/services/local_settings_service.dart';
import 'package:splitcount/core/services/remote_group_service.dart';

import 'package:splitcount/core/pages/group_page.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/services/settings_service.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var localSettingsService = LocalSettingsService();
  await localSettingsService.isInitialized;

  runApp(
    MultiProvider(
      providers: [
        Provider<ISettingsService>(create: (_) => localSettingsService),
        Provider<IGroupService>(create: (_) => RemoteGroupService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = context.read<ISettingsService>();

    return StreamBuilder<ThemeMode>(
        stream: settingsService.getThemeMode(),
        builder: (context, snapshot) {
          final lightTheme = ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
          );

          var darkTheme = ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
          );

          darkTheme = darkTheme.copyWith(
              colorScheme:
                  darkTheme.colorScheme.copyWith(secondary: Colors.green));

          return MaterialApp(
              title: 'Splitcount',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: snapshot.data,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const GroupOverviewPage());
        });
  }
}
