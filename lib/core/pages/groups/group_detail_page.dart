import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/pages/groups/group_summary_list_page.dart';

import 'package:splitcount/core/pages/transactions/create_transaction_page.dart';
import 'package:splitcount/core/pages/groups/edit_group_page.dart';
import 'package:splitcount/core/pages/transactions/transaction_list.dart';
import 'package:splitcount/core/services/group_service.dart';
import 'package:splitcount/core/services/implementations/impl_transaction_service.dart';
import 'package:splitcount/core/services/transaction_service.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:splitcount/core/ui/choose_local_member_dialog.dart';

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
  TransactionService? _remoteTransactionService;
  late ILocalGroupInformationService _localGroupInformationService;

  @override
  void initState() {
    super.initState();

    _localGroupInformationService =
        context.read<ILocalGroupInformationService>();

    var groupService = context.read<IGroupService>();

    groupService
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
    _remoteTransactionService = TransactionService(group);

    if (group.localMember == null) {
      _showChooseLocalMemberDialog();
    }
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
      create: (_) => transactionService,
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
          Stack(
            children: [
              const TransactionList(),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CurrentUserSaldo(
                  transactionService: transactionService,
                  onTap: () => _showChooseLocalMemberDialog(),
                ),
              )
            ],
          ),
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

  _showChooseLocalMemberDialog() async {
    var group = _group!;
    var member = await showModalBottomSheet<String>(
        context: context, builder: (context) => ChooseLocalGroupMember(group));

    if (member != null) {
      await _setLocalGroupUser(group, member);
    }
  }

  _setLocalGroupUser(Group group, String member) async {
    await _localGroupInformationService.setLocalGroupMember(group, member);

    setState(() {
      group.localMember = member;
    });
  }
}

class CurrentUserSaldo extends StatefulWidget {
  final ITransactionService transactionService;
  final void Function()? onTap;

  const CurrentUserSaldo(
      {required this.transactionService, this.onTap, super.key});

  @override
  State<CurrentUserSaldo> createState() => _CurrentUserSaldoState();
}

class _CurrentUserSaldoState extends State<CurrentUserSaldo> {
  late Stream<double?> stream;

  late Group group = widget.transactionService.getCurrentGroup();

  late BehaviorSubject<String?> member =
      BehaviorSubject.seeded(group.localMember);

  @override
  void initState() {
    super.initState();

    stream = member.switchMap((currentLocalUser) => currentLocalUser != null
        ? widget.transactionService.getSaldoOfUser(currentLocalUser)
        : const Stream.empty());
  }

  @override
  Widget build(BuildContext context) {
    var localMember = member.value;
    if (member.value != group.localMember && group.localMember != null) {
      localMember = group.localMember!;
      member.add(group.localMember);
    }

    if (localMember == null) {
      return Container();
    }

    return StreamBuilder<double?>(
      builder: ((context, snapshot) {
        var value = snapshot.data;

        var saldoTextStyle = value == null || value == 0
            ? null
            : value > 0
                ? const TextStyle(color: Colors.green)
                : const TextStyle(color: Colors.red);

        return ListTile(
          leading: const Icon(Icons.person_pin_circle_sharp),
          onTap: widget.onTap,
          title: Text(localMember!),
          subtitle: value != null
              ? Text(
                  "${value.toStringAsFixed(2)}€",
                  style: saldoTextStyle,
                )
              : const LinearProgressIndicator(),
        );
      }),
      stream: stream,
    );
  }
}
