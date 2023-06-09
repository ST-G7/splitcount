import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/services/group_service.dart';
import 'package:splitcount/core/ui/initials_avatar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

                  return ListTile(
                    leading: InitialsAvatar(text: group.name, radius: 20),
                    title: Text(group.name),
                    trailing: const Icon(Icons.chevron_right),
                    subtitle: group.description == null ||
                            group.description!.isEmpty
                        ? Text(AppLocalizations.of(context)!.noGroupDescription,
                            overflow: TextOverflow.ellipsis)
                        : Text(group.description!,
                            overflow: TextOverflow.ellipsis),
                    onTap: () => context.push("/groups/${group.id}"),
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
