import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

BehaviorSubject<ThemeMode> selectedTheme =
    BehaviorSubject.seeded(ThemeMode.light);

class ExpenseEntry {
  final String id;
  final String? emoji;
  final String user;
  final String title;
  final double amount;
  final String currency;

  const ExpenseEntry(this.id, this.user, this.title, this.amount,
      {this.emoji, this.currency = "€"});
}

final demoExpenseList = [
  const ExpenseEntry("1", "Max", "Flight (Rio)", 2.000),
  const ExpenseEntry("2", "Lisa", "Car", 12.000, emoji: "🏎️"),
  const ExpenseEntry("3", "John", "Kebab", 4.50, emoji: "🥙"),
  const ExpenseEntry("4", "Anna", "Cafe & Biscuits", 7.80),
  const ExpenseEntry("5", "Ludwig", "Restaurant", 76.99)
];

BehaviorSubject<List<ExpenseEntry>> expenses =
    BehaviorSubject.seeded(demoExpenseList);

void addExpense(ExpenseEntry entry, {int? index}) {
  var newExpenses = List<ExpenseEntry>.from(expenses.value);

  newExpenses.insert(
      min(index ?? newExpenses.length, newExpenses.length - 1), entry);
  expenses.add(newExpenses);
}

void removeExpense(int index) {
  var newExpenses = List<ExpenseEntry>.from(expenses.value);
  newExpenses.removeAt(index);
  expenses.add(newExpenses);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeMode>(
        stream: selectedTheme.stream,
        builder: (context, snapshot) {
          return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                  brightness: Brightness.light, primarySwatch: Colors.green),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
              ),
              themeMode: snapshot.data,
              debugShowCheckedModeBanner: false,
              home: const MyHomePage(title: 'Splitcount'));
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final isLightMode = selectedTheme.value == ThemeMode.light;

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: Icon(isLightMode
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded),
            tooltip: isLightMode ? 'Enable dark mode' : 'Enable light mode',
            onPressed: () {
              setState(() {
                selectedTheme
                    .add(isLightMode ? ThemeMode.dark : ThemeMode.light);
              });
            },
          ),
        ),
        body: const ExpenseList());
  }
}

class ExpenseList extends StatefulWidget {
  const ExpenseList({super.key});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ExpenseEntry>>(
        stream: expenses,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                  );
                },
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  final entry = snapshot.data![index];

                  return Dismissible(
                    key: Key(entry.id),
                    direction: DismissDirection.endToStart,
                    background: Container(color: Colors.red),
                    onDismissed: (direction) {
                      removeExpense(index);

                      // Then show a snackbar.
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Entry ${entry.title} was delete'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            addExpense(entry, index: index);
                          },
                        ),
                      ));
                    },
                    child: ListTile(
                      leading: Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColorLight,
                              border: Border.all(
                                width: 2,
                                color: Theme.of(context).primaryColor,
                              )),
                          child: Align(
                            alignment: Alignment
                                .center, // Align however you like (i.e .centerRight, centerLeft)
                            child: Text(
                              style: const TextStyle(fontSize: 22),
                              entry.emoji ?? "💲",
                              textAlign: TextAlign.center,
                            ),
                          )),
                      title: Text(entry.title),
                      subtitle: Text("Paid by ${entry.user}"),
                      trailing: Text(
                          "${entry.amount.toStringAsFixed(2)} ${entry.currency}"),
                    ),
                  );
                });
          } else {
            return const Text("No data available");
          }
        });
  }
}
