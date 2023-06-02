import 'package:flutter/material.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/models/transaction.dart';
import 'package:splitcount/core/services/transaction_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:splitcount/core/ui/connectivity_indicator_scaffold.dart';

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
  late Map<String, bool> transactionUsers;

  bool canSubmit = false;

  @override
  void initState() {
    super.initState();

    _titleInput.addListener(_evaluateSubmitStatus);
    _amountInput.addListener(_evaluateSubmitStatus);

    group = widget.transactionService.getCurrentGroup();
    transactionUser = group.members.first;

    transactionUsers = <String, bool>{};
    for (final member in group.members) {
      transactionUsers[member] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final costs = _getCostPerUser();

    return Material(
      child: ConnectivityIndiactorScaffold(
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
                        return AppLocalizations.of(context)!.titleError;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.title),
                  ),
                  DropdownButton<String>(
                      icon: const Icon(Icons.person),
                      isExpanded: true,
                      value: transactionUser,
                      items: _getDropDownMenuItems(group),
                      onChanged: (selected) =>
                          {setState(() => transactionUser = selected!)}),
                  TextFormField(
                    controller: _amountInput,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.invalidValueError;
                      }

                      if (double.tryParse(value) == null) {
                        return AppLocalizations.of(context)!.invalidValueError;
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.amount,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: transactionUsers.keys.map((String key) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          enabled: _amountInput.text.isNotEmpty,
                          title: Text(key),
                          subtitle: costs != null && transactionUsers[key]!
                              ? Text("${costs.toStringAsFixed(2)}€")
                              : null,
                          value: transactionUsers[key]!,
                          activeColor: Colors.pink,
                          checkColor: Colors.white,
                          onChanged: (bool? value) {
                            setState(() {
                              transactionUsers[key] = value ?? false;
                              _evaluateSubmitStatus();
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
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
                                          _getSelectedTransactionUsers(),
                                          _titleInput.text,
                                          _getAmount(),
                                          DateTime.now(),
                                          group));

                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .transactionCreated(
                                                  createdTransaction.title)),
                                      action: SnackBarAction(
                                          label: AppLocalizations.of(context)!
                                              .undo,
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
                        child: Text(
                            AppLocalizations.of(context)!.createTransaction),
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

  List<String> _getSelectedTransactionUsers() {
    return transactionUsers.keys
        .where((key) => transactionUsers[key] == true)
        .toList();
  }

  double _getAmount() {
    return _amountInput.text.isNotEmpty
        ? double.tryParse(_amountInput.text) ?? 0
        : 0;
  }

  double? _getCostPerUser() {
    var userLength = _getSelectedTransactionUsers().length;
    if (userLength == 0) {
      return null;
    }

    return _getAmount() / userLength;
  }

  void _evaluateSubmitStatus() {
    setState(() {
      canSubmit = _titleInput.text.isNotEmpty &&
          _amountInput.text.isNotEmpty &&
          _getSelectedTransactionUsers().isNotEmpty;
    });
  }
}
