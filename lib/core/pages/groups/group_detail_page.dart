import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/constants.dart';
import 'package:splitcount/core/models/group.dart';

import 'package:splitcount/core/pages/transactions/create_transaction_page.dart';
import 'package:splitcount/core/pages/groups/edit_group_page.dart';
import 'package:splitcount/core/pages/transactions/transaction_list.dart';
import 'package:splitcount/core/services/group_service.dart';
import 'package:splitcount/core/services/transaction_service.dart';
import 'package:splitcount/core/services/remote_transaction_service.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

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

  late Future<Group> groupFuture;

  @override
  void initState() {
    super.initState();
    groupFuture = context.read<IGroupService>().getGroupById(widget._groupId);

    _controller =
        TabController(length: 2, vsync: this, initialIndex: _selectedTabIndex);
    _controller.addListener(() => setState(() {
          _selectedTabIndex = _controller.index;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Group>(
      future: groupFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text("")),
            body: const Center(child: Text("Loading Group ...")),
          );
        }

        var group = snapshot.data!;
        var remoteTransactionService = RemoteTransactionService(group);
        return Provider<ITransactionService>(
          create: (_) => remoteTransactionService,
          child: Scaffold(
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
              GroupSummary(widget._groupId)
            ]),
            floatingActionButton: _selectedTabIndex == 0
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateTransactionPage(
                                remoteTransactionService)),
                      );
                    },
                    child: const Icon(Icons.add),
                  )
                : null,
          ),
        );
      },
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

class GroupSummary extends StatefulWidget {
  final String groupId;

  const GroupSummary(this.groupId, {super.key});

  @override
  State<GroupSummary> createState() => _GroupSummaryState();
}

class _GroupSummaryState extends State<GroupSummary> {
  String summaryText = "Loading ...";

  @override
  void initState() {
    super.initState();
    _computeSummary();
  }

  _computeSummary() async {
    var function = Functions(appwriteClient);

    var calculateSummaryId = "6468b30dbb01fb4f48a8";
    var requestData = {"groupId": widget.groupId};
    var jsonData = jsonEncode(requestData);

    var result = await function.createExecution(
        functionId: calculateSummaryId, data: jsonData);

    setState(() {
      summaryText = result.response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(summaryText),
    );
  }
}
