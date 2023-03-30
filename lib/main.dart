import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitcount/core/services/expense_service.dart';
import 'package:splitcount/core/services/inmemory_expense_service.dart';
import 'package:splitcount/core/services/local/local_expense_service.dart';

import 'core/models/expense.dart';

// Save an boolean value to 'repeat' key.
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

final IExpenseService _expenseService = LocalExpenseService();
// final IExpenseService _expenseService = InMemoryExpenseService();

void main() async {
  final preferences = await SharedPreferences.getInstance();
  var isDarkMode = preferences.getBool(kDarkModePreferencesKey) ?? false;
  selectedTheme.add(isDarkMode ? ThemeMode.dark : ThemeMode.light);
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
              title: 'Splitcount',
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
            onPressed: () async {
              await setSelectedTheme(
                  isLightMode ? ThemeMode.dark : ThemeMode.light);
              setState(() => {});
            }),
      ),
      body: const ExpenseList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateExpensePage()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
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
    return StreamBuilder<List<Expense>>(
        stream: _expenseService.getExpenses(),
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
                  final expense = snapshot.data![index];

                  return Dismissible(
                    key: Key(expense.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(color: Colors.red),
                    onDismissed: (direction) {
                      _expenseService.deleteExpense(expense);

                      // Then show a snackbar.
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Entry ${expense.title} was delete'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            _expenseService.createExpense(expense,
                                index: index);
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
                              color: Theme.of(context).primaryColorLight),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              style: const TextStyle(fontSize: 22),
                              expense.emoji ?? "💲",
                              textAlign: TextAlign.center,
                            ),
                          )),
                      title: Text(expense.title),
                      subtitle: Text("paid by ${expense.user}"),
                      trailing: Text(
                          "${expense.amount.toStringAsFixed(2)} ${expense.currency}"),
                    ),
                  );
                });
          } else {
            return const Text("No data available");
          }
        });
  }
}

class CreateExpensePage extends StatefulWidget {
  const CreateExpensePage({super.key});

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _userInput = TextEditingController();
  final TextEditingController _titleInput = TextEditingController();
  final TextEditingController _amountInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Create Expense'),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    autofocus: true,
                    controller: _titleInput,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a valid title';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextFormField(
                    controller: _amountInput,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp('[0-9]+(,[0-9][0-9])?'))
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid value';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                    ),
                  ),
                  TextFormField(
                    controller: _userInput,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a user';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Person'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);

                            final createdExpense =
                                await _expenseService.createExpense(Expense(
                                    Random().nextInt(10000),
                                    _userInput.text,
                                    _titleInput.text,
                                    double.parse(_amountInput.text)));

                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content:
                                    Text('Created ${createdExpense.title}'),
                                action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () async => {
                                          await _expenseService
                                              .deleteExpense(createdExpense)
                                        }),
                              ),
                            );

                            navigator.pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).primaryIconTheme.color,
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 1.0,
                        ),
                        child: const Text('Create Entry'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
