import 'dart:convert';

import 'package:quant_finance/candle_sticks/lib/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quant_finance/constants/gaps.dart';
import 'package:quant_finance/constants/sizes.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:quant_finance/candle_sticks/lib/src/utils/indicators/horizontal_price_line.dart';
import 'package:quant_finance/candle_sticks/lib/src/utils/indicators/moving_average_indicator_by_high_and_low.dart';
import 'package:quant_finance/candle_sticks/lib/src/utils/indicators/moving_average_indicator_by_low.dart';
import '../models/candle_ticker_model.dart';
import '../repos/repository.dart';

class BinanceChartScreen extends StatefulWidget {
  const BinanceChartScreen({Key? key}) : super(key: key);

  @override
  _BinanceChartScreenState createState() => _BinanceChartScreenState();
}

class _BinanceChartScreenState extends State<BinanceChartScreen> {
  BinanceRepository repository = BinanceRepository();

  List<Candle> candles = [];
  WebSocketChannel? _channel;
  bool themeIsDark = false;
  String currentInterval = "1m";
  final intervals = [
    '1m',
    '3m',
    '5m',
    '15m',
    '30m',
    '1h',
    '2h',
    '4h',
    '6h',
    '8h',
    '12h',
    '1d',
    '3d',
    '1w',
    '1M',
  ];
  String initSymbol = "BTCUSDT";
  List<String> symbols = [];
  String currentSymbol = "";
  List<Indicator> indicators = [
    BollingerBandsIndicator(
      length: 20,
      stdDev: 2,
      upperColor: const Color(0xFF2962FF),
      basisColor: const Color(0xFFFF6D00),
      lowerColor: const Color(0xFF2962FF),
    ),
    WeightedMovingAverageIndicator(
      length: 100,
      color: Colors.green.shade600,
    ),
    MovingAverageIndicator(
      length: 20,
      color: Colors.blue,
    ),
    MovingAverageIndicatorByLow(
      length: 10,
      color: Colors.yellowAccent,
    ),
    MovingAverageIndicatorByHighAndLow(
      length: 10,
      colorLow: Colors.black,
      colorHigh: Colors.red,
    ),
    HorizontalPriceLine(
      price: 29000,
      color: Colors.black,
    ),
  ];
  final GlobalKey<FormState> _maKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _wmaKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _bbKey = GlobalKey<FormState>();

