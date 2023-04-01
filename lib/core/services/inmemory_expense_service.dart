import 'dart:math';

import 'package:rxdart/subjects.dart';

import '../models/expense.dart';
import 'expense_service.dart';

final demoExpenseList = [
  Expense("0", "Max", "Flight (Rio)", 2.000),
  Expense("1", "Lisa", "Car", 12.000, emoji: "🏎️"),
  Expense("2", "John", "Kebab", 4.50, emoji: "🥙"),
  Expense("3", "Anna", "Cafe & Biscuits", 7.80),
  Expense("4", "Ludwig", "Restaurant", 76.99)
];

class InMemoryExpenseService implements IExpenseService {
  final BehaviorSubject<List<Expense>> _expenses =
      BehaviorSubject.seeded(demoExpenseList);

  @override
  Future<Expense> createExpense(Expense expense, {int? index}) {
    var newExpenses = List<Expense>.from(_expenses.value);

    newExpenses.insert(
        min(index ?? newExpenses.length, newExpenses.length), expense);
    _expenses.add(newExpenses);

    return Future.value(expense);
  }

  @override
  Future<void> deleteExpense(Expense expense) async {
    var newExpenses = List<Expense>.from(_expenses.value);
    newExpenses.remove(expense);
    _expenses.add(newExpenses);
  }

  @override
  Stream<List<Expense>> getExpenses() {
    return _expenses.stream;
  }
}
