import 'package:flutter/material.dart';

class IndicatorSettingsScreen extends StatefulWidget {
  const IndicatorSettingsScreen({Key? key}) : super(key: key);

  @override
  State<IndicatorSettingsScreen> createState() => _IndicatorSettingsScreenState();
}

class _IndicatorSettingsScreenState extends State<IndicatorSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Indicator Setting"),
      ),
      body: const Center(
        child: Text("Indicator Setting"),
      ),
    );
  }
}