  @override
  void initState() {
    fetchSymbols().then((value) {
      symbols = value;
      if (symbols.isNotEmpty) fetchCandles(initSymbol, currentInterval);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_channel != null) _channel!.sink.close();
    super.dispose();
  }

  Future<List<String>> fetchSymbols() async {
    try {
      // load candles info
      final data = await repository.fetchSymbols();
      return data;
    } catch (e) {
      // handle error
      return [];
    }
  }

  Future<void> fetchCandles(String symbol, String interval) async {
    // close current channel if exists
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    // clear last candle list
    setState(() {
      candles = [];
      currentInterval = interval;
    });

    try {
      // load candles info
      final data = await repository.fetchCandles(symbol: symbol, interval: interval);
      // connect to binance stream
      _channel = repository.establishConnection(symbol.toLowerCase(), currentInterval);
      // update candles
      setState(() {
        candles = data;
        currentInterval = interval;
        currentSymbol = symbol;
      });
    } catch (e) {
      // handle error
      return;
    }
  }

  void updateCandlesFromSnapshot(AsyncSnapshot<Object?> snapshot) {
    if (candles.isEmpty) return;
    if (snapshot.data != null) {
      final map = jsonDecode(snapshot.data as String) as Map<String, dynamic>;
      if (map.containsKey("k") == true) {
        final candleTicker = CandleTickerModel.fromJson(map);

        // cehck if incoming candle is an update on current last candle, or a new one
        if (candles[0].date == candleTicker.candle.date &&
            candles[0].open == candleTicker.candle.open) {
          // update last candle
          candles[0] = candleTicker.candle;
        }
        // check if incoming new candle is next candle so the difrence
        // between times must be the same as last existing 2 candles
        else if (candleTicker.candle.date.difference(candles[0].date) ==
            candles[0].date.difference(candles[1].date)) {
          // add new candle to list
          candles.insert(0, candleTicker.candle);
        }
      }
    }
  }

  Future<void> loadMoreCandles() async {
    try {
      // load candles info
      final data = await repository.fetchCandles(
          symbol: currentSymbol,
          interval: currentInterval,
          endTime: candles.last.date.millisecondsSinceEpoch);
      candles.removeLast();
      setState(() {
        candles.addAll(data);
      });
    } catch (e) {
      // handle error
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeIsDark ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Binance $currentSymbol $currentInterval Chart"),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  themeIsDark = !themeIsDark;
                });
              },
              icon: Icon(
                themeIsDark ? Icons.wb_sunny_sharp : Icons.nightlight_round_outlined,
              ),
            ),
          ],
        ),
        body: Center(
          child: StreamBuilder(
            stream: _channel == null ? null : _channel!.stream,
            builder: (context, snapshot) {
              updateCandlesFromSnapshot(snapshot);
              return Candlesticks(
                chartAdjust: ChartAdjust.visibleRange,
                key: Key(currentSymbol + currentInterval),
                indicators: indicators,
                candles: candles,
                onLoadMoreCandles: loadMoreCandles,
                onRemoveIndicator: (String indicator) {
                  setState(() {
                    indicators = [...indicators];
                    indicators.removeWhere((element) => element.name == indicator);
                  });
                },
                actions: [
                  ToolBarAction(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Center(
                            child: Container(
                              width: 200,
                              color: Theme.of(context).colorScheme.background,
                              child: Wrap(
                                children: intervals
                                    .map(
                                      (e) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 50,
                                          height: 30,
                                          child: RawMaterialButton(
                                            elevation: 0,
                                            fillColor: const Color(0xFF494537),
                                            onPressed: () {
                                              fetchCandles(currentSymbol, e);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              e,
                                              style: const TextStyle(
                                                color: Color(0xFFF0B90A),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      currentInterval,
                    ),
                  ),
                  ToolBarAction(
                    width: 100,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SymbolsSearchModal(
                            symbols: symbols,
                            onSelect: (value) {
                              fetchCandles(value, currentInterval);
                            },
                          );
                        },
                      );
                    },
                    child: Text(
                      currentSymbol,
                    ),
                  ),
                  ToolBarAction(
                    width: 50,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Center(
                            child: Container(
                              width: 450,
                              height: 450,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Center(
                                    child: Text(
                                      "settings indicator",
                                    ),
                                  ),
                                  Gaps.v12,
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Moving Average Line",
                                        style: TextStyle(
                                          fontSize: Sizes.size16,
                                        ),
                                      ),
                                      Gaps.h10,
                                      SizedBox(
                                        width: 50,
                                        child: Card(
                                          child: Form(
                                            key: _maKey,
                                            child: TextFormField(
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                              ],
                                              keyboardType: TextInputType.number,
                                              onSaved: (newValue) {
                                                if (newValue != null) {
                                                  Indicator indicator = MovingAverageIndicator(
                                                    length: int.parse(newValue),
                                                    color: Colors.black,
                                                  );
                                                  indicators.add(indicator);
                                                } else {
                                                  return;
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        child: SizedBox(
                                          child: IconButton(
                                            onPressed: () {
                                              if (_maKey.currentState != null) {
                                                if (_maKey.currentState!.validate()) {
                                                  _maKey.currentState!.save();
                                                }
                                              }
                                            },
                                            icon: const Icon(Icons.add),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.addchart),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class SymbolsSearchModal extends StatefulWidget {
  const SymbolsSearchModal({
    Key? key,
    required this.onSelect,
    required this.symbols,
  }) : super(key: key);

  final Function(String symbol) onSelect;
  final List<String> symbols;

  @override
  State<SymbolsSearchModal> createState() => _SymbolSearchModalState();
}

class _SymbolSearchModalState extends State<SymbolsSearchModal> {
  String symbolSearch = "";
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          height: MediaQuery.of(context).size.height * 0.75,
          color: Theme.of(context).colorScheme.background.withOpacity(0.5),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextField(
                  onChanged: (value) {
                    setState(() {
                      symbolSearch = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  children: widget.symbols
                      .where(
                          (element) => element.toLowerCase().contains(symbolSearch.toLowerCase()))
                      .map((e) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 50,
                              height: 30,
                              child: RawMaterialButton(
                                elevation: 0,
                                fillColor: const Color(0xFF494537),
                                onPressed: () {
                                  widget.onSelect(e);
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    color: Color(0xFFF0B90A),
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({Key? key, required this.onChanged}) : super(key: key);
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      cursorColor: const Color(0xFF494537),
      decoration: const InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          color: Color(0xFF494537),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 3, color: Color(0xFF494537)), //<-- SEE HER
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 3, color: Color(0xFF494537)), //<-- SEE HER
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 3, color: Color(0xFF494537)), //<-- SEE HER
        ),
      ),
      onChanged: onChanged,
    );
  }
}
