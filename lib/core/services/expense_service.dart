import 'package:splitcount/core/models/expense.dart';

abstract class IExpenseService {
  Future<Expense> createExpense(Expense entry, {int? index});

  Future<void> deleteExpense(Expense entry);

  Stream<List<Expense>> getExpenses();
}
