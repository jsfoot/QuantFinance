import 'dart:ui';
import 'package:quant_finance/candle_sticks/lib/candlesticks.dart';

class MovingAverageIndicatorByLow extends Indicator {
  MovingAverageIndicatorByLow({
    required int length,
    required Color color,
  }) : super(
          name: "MA Low $length",
          dependsOnNPrevCandles: length,
          calculator: (index, candles) {
            double sum = 0;
            for (int i = 0; i < length; i++) {
              sum += candles[i + index].low;
            }
            return [sum / length];
          },
          indicatorComponentsStyles: [
            IndicatorStyle(name: "mvL", color: color, indicatorType: IndicatorType.line),
          ],
        );
}
