import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:splitcount/core/pages/groups/create_group_page.dart';
import 'package:splitcount/core/pages/groups/group_detail_page.dart';
import 'package:splitcount/core/pages/settings_page.dart';
import 'package:splitcount/core/services/group_service.dart';
import 'package:splitcount/core/services/implementations/impl_group_service.dart';
import 'package:splitcount/core/services/implementations/local_settings_service.dart';

import 'package:splitcount/core/pages/groups/groups_overview_page.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/services/settings_service.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:json_theme/json_theme.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:flutter/services.dart';
import 'dart:convert';

final _router = GoRouter(
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) => const GroupOverviewPage(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => SettingsPage(),
          ),
          GoRoute(
            path: 'groups/create',
            builder: (context, state) => const CreateGroupPage(),
          ),
          GoRoute(
            path: 'groups/:groupId',
            builder: (context, state) {
              var groupId = state.pathParameters['groupId'];
              if (groupId != null) {
                return GroupDetailPage(groupId);
              }
              return const GroupOverviewPage();
            },
          )
        ]),
  ],
);

void main() async {
  usePathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();

  Future<ThemeData> loadTheme(String name) async {
    final themeJson =
        jsonDecode(await rootBundle.loadString('assets/themes/$name'));

    // Remove target platform and use native
    themeJson["platform"] = null;
    return ThemeDecoder.decodeThemeData(themeJson)!;
  }

  final lightTheme = await loadTheme('light-theme.json');
  final darkTheme = await loadTheme('dark-theme.json');

  var localSettingsService = LocalSettingsService();
  await localSettingsService.isInitialized;

  var groupService = GroupService();

  runApp(
    MultiProvider(
      providers: [
        Provider<ISettingsService>(create: (_) => localSettingsService),
        Provider<IGroupService>(create: (_) => groupService),
        Provider<ILocalGroupInformationService>(create: (_) => groupService),
      ],
      child: MyApp(
        lightTheme: lightTheme,
        darkTheme: darkTheme,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeData? lightTheme;
  final ThemeData? darkTheme;

  const MyApp({super.key, this.lightTheme, this.darkTheme});

  @override
  Widget build(BuildContext context) {
    final settingsService = context.read<ISettingsService>();

    return StreamBuilder(
        stream: settingsService.onSettingsChanged(),
        builder: (context, snapshot) {
          return MaterialApp.router(
            title: 'Splitcount',
            theme: lightTheme,
            darkTheme: darkTheme,
            locale: settingsService.getCurrentLocale(),
            themeMode: settingsService.getCurrentThemeMode(),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: _router,
          );
        });
  }
}
