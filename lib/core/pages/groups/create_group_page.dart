import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/services/group_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _newMemberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool canSubmit = false;

  final members = <String>{};

  late final FocusNode addUserTextfieldFocusNode;

  @override
  void initState() {
    super.initState();

    addUserTextfieldFocusNode = FocusNode();

    controllerListener() {
      setState(() {
        canSubmit = _nameController.text.isNotEmpty && members.isNotEmpty;
      });
    }

    _nameController.addListener(controllerListener);
    _newMemberController.addListener(controllerListener);
  }

  @override
  void dispose() {
    addUserTextfieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var groupService = context.read<IGroupService>();

    return Material(
      child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.createGroup),
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
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a valid group name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.groupName),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.groupDescription),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text("Users"),
                  ),
                  Flexible(
                    child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (_, index) {
                          final member = members.toList()[index];

                          return ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              title: Text(member),
                              subtitle: index == 0 ? const Text("Owner") : null,
                              leading: index == 0
                                  ? const Icon(Icons.engineering)
                                  : const Icon(Icons.person),
                              trailing: ElevatedButton.icon(
                                label: const Text("Remove"),
                                icon: const Icon(Icons.person_remove),
                                onPressed: () => _removeMember(member),
                              ));
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(
                            height: 1,
                          );
                        },
                        itemCount: members.length),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: TextFormField(
                          focusNode: addUserTextfieldFocusNode,
                          controller: _newMemberController,
                          onFieldSubmitted: (_) => _addMember(),
                          decoration:
                              const InputDecoration(labelText: 'User Name'),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addMember,
                        icon: const Icon(Icons.person_add),
                        label: const Text("Add User"),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: canSubmit
                            ? () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                final navigator = Navigator.of(context);
                                await groupService.createGroup(Group(
                                    "",
                                    _nameController.text,
                                    _descriptionController.text,
                                    members.first, // TODO: Do we need an owner?
                                    members.toList()));

                                navigator.pop();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).primaryIconTheme.color,
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 1.0,
                        ),
                        child: Text(AppLocalizations.of(context)!.create),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  _addMember() {
    var memberName = _newMemberController.text;
    if (memberName.isEmpty) {
      // TODO: We should probably show some kind of error
      return;
    }

    if (members.contains(memberName)) {
      // TODO: We should probably show some kind of error
      return;
    }

    setState(() {
      members.add(memberName);
      _newMemberController.clear();
    });

    addUserTextfieldFocusNode.requestFocus();
  }

  _removeMember(String memberName) {
    if (!members.contains(memberName)) {
      return;
    }

    setState(() {
      members.remove(memberName);
    });
  }
}
