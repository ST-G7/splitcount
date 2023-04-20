import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/pages/transaction_page.dart';
import 'package:splitcount/core/services/group_service.dart';
import 'package:splitcount/main.dart';

class GroupOverviewPage extends StatefulWidget {
  const GroupOverviewPage({super.key, required this.title});

  final String title;

  @override
  State<GroupOverviewPage> createState() => _GroupOverviewPageState();
}

class _GroupOverviewPageState extends State<GroupOverviewPage> {
  @override
  Widget build(BuildContext context) {
    final isLightMode = selectedTheme.value == ThemeMode.light;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
            icon: Icon(isLightMode
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded),
            tooltip: isLightMode ? 'Enable dark mode' : 'Enable light mode',
            onPressed: () async {
              await setSelectedTheme(
                  isLightMode ? ThemeMode.dark : ThemeMode.light);
              setState(() => {});
            }),
      ),
      body: const GroupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGroupPage()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GroupList extends StatefulWidget {
  const GroupList({super.key});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Group>>(
        //TODO: is this correct, or should we use "StreamProvider" instead?
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
                padding: const EdgeInsets.only(right: 40.0),
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  final group = snapshot.data![index];

                  return ListTile(
                    leading: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColorLight),
                        child: const Align(alignment: Alignment.center)),
                    title: Text(group.groupName),

                    subtitle: Text(group.members.join(", "),
                        overflow: TextOverflow.ellipsis),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TransactionPage(title: group.groupName),
                        ),
                      );
                    },
                    //trailing: Text(
                    //    "${transaction.amount.toStringAsFixed(2)} ${transaction.currency}"),
                  );
                });
          } else {
            return const Text("No data available");
          }
        });
  }
}

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
