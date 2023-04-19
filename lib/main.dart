import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitcount/core/services/transaction_service.dart';
import 'package:splitcount/core/services/group_service.dart';
import 'package:splitcount/core/services/remote_transaction_service.dart';
import 'package:splitcount/core/services/remote_group_service.dart';

import 'core/models/transaction.dart';
import 'core/models/group.dart';

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

final ITransactionService _transactionService = RemoteTransactionService();
final IGroupService _groupService = RemoteGroupService();

//final ITransactionService _transactionService = InMemoryTransactionService();

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
              home: const MyHomePage(title: 'GroupOverwiew'));
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _GroupOverviewPage();
}

// ---------------
class _GroupOverviewPage extends State<MyHomePage> {
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
      body: const GroupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateTransactionPage()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GroupList extends StatefulWidget {
  const GroupList({super.key});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Group>>(
        stream: _groupService.getGroups(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                  );
                },
                itemCount: snapshot.data!.length,
                padding: const EdgeInsets.only(right: 40.0),
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  final group = snapshot.data![index];

                  return ListTile(
                    leading: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColorLight),
                        child: const Align(alignment: Alignment.center)),
                    title: Text(group.groupName),

                    subtitle: Text(group.members.join(", "),
                        overflow: TextOverflow.ellipsis),
                    //trailing: Text(
                    //    "${transaction.amount.toStringAsFixed(2)} ${transaction.currency}"),
                  );
                });
          } else {
            return const Text("No data available");
          }
        });
  }
}

//---------------

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
      body: const TransactionList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateTransactionPage()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
        stream: _transactionService.getTransactions(),
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
                  final transaction = snapshot.data![index];

                  return Dismissible(
                    key: Key(transaction.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(color: Colors.red),
                    onDismissed: (direction) async {
                      final messenger = ScaffoldMessenger.of(context);
                      await _transactionService.deleteTransaction(transaction);

                      messenger.showSnackBar(SnackBar(
                        content: Text('Entry ${transaction.title} was delete'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () async {
                            await _transactionService
                                .createTransaction(transaction, index: index);
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
                              transaction.emoji ?? "💲",
                              textAlign: TextAlign.center,
                            ),
                          )),
                      title: Text(transaction.title),
                      subtitle: Text("paid by ${transaction.user}"),
                      trailing: Text(
                          "${transaction.amount.toStringAsFixed(2)} ${transaction.currency}"),
                    ),
                  );
                });
          } else {
            return const Text("No data available");
          }
        });
  }
}

class CreateTransactionPage extends StatefulWidget {
  const CreateTransactionPage({super.key});

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _userInput = TextEditingController();
  final TextEditingController _titleInput = TextEditingController();
  final TextEditingController _amountInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Create Transaction'),
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

                            final createdTransaction = await _transactionService
                                .createTransaction(Transaction(
                                    Random()
                                        .nextInt(10000000)
                                        .toString(), // TODO: This should be handled better
                                    _userInput.text,
                                    _titleInput.text,
                                    double.parse(_amountInput.text)));

                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content:
                                    Text('Created ${createdTransaction.title}'),
                                action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () async => {
                                          await _transactionService
                                              .deleteTransaction(
                                                  createdTransaction)
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
