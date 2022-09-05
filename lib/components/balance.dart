import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/balance.dart';

class BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<Balance>(builder: (context, value, child) {
            return Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            );
          })),
    );
  }
}
