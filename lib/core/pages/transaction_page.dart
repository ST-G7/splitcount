import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/models/group.dart';

import 'package:splitcount/core/models/transaction.dart';
import 'package:splitcount/core/pages/create_transaction_page.dart';
import 'package:splitcount/core/services/transaction_service.dart';
import 'package:splitcount/core/services/remote_transaction_service.dart';
import 'package:splitcount/core/ui/user_avatar.dart';

class TransactionPage extends StatefulWidget {
  TransactionPage(this.group, {super.key}) {
    transactionService = RemoteTransactionService(group);
  }

  final Group group;
  late final ITransactionService transactionService;

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Provider<ITransactionService>(
      create: (_) => widget.transactionService,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.group.name),
        ),
        body: const TransactionList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CreateTransactionPage(widget.transactionService)),
            );
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
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
    var transactionService = context.read<ITransactionService>();
    return StreamBuilder<List<Transaction>>(
        stream: transactionService.getLiveTransactions(),
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
                      await transactionService.deleteTransaction(transaction);

                      messenger.showSnackBar(SnackBar(
                        content: Text('Entry ${transaction.title} was delete'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () async {
                            await transactionService
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
                        subtitle: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("paid by"),
                              const SizedBox(width: 4),
                              UserAvatar(transaction.user, 18),
                              const SizedBox(width: 2),
                              Text(transaction.user)
                            ]),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                "${transaction.amount.toStringAsFixed(2)} ${transaction.currency}"),
                            Text(
                              _formatDate(transaction.dateTime),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        )),
                  );
                });
          } else {
            return const Text("No data available");
          }
        });
  }

  final DateFormat dayFormatter = DateFormat('MMMEd');
  final DateFormat todayFormatter = DateFormat.Hm();

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();

    final correctFormatter =
        now.day == date.day && now.month == date.month && now.year == date.year
            ? todayFormatter
            : dayFormatter;
    return correctFormatter.format(date);
  }
}
