import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/services/group_service.dart';
import 'package:splitcount/core/ui/initials_avatar.dart';

class GroupList extends StatefulWidget {
  const GroupList({super.key});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Group>>(
        stream: context.read<IGroupService>().getGroups(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                  );
                },
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  final group = snapshot.data![index];

                  return Dismissible(
                    key: Key(group.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(color: Colors.red),
                    onDismissed: (direction) async {
                      await context.read<IGroupService>().deleteGroup(group);
                    },
                    child: ListTile(
                      leading: InitialsAvatar(text: group.name, radius: 20),
                      title: Text(group.name),

                      trailing: const Icon(Icons.chevron_right),
                      subtitle: group.description != null
                          ? Text(group.description!,
                              overflow: TextOverflow.ellipsis)
                          : null,

                      onTap: () {
                        context.push("/groups/${group.id}");
                      },
                      //trailing: Text(
                      //    "${transaction.amount.toStringAsFixed(2)} ${transaction.currency}"),
                    ),
                  );
                });
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
