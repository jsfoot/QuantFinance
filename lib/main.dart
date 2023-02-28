import 'package:flutter/material.dart';
import 'package:quant_finance/main_screen.dart';

void main() {
  runApp(const QuantFinanceApp());
}

class QuantFinanceApp extends StatelessWidget {
  const QuantFinanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Quant Finance",
      home: MainScreen(),
    );
  }
}
