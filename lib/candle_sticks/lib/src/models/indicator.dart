// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:quant_finance/candle_sticks/lib/candlesticks.dart';

class Indicator {
  /// Indicator name. visible at top right side of chart
  final String name;

  /// Calculates indicator value for givien index.
  /// if your indicator has muliple lines (values) always return results in the same order.
  final List<double?> Function(int index, List<Candle> candles) calculator;
  final int dependsOnNPrevCandles;

  /// Indicator lines style.
  /// the order of this should be same as calculator function results order.
  final List<IndicatorStyle> indicatorComponentsStyles;

  Indicator({
    required this.name,
    required this.dependsOnNPrevCandles,
    required this.calculator,
    required this.indicatorComponentsStyles,
  });

  @override
  bool operator ==(other) {
    if (other is Indicator) {
      return other.name == name;
    } else {
      return false;
    }
  }
}

enum IndicatorType { line, signal }

class IndicatorStyle {
  final String name;
  final Color color;
  // indicator type : line or signal
  final IndicatorType indicatorType;

  IndicatorStyle({
    required this.name,
    required this.color,
    required this.indicatorType,
  });
}
