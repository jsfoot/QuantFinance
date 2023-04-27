import 'dart:ui';
import 'package:quant_finance/candle_sticks/lib/candlesticks.dart';

class MovingAverageIndicatorByHighAndLow extends Indicator {
  MovingAverageIndicatorByHighAndLow({
    required int length,
    required Color colorLow,
    required Color colorHigh,
  }) : super(
          name: "MA H&L $length",
          dependsOnNPrevCandles: length,
          calculator: (index, candles) {
            double sumLow = 0;
            for (int i = 0; i < length; i++) {
              sumLow += candles[i + index].low;
            }
            final lineLow = sumLow / length;

            double sumHigh = 0;
            for (int i = 0; i < length; i++) {
              sumHigh += candles[i + index].high;
            }
            final lineHigh = sumHigh / length;

            return [
              lineLow,
              lineHigh,
            ];
          },
          indicatorComponentsStyles: [
            IndicatorStyle(name: "mvL", color: colorLow, indicatorType: IndicatorType.line),
            IndicatorStyle(name: "mvH", color: colorHigh, indicatorType: IndicatorType.line),
          ],
        );
}
