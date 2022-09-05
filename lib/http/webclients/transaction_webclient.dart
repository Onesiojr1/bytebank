import 'dart:convert';

import 'package:bytebankv2/http/webclient.dart';
import 'package:http/http.dart';

import '../../models/Transaction.dart';

class TransactionWebClient {
  Future<List<Transaction>> getAllTransaction() async {
    final Response response =
        await client.get(Uri.parse(baseUrl));

    final List<dynamic> decodedJson = jsonDecode(response.body);
    final List<Transaction> transactions = decodedJson.map((dynamic json) {
      return Transaction.fromJson(json);
    }).toList();
    return transactions;
  }

  Future<Transaction> PostTransaction(
      Transaction transaction, String password) async {
    final String transationJson = jsonEncode(transaction.toJson());

    await Future.delayed(Duration( seconds:2));

    final Response response = await client.post(Uri.parse(baseUrl),
        headers: {
          'Content-type': 'application/json',
          'password': password,
        },
        body: transationJson);

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    }
    throw HttpException(_getMessage(response.statusCode));
  }

  String? _getMessage(int statusCode) {
    if(_statusCodeResponses.containsValue(statusCode)) {
      return _statusCodeResponses[statusCode];
    }
    return 'Unknown error';
  }

  Exception _trowHttpError(int statusCode) {
    throw Exception(_statusCodeResponses[statusCode]);
  }

  static final Map<int, String> _statusCodeResponses = {
    400: 'there was an error submitting transaction',
    401: 'Authentication failed',
    409: 'transaction already exists'
  };
} 

class HttpException implements Exception {
  final String? message;

  HttpException(this.message);
}
