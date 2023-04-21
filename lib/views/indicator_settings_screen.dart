import 'dart:convert';

import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
