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
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool canSubmit = false;

  @override
  void initState() {
    super.initState();

    controllerListener() {
      setState(() {
        canSubmit =
            _nameController.text.isNotEmpty && _ownerController.text.isNotEmpty;
      });
    }

    _nameController.addListener(controllerListener);
    _ownerController.addListener(controllerListener);
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
                  TextFormField(
                    controller: _ownerController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'this will be omitted in the future'),
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
                                    _ownerController.text, <String>[]));

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
}
