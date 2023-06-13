import 'package:flutter/material.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/models/transaction.dart';
import 'package:splitcount/core/services/transaction_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:splitcount/core/ui/circular_icon_button.dart';
import 'package:splitcount/core/ui/connectivity_indicator_scaffold.dart';
import 'package:collection/collection.dart';

class TransactionEditorPage extends StatefulWidget {
  final ITransactionService transactionService;
  final Transaction? editingTransaction;

  const TransactionEditorPage(this.transactionService,
      {this.editingTransaction, super.key});

  @override
  State<TransactionEditorPage> createState() => _TransactionEditorPageState();
}

class _TransactionEditorPageState extends State<TransactionEditorPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleInput = TextEditingController();
  final TextEditingController _amountInput = TextEditingController();

  late final Group group;
  late String transactionUser;
  late Map<String, bool> transactionUsers;

  bool canSubmit = false;

  int selectedCategoryIndex = 0;

  late bool isEdit = widget.editingTransaction != null;

  @override
  void initState() {
    super.initState();

    _titleInput.addListener(_evaluateSubmitStatus);
    _amountInput.addListener(_evaluateSubmitStatus);

    transactionUsers = <String, bool>{};

    if (isEdit) {
      final editingTransaction = widget.editingTransaction!;
      group = editingTransaction.group;
      transactionUser = editingTransaction.user;

      _titleInput.text = editingTransaction.title;
      _amountInput.text = editingTransaction.amount.toString();

      for (final member in group.members) {
        transactionUsers[member] = editingTransaction.users.contains(member);
      }

      selectedCategoryIndex = transactionCategories
          .indexWhere((cat) => cat.value == editingTransaction.category.value);
    } else {
      group = widget.transactionService.getCurrentGroup();
      transactionUser = group.localMember ?? group.members.first;

      for (final member in group.members) {
        transactionUsers[member] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final costs = _getCostPerUser();

    return Material(
      child: ConnectivityIndiactorScaffold(
          appBar: AppBar(
            title: Text(isEdit
                ? AppLocalizations.of(context)!.editTransaction
                : AppLocalizations.of(context)!.createTransaction),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: transactionCategories
                          .mapIndexed((index, category) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularIconButton(
                                  category.icon,
                                  active: index == selectedCategoryIndex,
                                  size: 42,
                                  onTap: () {
                                    setState(() {
                                      selectedCategoryIndex = index;
                                    });
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
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
                              : Text("${0.toStringAsFixed(2)}€"),
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
                        onPressed: canSubmit ? () => _onSubmit() : null,
                        child: Text(isEdit
                            ? AppLocalizations.of(context)!.editTransaction
                            : AppLocalizations.of(context)!.createTransaction),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final navigator = Navigator.of(context);

      final transaction = Transaction(
          widget.editingTransaction?.id ?? "",
          transactionUser,
          _getSelectedTransactionUsers(),
          _titleInput.text,
          _getAmount(),
          widget.editingTransaction?.dateTime ?? DateTime.now(),
          group,
          transactionCategories[selectedCategoryIndex]);

      if (!isEdit) {
        await _createTransaction(transaction);
      } else {
        await _editTransaction(transaction);
      }

      navigator.pop();
    }
  }

  _createTransaction(Transaction transaction) async {
    var appLocalizations = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final createdTransaction =
        await widget.transactionService.createTransaction(transaction);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content:
            Text(appLocalizations.transactionCreated(createdTransaction.title)),
        action: SnackBarAction(
            label: appLocalizations.undo,
            onPressed: () async => {
                  await widget.transactionService
                      .deleteTransaction(createdTransaction)
                }),
      ),
    );
  }

  _editTransaction(Transaction transaction) async {
    var appLocalizations = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final editedTransaction =
        await widget.transactionService.editTransaction(transaction);
    final previousTransaction = widget.editingTransaction;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content:
            Text(appLocalizations.transactionEdited(editedTransaction.title)),
        action: SnackBarAction(
            label: appLocalizations.undo,
            onPressed: () async => {
                  await widget.transactionService
                      .editTransaction(previousTransaction!)
                }),
      ),
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
