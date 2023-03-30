import 'package:isar/isar.dart';
import 'package:splitcount/core/services/local/database_models.dart';

import '../../models/expense.dart';
import '../expense_service.dart';

class LocalExpenseService implements IExpenseService {
  late Future<Isar> _db;

  LocalExpenseService() {
    _db = _openDB();
  }

  @override
  Future<Expense> createExpense(Expense expense, {int? index}) async {
    final isar = await _db;
    final entry = ExpenseDbEntry.fromExpense(expense);

    await isar.writeTxn(() async {
      await isar.expenseDbEntrys.put(entry);
    });

    return entry.toExpense();
  }

  @override
  Future<void> deleteExpense(Expense expense) async {
    final isar = await _db;

    await isar.writeTxn(() async {
      await isar.expenseDbEntrys.delete(expense.id);
    });
  }

  @override
  Stream<List<Expense>> getExpenses() async* {
    final isar = await _db;
    final dbStream = isar.expenseDbEntrys.where().watch(fireImmediately: true);

    yield* dbStream
        .map((list) => list.map((dbExpense) => dbExpense.toExpense()).toList());
  }

  Future<Isar> _openDB() async {
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [ExpenseDbEntrySchema],
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
