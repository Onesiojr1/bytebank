import 'dart:convert';

import 'package:bytebankv2/http/webclient.dart';
import 'package:http/http.dart';

import '../../models/Transaction.dart';

class TransactionWebClient {
  Future<List<Transaction>> getAllTransaction() async {
    final Response response =
        await client.get(Uri.parse(baseUrl)).timeout(Duration(seconds: 5));

    final List<dynamic> decodedJson = jsonDecode(response.body);
    final List<Transaction> transactions = decodedJson.map((dynamic json) {
      return Transaction.fromJson(json);
    }).toList();
    return transactions;
  }

  Future<Transaction> PostTransaction(Transaction transaction, String password) async {
    final String transationJson = jsonEncode(transaction.toJson());

    final Response response = await client.post(Uri.parse(baseUrl),
        headers: {
          'Content-type': 'application/json',
          'password': password,
        },
        body: transationJson);

    return Transaction.fromJson(jsonDecode(response.body));
    ;
  }
}
