import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/group.dart';

class ChooseLocalGroupMember extends StatelessWidget {
  final Group group;

  const ChooseLocalGroupMember(this.group, {super.key});

  @override
  Widget build(BuildContext context) {
    var members = group.members;

    List<Widget> widgets = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          AppLocalizations.of(context)!.groupChooseIdentityText,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      )
    ];

    for (var i = 0; i < members.length; i++) {
      var member = members[i];
      widgets.add(ListTile(
        leading: const Icon(Icons.person),
        title: Text(member),
        onTap: () => Navigator.pop(context, member),
      ));
    }

    widgets.add(Container(
      height: 1,
      color: Theme.of(context).dividerColor,
    ));
    widgets.add(ListTile(
      leading: const Icon(Icons.no_accounts_rounded),
      title: Text(AppLocalizations.of(context)!.groupContinueAsGuest),
      onTap: () => Navigator.pop(context, null),
    ));

    return Column(children: widgets);
  }
}
