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

  late List<String> members;

  @override
  void initState() {
    super.initState();
    _computeSummary();
  }

  _computeSummary() async {
    var transactionService = context.read<ITransactionService>();
    groupSummary = transactionService.getGroupSummary();
    group = transactionService.getCurrentGroup();
    members = group.members;
    members.sort((a, b) => _groupMemberCompare(a, b));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: groupSummary,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var summary = snapshot.data!;
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

  int _groupMemberCompare(String memberA, String memberB) {
    if (group.localMember == memberA) {
      return -1;
    }

    if (group.localMember == memberB) {
      return 1;
    }

    return memberA.compareTo(memberB);
  }

  ListTile _getTileForMember(String name, double amount) {
    var color =
        switch (amount) { > 0 => Colors.green, < 0 => Colors.red, _ => null };
    var icon = switch (amount) {
      > 0 => Icons.add,
      < 0 => Icons.remove,
      _ => Icons.done
    };
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        name,
        style: group.localMember == name
            ? const TextStyle(fontWeight: FontWeight.bold)
            : null,
      ),
      trailing: Text(
        "${amount.toStringAsFixed(2)}€",
        style: TextStyle(color: color),
      ),
    );
  }
}
