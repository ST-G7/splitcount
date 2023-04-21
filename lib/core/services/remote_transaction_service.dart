import 'package:rxdart/rxdart.dart';
import 'package:splitcount/core/models/transaction.dart';
import 'package:splitcount/core/services/transaction_service.dart';

import 'package:appwrite/appwrite.dart';

import '../../constants.dart';

class RemoteTransactionService implements ITransactionService {
  static const String transactionCollectionId = "64327dbba600a97fc0fa";

  late Realtime realtime;
  late Databases databases;

  RemoteTransactionService() {
    databases = Databases(appwriteClient);
    realtime = Realtime(appwriteClient);
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction,
      {int? index}) async {
    var document = await databases.createDocument(
        databaseId: appwriteDatabaseId,
        collectionId: transactionCollectionId,
        documentId: ID.unique(),
        data: {
          "user": transaction.user,
          "amount": transaction.amount,
          "title": transaction.title,
          "date": transaction.dateTime.toIso8601String()
        });

    return Transaction.fromAppwriteDocument(document);
  }

  @override
  Future<void> deleteTransaction(Transaction transaction) async {
    await databases.deleteDocument(
        databaseId: appwriteDatabaseId,
        collectionId: transactionCollectionId,
        documentId: transaction.id);
  }

  @override
  Stream<List<Transaction>> getTransactions() async* {
    final subscription = realtime.subscribe([
      'databases.$appwriteDatabaseId.collections.$transactionCollectionId.documents'
    ]);

    yield* subscription.stream
        .asyncMap(_onHandleTransactionListChanged)
        .startWith(await _getTransactionList());
  }

  Future<List<Transaction>> _getTransactionList() async {
    final transactionDocuments = await databases.listDocuments(
        databaseId: appwriteDatabaseId,
        collectionId: transactionCollectionId,
        queries: [Query.orderDesc("date")]);

    final expenses = transactionDocuments.documents
        .map(Transaction.fromAppwriteDocument)
        .toList();

    return expenses;
  }

  Future<List<Transaction>> _onHandleTransactionListChanged(
      RealtimeMessage event) {
    // TODO: We don't need to query the entire list again here
    return _getTransactionList();
  }
}
