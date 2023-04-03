import 'package:splitcount/core/models/transaction.dart';

abstract class ITransactionService {
  Future<Transaction> createTransaction(Transaction transaction, {int? index});

  Future<void> deleteTransaction(Transaction transaction);

  Stream<List<Transaction>> getTransactions();
}
