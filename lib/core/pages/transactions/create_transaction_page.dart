import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/models/transaction.dart';
import 'package:splitcount/core/services/transaction_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateTransactionPage extends StatefulWidget {
  final ITransactionService transactionService;

  const CreateTransactionPage(this.transactionService, {super.key});

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleInput = TextEditingController();
  final TextEditingController _amountInput = TextEditingController();

  late final Group group;
  late String transactionUser;

  bool canSubmit = false;

  @override
  void initState() {
    super.initState();

    controllerListener() {
      setState(() {
        canSubmit = _titleInput.text.isNotEmpty && _amountInput.text.isNotEmpty;
      });
    }

    _titleInput.addListener(controllerListener);
    _amountInput.addListener(controllerListener);

    group = widget.transactionService.getCurrentGroup();
    transactionUser = group.members.first;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.createTransaction),
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
                    controller: _titleInput,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a valid title';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextFormField(
                    controller: _amountInput,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: false, decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp('[0-9]+(,[0-9][0-9])?'))
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid value';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                    ),
                  ),
                  DropdownButton<String>(
                      icon: const Icon(Icons.person),
                      isExpanded: true,
                      value: transactionUser,
                      items: _getDropDownMenuItems(group),
                      onChanged: (selected) =>
                          {setState(() => transactionUser = selected!)}),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: canSubmit
                            ? () async {
                                if (_formKey.currentState!.validate()) {
                                  final scaffoldMessenger =
                                      ScaffoldMessenger.of(context);
                                  final navigator = Navigator.of(context);

                                  final group = widget.transactionService
                                      .getCurrentGroup();
                                  final createdTransaction = await widget
                                      .transactionService
                                      .createTransaction(Transaction(
                                          "",
                                          transactionUser,
                                          _titleInput.text,
                                          double.parse(_amountInput.text),
                                          DateTime.now(),
                                          group));

                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Created ${createdTransaction.title}'),
                                      action: SnackBarAction(
                                          label: 'Undo',
                                          onPressed: () async => {
                                                await widget.transactionService
                                                    .deleteTransaction(
                                                        createdTransaction)
                                              }),
                                    ),
                                  );

                                  navigator.pop();
                                }
                              }
                            : null,
                        child: const Text('Create Entry'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  List<DropdownMenuItem<String>> _getDropDownMenuItems(Group group) {
    return group.members
        .map((member) => DropdownMenuItem<String>(
              value: member,
              child: Text(member),
            ))
        .toList();
  }
}
