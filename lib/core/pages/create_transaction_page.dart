import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitcount/core/models/transaction.dart';
import 'package:splitcount/core/services/transaction_service.dart';

class CreateTransactionPage extends StatefulWidget {
  final ITransactionService transactionService;

  const CreateTransactionPage(this.transactionService, {super.key});

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _userInput = TextEditingController();
  final TextEditingController _titleInput = TextEditingController();
  final TextEditingController _amountInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Create Transaction'),
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
                  TextFormField(
                    controller: _userInput,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a user';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Person'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);

                            final group = await widget.transactionService
                                .getCurrentGroup();
                            final createdTransaction = await widget
                                .transactionService
                                .createTransaction(Transaction(
                                    "",
                                    _userInput.text,
                                    _titleInput.text,
                                    double.parse(_amountInput.text),
                                    DateTime.now(),
                                    group));

                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content:
                                    Text('Created ${createdTransaction.title}'),
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
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).primaryIconTheme.color,
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 1.0,
                        ),
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
}
