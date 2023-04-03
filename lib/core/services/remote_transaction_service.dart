import 'package:appwrite/models.dart';
import 'package:rxdart/rxdart.dart';
import 'package:splitcount/core/models/transaction.dart';
import 'package:splitcount/core/services/transaction_service.dart';

import 'package:appwrite/appwrite.dart';

class RemoteTransactionService implements ITransactionService {
  final Client client = Client();
  late Realtime realtime;
  late Databases databases;

  static const String databaseId = "642751b87c6dbc13f97e";
  static const String collectionId = "642751e73ea8bf7bcb3a";

  RemoteTransactionService() {
    client
        .setEndpoint('https://appwrite.perz.cloud/v1')
        .setProject('6427515d8090de3f3f0f');

    databases = Databases(client);
    realtime = Realtime(client);
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction,
      {int? index}) async {
    var document = await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: {
          "user": transaction.user,
          "amount": transaction.amount,
          "title": transaction.title,
        });

    return _createTransactionFromDocument(document);
  }

  @override
  Future<void> deleteTransaction(Transaction transaction) async {
    await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: transaction.id);
  }

  @override
  Stream<List<Transaction>> getTransactions() async* {
    final subscription = realtime.subscribe(
        ['databases.$databaseId.collections.$collectionId.documents']);

    yield* subscription.stream
        .asyncMap((event) => _getTransactionList())
        .startWith(await _getTransactionList());
  }

  Future<List<Transaction>> _getTransactionList() async {
    final transactionDocuments = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [Query.orderDesc("\$createdAt")]);

    final expenses = transactionDocuments.documents
        .map(_createTransactionFromDocument)
        .toList();

    return expenses;
  }

  Transaction _createTransactionFromDocument(Document document) {
    return Transaction(document.$id, document.data["user"],
        document.data["title"], (document.data["amount"] as num).toDouble());
  }
}
