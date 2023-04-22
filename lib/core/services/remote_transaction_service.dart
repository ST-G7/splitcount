import 'package:rxdart/rxdart.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/models/transaction.dart';
import 'package:splitcount/core/services/transaction_service.dart';

import 'package:appwrite/appwrite.dart';

import '../../constants.dart';

class RemoteTransactionService implements ITransactionService {
  static const String transactionCollectionId = "64327dbba600a97fc0fa";

  late Realtime realtime;
  late Databases databases;
  late Group group;

  RemoteTransactionService(this.group) {
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
          "date": transaction.dateTime.toIso8601String(),
          "group": transaction.group.id
        });

    return getTransactionById(document.$id);
  }

  @override
  Future<Transaction> getTransactionById(String id) async {
    final document = await databases.getDocument(
        databaseId: appwriteDatabaseId,
        collectionId: transactionCollectionId,
        documentId: id);

    return Transaction.fromAppwriteDocument(document.data);
  }

  @override
  Future<void> deleteTransaction(Transaction transaction) async {
    await databases.deleteDocument(
        databaseId: appwriteDatabaseId,
        collectionId: transactionCollectionId,
        documentId: transaction.id);
  }

  @override
  Stream<List<Transaction>> getLiveTransactions() async* {
    final subscription = realtime.subscribe([
      'databases.$appwriteDatabaseId.collections.$transactionCollectionId.documents'
    ]);

    yield* subscription.stream
        .asyncMap(_onHandleTransactionListChanged)
        .startWith(await getTransactions());
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    final transactionDocuments = await databases.listDocuments(
        databaseId: appwriteDatabaseId,
        collectionId: transactionCollectionId,
        queries: [Query.orderDesc("date"), Query.equal("group", group.id)]);

    final expenses = transactionDocuments.documents
        .map((document) => Transaction.fromAppwriteDocument(document.data))
        .toList();

    return expenses;
  }

  Future<List<Transaction>> _onHandleTransactionListChanged(
      RealtimeMessage event) {
    // TODO: We don't need to query the entire list again here
    return getTransactions();
  }

  @override
  Future<Group> getCurrentGroup() {
    return Future.value(group);
  }
}
