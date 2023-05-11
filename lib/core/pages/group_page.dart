import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/pages/create_group_page.dart';
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

                      trailing: const Icon(Icons.chevron_right),
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
