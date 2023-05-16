import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/services/group_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.editGroup),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
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

                                var group = widget.group;

                                group.name = _nameController.text;
                                group.description = _descriptionController.text;

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
          )),
    );
  }
}
