import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/models/transaction.dart';
import 'package:splitcount/core/pages/transactions/transaction_editor_page.dart';
import 'package:splitcount/core/services/transaction_service.dart';
import 'package:splitcount/core/ui/circular_icon_button.dart';
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
    var group = transactionService.getCurrentGroup();

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

                  final paidByMe = transaction.user == group.localMember;
                  final paidForMe = group.localMember != null &&
                      group.members.contains(group.localMember);

                  return Dismissible(
                      key: Key(transaction.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(color: Colors.red),
                      onDismissed: (direction) async {
                        final messenger = ScaffoldMessenger.of(context);
                        var transactionDeletedText =
                            AppLocalizations.of(context)!
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
                      child: _getListTile(transaction, paidByMe, paidForMe,
                          transactionService));
                });
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  ListTile _getListTile(Transaction transaction, bool paidByMe, bool paidForMe,
      ITransactionService transactionService) {
    var subtitle =
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(AppLocalizations.of(context)!.paidBy),
      const SizedBox(width: 4),
      InitialsAvatar(text: transaction.user, radius: 8),
      const SizedBox(width: 2),
      Text(
        paidByMe ? AppLocalizations.of(context)!.me : transaction.user,
        style: paidByMe ? const TextStyle(fontWeight: FontWeight.bold) : null,
      )
    ]);

    var saldoTextStyle = paidByMe
        ? const TextStyle(color: Colors.green)
        : paidForMe
            ? const TextStyle(color: Colors.red)
            : null;

    return ListTile(
        leading: CircularIconButton(
          transaction.category.icon,
          size: 40,
        ),
        title: Text(transaction.title),
        subtitle: subtitle,
        onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TransactionEditorPage(
                          transactionService,
                          editingTransaction: transaction,
                        )),
              )
            },
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
                style: saldoTextStyle,
                "${transaction.amount.toStringAsFixed(2)} ${transaction.currency}"),
            Text(
              _formatDate(transaction.dateTime),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ));
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
                          TransactionEditorPage(transactionService)),
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
