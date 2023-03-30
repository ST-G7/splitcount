import 'package:splitcount/core/models/expense.dart';

abstract class IExpenseService {
  Future<Expense> createExpense(Expense expense, {int? index});

  Future<void> deleteExpense(Expense expense);

  Stream<List<Expense>> getExpenses();
}
