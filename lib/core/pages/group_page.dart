import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/pages/settings_page.dart';
import 'package:splitcount/core/pages/transaction_page.dart';
import 'package:splitcount/core/services/group_service.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupOverviewPage extends StatefulWidget {
  const GroupOverviewPage({
    super.key,
  });

  @override
  State<GroupOverviewPage> createState() => _GroupOverviewPageState();
}

class _GroupOverviewPageState extends State<GroupOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.groups),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              tooltip: AppLocalizations.of(context)!.settings,
              onPressed: _showSettingsPage)
        ],
      ),
      body: const GroupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupPage,
        child: const Icon(Icons.add),
      ),
    );
  }

  _showSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  _showCreateGroupPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupPage()),
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
                      leading: Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColorLight),
                          child: const Align(alignment: Alignment.center)),
                      title: Text(group.name),

                      subtitle: Text(group.members.join(", "),
                          overflow: TextOverflow.ellipsis),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionPage(group),
                          ),
                        );
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
    var groupService = context.read<IGroupService>();

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
                            final navigator = Navigator.of(context);
                            await groupService.createGroup(Group("",
                                _groupName.text, _groupOwner.text, <String>[]));

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
