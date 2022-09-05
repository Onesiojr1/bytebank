import 'dart:async';

import 'package:bytebankv2/screens/dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:provider/provider.dart';

import 'models/balance.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FirebaseCrashlytics.instance.setUserIdentifier('alura123');
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    }

    runApp(ChangeNotifierProvider(
      create: (context) => Balance(0),
      child: BytebankApp(),
    ));
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class BytebankApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
        ).copyWith(
          secondary: Colors.blueAccent[700],
        ),
        buttonTheme: ButtonThemeData(
            buttonColor: Colors.blueAccent[700],
            textTheme: ButtonTextTheme.primary),
      ),
      home: Dashboard(),
    );
  }
}
