import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/pages/groups/group_summary_list_page.dart';

import 'package:splitcount/core/pages/transactions/create_transaction_page.dart';
import 'package:splitcount/core/pages/groups/edit_group_page.dart';
import 'package:splitcount/core/pages/transactions/transaction_list.dart';
import 'package:splitcount/core/services/group_service.dart';
import 'package:splitcount/core/services/transaction_service.dart';
import 'package:splitcount/core/services/remote_transaction_service.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../ui/connectivity_indicator_scaffold.dart';

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage(this._groupId, {super.key});

  final String _groupId;

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  var _selectedTabIndex = 0;

  Group? _group;
  RemoteTransactionService? _remoteTransactionService;

  @override
  void initState() {
    super.initState();
    context
        .read<IGroupService>()
        .getGroupById(widget._groupId)
        .then((group) => {setState(() => _onGroupLoaded(group))});

    _controller =
        TabController(length: 2, vsync: this, initialIndex: _selectedTabIndex);
    _controller.addListener(() => setState(() {
          _selectedTabIndex = _controller.index;
        }));
  }

  _onGroupLoaded(Group group) {
    _group = group;
    _remoteTransactionService = RemoteTransactionService(group);
  }

  @override
  void dispose() {
    super.dispose();
    _remoteTransactionService?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_group == null || _remoteTransactionService == null) {
      return ConnectivityIndiactorScaffold(
        appBar: AppBar(title: const Text("")),
        body: const Center(child: Text("Loading Group ...")),
      );
    }

    Group group = _group!;
    ITransactionService transactionService = _remoteTransactionService!;

    return Provider<ITransactionService>(
      create: (_) => transactionService!,
      child: ConnectivityIndiactorScaffold(
        appBar: AppBar(
          title: Text(group.name),
          actions: [
            IconButton(
                onPressed: () async {
                  final link = kIsWeb
                      ? Uri.base.toString()
                      : 'https://splitcount.web.app/groups/${group.id}';
                  return Share.share(link,
                      subject: "${group.name} - Splitcount");
                },
                icon: const Icon(Icons.share),
                tooltip: AppLocalizations.of(context)!.shareGroup),
            IconButton(
                icon: const Icon(Icons.edit_square),
                tooltip: AppLocalizations.of(context)!.settings,
                onPressed: () => _showGroupSettings(group))
          ],
          bottom: TabBar(
            controller: _controller,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: <Tab>[
              Tab(text: AppLocalizations.of(context)!.transactions),
              Tab(text: AppLocalizations.of(context)!.overview),
            ],
          ),
        ),
        body: TabBarView(controller: _controller, children: [
          const TransactionList(),
          GroupSummaryList(widget._groupId)
        ]),
        floatingActionButton: _selectedTabIndex == 0
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CreateTransactionPage(transactionService)),
                  );
                },
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  _showGroupSettings(Group group) async {
    var updatedGroup = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditGroupPage(group)),
    );

    if (updatedGroup != null) {
      setState(() {
        group = updatedGroup;
      });
    }
  }
}
