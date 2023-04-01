import 'package:isar/isar.dart';

import '../../models/expense.dart';

part 'database_models.g.dart';

@collection
class ExpenseDbEntry {
  late String id;

  Id get isarId => fastHash(id);

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

//https://isar.dev/recipes/string_ids.html
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}
