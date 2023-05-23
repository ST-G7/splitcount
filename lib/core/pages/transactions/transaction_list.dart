import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/models/transaction.dart';
import 'package:splitcount/core/pages/transactions/create_transaction_page.dart';
import 'package:splitcount/core/services/transaction_service.dart';
import 'package:splitcount/core/ui/initials_avatar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          var transactions = snapshot.data;
          if (snapshot.hasData && transactions != null) {
            if (transactions.isEmpty) {
              return const NoTransactionsPlaceholder();
            }

            return ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                  );
                },
                itemCount: transactions.length,
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  final transaction = transactions[index];
                  return Dismissible(
                    key: Key(transaction.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(color: Colors.red),
                    onDismissed: (direction) async {
                      final messenger = ScaffoldMessenger.of(context);
                      var transactionDeletedText = AppLocalizations.of(context)!
                          .transactionDeleted(transaction.title);

                      var undoText = AppLocalizations.of(context)!.undo;

                      await transactionService.deleteTransaction(transaction);

                      messenger.showSnackBar(SnackBar(
                        content: Text(transactionDeletedText),
                        action: SnackBarAction(
                          label: undoText,
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
                              Text(AppLocalizations.of(context)!.paidBy),
                              const SizedBox(width: 4),
                              InitialsAvatar(text: transaction.user, radius: 8),
                              const SizedBox(width: 2),
                              Text(transaction.user)
                            ]),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
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
            return const Center(child: CircularProgressIndicator());
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

class NoTransactionsPlaceholder extends StatelessWidget {
  const NoTransactionsPlaceholder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var transactionService = context.read<ITransactionService>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt,
            size: 112,
          ),
          Text(
            AppLocalizations.of(context)!.noTransactions,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Container(
            height: 8,
          ),
          Text(
            AppLocalizations.of(context)!
                .groupNoTransactions(transactionService.getCurrentGroup().name),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Container(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          CreateTransactionPage(transactionService)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context)!.createTransaction,
                  textAlign: TextAlign.center,
                ),
              )),
          Container(
            height: 60, // Add to bottom for visual balance
          ),
        ],
      ),
    );
  }
}
