import 'dart:async';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/models/summary.dart';
import 'package:splitcount/core/models/transaction.dart';
import 'package:splitcount/core/services/transaction_service.dart';

import 'package:appwrite/appwrite.dart';

import 'package:splitcount/constants.dart';

class TransactionService implements ITransactionService {
  static const String transactionCollectionId = "64327dbba600a97fc0fa";
  static const String calculateSummaryFunctionId = "6468b30dbb01fb4f48a8";

  late Realtime realtime;
  late Databases databases;
  late Group group;
  late Functions functions;

  RealtimeSubscription? _subscription;

  TransactionService(this.group) {
    databases = Databases(appwriteClient);
    realtime = Realtime(appwriteClient);
    functions = Functions(appwriteClient);
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
          "group": transaction.group.id,
          "users": transaction.users,
          "category": transaction.category.value
        });

    return getTransactionById(document.$id);
  }

  @override
  Future<Transaction> editTransaction(Transaction transaction) async {
    var document = await databases.updateDocument(
        databaseId: appwriteDatabaseId,
        collectionId: transactionCollectionId,
        documentId: transaction.id,
        data: {
          "user": transaction.user,
          "amount": transaction.amount,
          "title": transaction.title,
          "date": transaction.dateTime.toIso8601String(),
          "group": transaction.group.id,
          "users": transaction.users,
          "category": transaction.category.value
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
    _subscription ??= realtime.subscribe([
      'databases.$appwriteDatabaseId.collections.$transactionCollectionId.documents'
    ]);

    yield* _subscription!.stream
        .asyncMap(_onHandleTransactionListChanged)
        .shareValueSeeded(await getTransactions());
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
  Group getCurrentGroup() {
    return group;
  }

  @override
  Future<GroupSummary> getGroupSummary() async {
    var requestData = {"groupId": group.id};
    var jsonData = jsonEncode(requestData);

    var result = await functions.createExecution(
        functionId: calculateSummaryFunctionId, data: jsonData);

    return GroupSummary.fromData(jsonDecode(result.response));
  }

  dispose() {
    try {
      //_subscription?.close();
    }
    // ignore: empty_catches
    catch (_) {}
  }

  @override
  Stream<double> getSaldoOfUser(String member) {
    return getLiveTransactions()
        .asyncMap((_) => getGroupSummary())
        .map((summary) => summary.saldo[member] ?? 0);
  }
}
