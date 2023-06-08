import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:splitcount/core/pages/groups/group_list.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:splitcount/core/ui/connectivity_indicator_scaffold.dart';

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
    return ConnectivityIndiactorScaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.groups),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              tooltip: AppLocalizations.of(context)!.settings,
              onPressed: () => context.push("/settings"))
        ],
      ),
      body: const GroupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push("/groups/create"),
        child: const Icon(Icons.add),
      ),
    );
  }
}
