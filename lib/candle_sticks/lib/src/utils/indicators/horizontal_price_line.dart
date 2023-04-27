import 'dart:ui';
import 'package:quant_finance/candle_sticks/lib/candlesticks.dart';

class HorizontalPriceLine extends Indicator {
  HorizontalPriceLine({
    required double price,
    required Color color,
  }) : super(
          name: "H_Line $price",
          dependsOnNPrevCandles: 0,
          calculator: (index, candles) {
            double horizontalLine = price;

            return [
              horizontalLine,
            ];
          },
          indicatorComponentsStyles: [
            IndicatorStyle(name: "H_Line", color: color, indicatorType: IndicatorType.line),
          ],
        );
}
