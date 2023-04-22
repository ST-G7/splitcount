import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/models/transaction.dart';

abstract class ITransactionService {
  Future<Group> getCurrentGroup();

  Future<Transaction> getTransactionById(String id);

  Future<Transaction> createTransaction(Transaction transaction, {int? index});

  Future<void> deleteTransaction(Transaction transaction);

  Future<List<Transaction>> getTransactions();

  Stream<List<Transaction>> getLiveTransactions();
}
