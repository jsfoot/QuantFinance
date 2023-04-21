import 'package:flutter/material.dart';
import 'package:quant_finance/common/main_navigation_screen.dart';

void main() {
  runApp(const QuantFinanceApp());
}

class QuantFinanceApp extends StatelessWidget {
  const QuantFinanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      title: "Crypto Quant",
      home: const MainNavigationScreen(),
    );
  }
}
