import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quant_finance/candle_sticks/lib/candlesticks.dart';
import '../models/main_window_indicator.dart';

class MainWindowIndicatorWidget extends LeafRenderObjectWidget {
  final List<IndicatorComponentData> indicatorDatas;
  final int index;
  final double candleWidth;
  final double high;
  final double low;

  const MainWindowIndicatorWidget({
    super.key,
    required this.indicatorDatas,
    required this.index,
    required this.candleWidth,
    required this.low,
    required this.high,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MainWindowIndicatorRenderObject(
      indicatorDatas,
      index,
      candleWidth,
      low,
      high,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    MainWindowIndicatorRenderObject candlestickRenderObject =
        renderObject as MainWindowIndicatorRenderObject;

    candlestickRenderObject._indicatorDatas = indicatorDatas;
    candlestickRenderObject._index = index;
    candlestickRenderObject._candleWidth = candleWidth;
    candlestickRenderObject._high = high;
    candlestickRenderObject._low = low;
    candlestickRenderObject.markNeedsPaint();
    super.updateRenderObject(context, renderObject);
  }
}

class MainWindowIndicatorRenderObject extends RenderBox {
  late List<IndicatorComponentData> _indicatorDatas;
  late int _index;
  late double _candleWidth;
  late double _low;
  late double _high;

  MainWindowIndicatorRenderObject(
    List<IndicatorComponentData> indicatorDatas,
    int index,
    double candleWidth,
    double low,
    double high,
  ) {
    _indicatorDatas = indicatorDatas;
    _index = index;
    _candleWidth = candleWidth;
    _low = low;
    _high = high;
  }

  /// set size as large as possible
  @override
  void performLayout() {
    size = Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    double range = (_high - _low) / size.height;
    for (var element in _indicatorDatas) {
      if (element.visible == false) {
        continue;
      }
      Path? path;
      for (int i = 0; (i + 1) * _candleWidth < size.width; i++) {
        if (i + _index >= element.values.length ||
            i + _index < 0 ||
            element.values[i + _index] == null) continue;
        if (path == null) {
          path = Path()
            ..moveTo(size.width + offset.dx - (i + 0.5) * _candleWidth,
                offset.dy + (_high - element.values[i + _index]!) / range);
        } else {
          path.lineTo(size.width + offset.dx - (i + 0.5) * _candleWidth,
              offset.dy + (_high - element.values[i + _index]!) / range);
        }
      }
      if (path != null) {
        for (var style in element.parentIndicator.indicatorComponentsStyles) {
          if (style.indicatorType == IndicatorType.line) {
            // line indicator part
            context.canvas.drawPath(
                path,
                Paint()
                  ..color = element.color
                  ..strokeWidth = 1
                  ..style = PaintingStyle.stroke);
          } else if (style.indicatorType == IndicatorType.signal) {
            // signal indicator part
            List<Offset> offsetPoints = [];

            for (int i = 0; (i + 1) * _candleWidth < size.width; i++) {
              if (i + _index >= element.values.length ||
                  i + _index < 0 ||
                  element.values[i + _index] == null) continue;
              offsetPoints.add(Offset(size.width - (i + 0.5) * _candleWidth,
                  (_high - element.values[i + _index]!) / range));
            }

            context.canvas.drawPoints(
                PointMode.points, // PointMode.lines : broken line
                offsetPoints,
                Paint()
                  ..color = element.color
                  ..strokeCap = StrokeCap.round
                  ..strokeWidth = 6);
          }
        }
      }
    }

    context.canvas.save();
    context.canvas.restore();
  }
}
