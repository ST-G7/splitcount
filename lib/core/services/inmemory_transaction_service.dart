import 'dart:math';

import 'package:rxdart/subjects.dart';

import '../models/transaction.dart';
import 'transaction_service.dart';

final demoTransactionList = [
  Transaction("0", "Max", "Flight (Rio)", 2.000),
  Transaction("1", "Lisa", "Car", 12.000, emoji: "🏎️"),
  Transaction("2", "John", "Kebab", 4.50, emoji: "🥙"),
  Transaction("3", "Anna", "Cafe & Biscuits", 7.80),
  Transaction("4", "Ludwig", "Restaurant", 76.99)
];

class InMemoryTransactionService implements ITransactionService {
  final BehaviorSubject<List<Transaction>> _transactions =
      BehaviorSubject.seeded(demoTransactionList);

  @override
  Future<Transaction> createTransaction(Transaction transaction, {int? index}) {
    var newTransactions = List<Transaction>.from(_transactions.value);

    newTransactions.insert(
        min(index ?? newTransactions.length, newTransactions.length),
        transaction);
    _transactions.add(newTransactions);

    return Future.value(transaction);
  }

  @override
  Future<void> deleteTransaction(Transaction transaction) async {
    var newTransactions = List<Transaction>.from(_transactions.value);
    newTransactions.remove(transaction);
    _transactions.add(newTransactions);
  }

  @override
  Stream<List<Transaction>> getTransactions() {
    return _transactions.stream;
  }
}
