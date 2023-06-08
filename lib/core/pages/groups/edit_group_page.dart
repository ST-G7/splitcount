import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/services/group_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:splitcount/core/ui/connectivity_indicator_scaffold.dart';

class EditGroupPage extends StatefulWidget {
  final Group group;

  const EditGroupPage(this.group, {super.key});

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool canSubmit = false;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.group.name;
    _descriptionController.text = widget.group.description ?? "";

    controllerListener() {
      setState(() {
        canSubmit = _nameController.text.isNotEmpty;
      });
    }

    _nameController.addListener(controllerListener);
  }

  @override
  Widget build(BuildContext context) {
    var groupService = context.read<IGroupService>();

    return Material(
      child: ConnectivityIndiactorScaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.editGroup),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        autofocus: true,
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .invalidGroupName;
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
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: canSubmit
                                ? () async {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }

                                    var group = widget.group;

                                    group.name = _nameController.text;
                                    group.description =
                                        _descriptionController.text;

                                    final navigator = Navigator.of(context);
                                    await groupService.updateGroup(group);

                                    navigator.pop(group);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).primaryIconTheme.color,
                              backgroundColor: Theme.of(context).primaryColor,
                              elevation: 1.0,
                            ),
                            child: Text(AppLocalizations.of(context)!.save),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.symmetric(vertical: 16.0),
                  child: Container(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.dangerZone,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: Theme.of(context).colorScheme.error),
                ),
                Container(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showConfirmDeleteGroupDialog(context, widget.group),
                    icon: const Icon(Icons.delete),
                    label: Text(AppLocalizations.of(context)!.deleteGroup),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  Future _showConfirmDeleteGroupDialog(
    BuildContext context,
    Group group,
  ) async {
    final groupService = context.read<IGroupService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteGroup),
        content: Text(AppLocalizations.of(context)!.confirmGroupDelete),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await groupService.deleteGroup(group);
      if (context.mounted) context.go('/');
    }
  }
}
