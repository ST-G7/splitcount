import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/models/summary.dart';
import 'package:splitcount/core/services/transaction_service.dart';

class GroupSummaryList extends StatefulWidget {
  final String groupId;

  const GroupSummaryList(this.groupId, {super.key});

  @override
  State<GroupSummaryList> createState() => _GroupSummaryListState();
}

class _GroupSummaryListState extends State<GroupSummaryList> {
  late Future<GroupSummary> groupSummary;
  late Group group;

  @override
  void initState() {
    super.initState();
    _computeSummary();
  }

  _computeSummary() async {
    var transactionService = context.read<ITransactionService>();
    groupSummary = transactionService.getGroupSummary();
    group = transactionService.getCurrentGroup();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: groupSummary,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var summary = snapshot.data!;
            var members = group.members;
            return Column(
              children: members
                  .map(
                    (member) =>
                        _getTileForMember(member, summary.saldo[member] ?? 0),
                  )
                  .toList(),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  ListTile _getTileForMember(String name, double amount) {
    var positive = amount >= 0;
    var color = !positive ? Colors.red : Colors.green;
    return ListTile(
      leading: Icon(
        (positive ? Icons.add : Icons.remove),
        color: color,
      ),
      title: Text(name),
      trailing: Text(
        "${amount.toStringAsFixed(2)}€",
        style: TextStyle(color: color),
      ),
    );
  }
}
