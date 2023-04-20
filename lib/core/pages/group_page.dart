import 'dart:math';

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

                  return Dismissible(
                    key: Key(group.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(color: Colors.red),
                    onDismissed: (direction) async {
                      final messenger = ScaffoldMessenger.of(context);
                      await context.read<IGroupService>().deleteGroup(group);

                      messenger.showSnackBar(SnackBar(
                        content: Text('Group ${group.groupName} was deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () async {
                            await context
                                .read<IGroupService>()
                                .createGroup(group, index: index);
                          },
                        ),
                      ));
                    },
                    child: ListTile(
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
                    ),
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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _groupName = TextEditingController();
  final TextEditingController _groupOwner = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Create Group'),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    autofocus: true,
                    controller: _groupName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a valid group name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Group Name'),
                  ),
                  TextFormField(
                    controller: _groupOwner,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'this will be omitted in the future'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);

                            final createdGroup = await context
                                .read<IGroupService>()
                                .createGroup(Group(
                                    Random()
                                        .nextInt(10000000)
                                        .toString(), // TODO: This should be handled better
                                    _groupName.text,
                                    _groupOwner.text,
                                    <String>[]));

                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content:
                                    Text('Created ${createdGroup.groupName}'),
                                action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () async => {
                                          //TODO: lt. stackoverflow: "First of all, never call async methods inside of build as mentioned."
                                          await context // TODO: this breaks when "undoing" the current transaction
                                              .read<IGroupService>()
                                              .deleteGroup(createdGroup)
                                        }),
                              ),
                            );

                            navigator.pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).primaryIconTheme.color,
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 1.0,
                        ),
                        child: const Text('Create Entry'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
