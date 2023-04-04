import 'package:appwrite/models.dart';

class Transaction {
  // This id will probably be generated by a backend in future
  late final String id;

  final String? emoji;
  final String user;
  final String title;
  final double amount;
  final String currency;
  final DateTime dateTime;

  Transaction(this.id, this.user, this.title, this.amount, this.dateTime,
      {this.emoji, this.currency = "€"});

  factory Transaction.fromAppwriteDocument(Document document) {
    return Transaction(
        document.$id,
        document.data["user"],
        document.data["title"],
        (document.data["amount"] as num).toDouble(),
        DateTime.parse(document.data["date"] as String));
  }
}