import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitcount/core/services/transaction_service.dart';
import 'package:splitcount/core/services/group_service.dart';
import 'package:splitcount/core/services/remote_transaction_service.dart';
import 'package:splitcount/core/services/remote_group_service.dart';

import 'package:splitcount/core/pages/group_page.dart';

import 'package:provider/provider.dart';

BehaviorSubject<ThemeMode> selectedTheme =
    BehaviorSubject.seeded(ThemeMode.light);

const kDarkModePreferencesKey = 'dark-mode';

setSelectedTheme(ThemeMode mode) async {
  final preferences = await SharedPreferences.getInstance();

  if (mode == ThemeMode.dark) {
    await preferences.setBool(kDarkModePreferencesKey, true);
  } else {
    await preferences.remove(kDarkModePreferencesKey);
  } 

  selectedTheme.add(mode);
}

void main() async {
  final preferences = await SharedPreferences.getInstance();
  var isDarkMode = preferences.getBool(kDarkModePreferencesKey) ?? false;
  selectedTheme.add(isDarkMode ? ThemeMode.dark : ThemeMode.light);

  runApp(
    MultiProvider(
      providers: [
        Provider<ITransactionService>(
            create: (_) => RemoteTransactionService()),
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
    return StreamBuilder<ThemeMode>(
        stream: selectedTheme.stream,
        builder: (context, snapshot) {
          return MaterialApp(
              title: 'Splitcount',
              theme: ThemeData(
                  brightness: Brightness.light, primarySwatch: Colors.green),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
              ),
              themeMode: snapshot.data,
              debugShowCheckedModeBanner: false,
              home: const GroupOverviewPage(title: 'GroupOverwiew'));
        });
  }
}
