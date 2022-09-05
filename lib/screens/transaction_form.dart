import 'dart:async';

import 'package:bytebankv2/components/response_dialog.dart';
import 'package:bytebankv2/components/transaction_auth_dialog.dart';
import 'package:bytebankv2/http/webclients/transaction_webclient.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../components/progress.dart';
import '../models/Transaction.dart';
import '../models/contact.dart';

class TransactionForm extends StatefulWidget {
  final Contact contact;

  TransactionForm(this.contact);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController _valueController = TextEditingController();
  final TransactionWebClient _webClient = TransactionWebClient();
  final String transactionID = Uuid().v4();
  bool _sending = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('New transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Progress(),
                ),
                visible: _sending,
              ),
              Text(
                widget.contact.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  widget.contact.accountNumber.toString(),
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _valueController,
                  style: TextStyle(fontSize: 24.0),
                  decoration: InputDecoration(labelText: 'Value'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    child: Text('Transfer'),
                    onPressed: () {
                      final double? value =
                          double.tryParse(_valueController.text);
                      final transactionCreated =
                          Transaction(transactionID, value!, widget.contact);
                      showDialog(
                          context: context,
                          builder: (contextDialog) {
                            return TransactionAuthDialog(
                                onConfirm: (String password) {
                              _save(transactionCreated, password, context);
                            });
                          });
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _save(Transaction transactionCreated, String password,
      BuildContext context) async {
    await _send(transactionCreated, password, context);
  }

  Future<void> _send(Transaction transactionCreated, String password,
      BuildContext context) async {
    setState(() {
      _sending = true;
    });
    final Transaction transaction =
        await _webClient.PostTransaction(transactionCreated, password)
            .catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exeption', e.toString());
        FirebaseCrashlytics.instance.setCustomKey('http_code', e.statusCode);
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e, null);
      }
      _showFailureMessage(context,
          message: 'timeout submitting the transaction');
    }, test: (e) => e is TimeoutException).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exeption', e.toString());
        FirebaseCrashlytics.instance.setCustomKey('http_code', e.statusCode);
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e, null);
      }

      _showFailureMessage(context, message: e.message);
    }, test: (e) => e is HttpException).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exeption', e.toString());
        FirebaseCrashlytics.instance.setCustomKey('http_code', e.statusCode);
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e, null);
      }

      _showFailureMessage(context);
    }).whenComplete(() {
      setState(() {
        _sending = false;
      });
    });

    await _showSuccessfulMessage(transaction, context);
  }

  void _showFailureMessage(BuildContext context,
      {String message = 'Unknown error'}) {
    showDialog(
        context: context,
        builder: (contextDialog) {
          return FailureDialog(message);
        });
  }

  Future<void> _showSuccessfulMessage(
      Transaction transaction, BuildContext context) async {
    if (transaction != null) {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            return SuccessDialog('Successful transaction');
          });
      Navigator.pop(context);
    }
  }
}
