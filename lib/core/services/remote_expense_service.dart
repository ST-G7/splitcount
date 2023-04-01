import 'package:appwrite/models.dart';
import 'package:rxdart/rxdart.dart';
import 'package:splitcount/core/models/expense.dart';
import 'package:splitcount/core/services/expense_service.dart';

import 'package:appwrite/appwrite.dart';

class RemoteExpenseService implements IExpenseService {
  final Client client = Client();
  late Realtime realtime;
  late Databases databases;

  static const String databaseId = "642751b87c6dbc13f97e";
  static const String collectionId = "642751e73ea8bf7bcb3a";

  RemoteExpenseService() {
    client
        .setEndpoint('https://appwrite.perz.cloud/v1')
        .setProject('6427515d8090de3f3f0f');

    databases = Databases(client);
    realtime = Realtime(client);
  }

  @override
  Future<Expense> createExpense(Expense expense, {int? index}) async {
    var document = await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: {
          "user": expense.user,
          "amount": expense.amount,
          "title": expense.title,
        });

    return _createExpenseFromDocument(document);
  }

  @override
  Future<void> deleteExpense(Expense expense) async {
    await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: expense.id);
  }

  @override
  Stream<List<Expense>> getExpenses() async* {
    final subscription = realtime.subscribe(
        ['databases.$databaseId.collections.$collectionId.documents']);

    yield* subscription.stream
        .asyncMap((event) => _getExpenseList())
        .startWith(await _getExpenseList());
  }

  Future<List<Expense>> _getExpenseList() async {
    final expenseDocuments = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [Query.orderDesc("\$createdAt")]);

    final expenses =
        expenseDocuments.documents.map(_createExpenseFromDocument).toList();

    return expenses;
  }

  Expense _createExpenseFromDocument(Document document) {
    return Expense(document.$id, document.data["user"], document.data["title"],
        (document.data["amount"] as num).toDouble());
  }
}
