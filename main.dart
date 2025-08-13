import 'package:flutter/material.dart';
import 'flutter_finance_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FinanceHome(),
    );
  }
}
