import 'package:isar/isar.dart';

import '../../models/expense.dart';

part 'database_models.g.dart';

@collection
class ExpenseDbEntry {
  late Id id = Isar.autoIncrement;
  String? emoji;
  late String user;
  late String title;
  late double amount;
  late String currency;

  static ExpenseDbEntry fromExpense(Expense expense) {
    final dbEntry = ExpenseDbEntry();
    dbEntry.user = expense.user;
    dbEntry.emoji = expense.emoji;
    dbEntry.title = expense.title;
    dbEntry.amount = expense.amount;
    dbEntry.currency = expense.currency;
    dbEntry.id = expense.id;
    return dbEntry;
  }

  Expense toExpense() {
    return Expense(id, user, title, amount);
  }
}
