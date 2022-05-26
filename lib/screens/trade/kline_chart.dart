import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/trade/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:candlesticks/candlesticks.dart';

class KlineChart extends StatefulWidget {
  static const routeName = '/kline_chart';
  const KlineChart({Key? key}) : super(key: key);

  @override
  State<KlineChart> createState() => _KlineChartState();
}

class _KlineChartState extends State<KlineChart>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  List<Candle> candles = [];
  List<String> symbols = [];
  List latestTrades = [];
  String currentSymbol = '';
  String _currentInterval = '30min';
  List intervals = ['30min'];
  List<Indicator>? indicators = [
    // BollingerBandsIndicator(
    //   length: 20,
    //   stdDev: 2,
    //   upperColor: const Color(0xFF2962FF),
    //   basisColor: const Color(0xFFFF6D00),
    //   lowerColor: const Color(0xFF2962FF),
    // ),
    // WeightedMovingAverageIndicator(
    //   length: 100,
    //   color: Colors.green.shade600,
    // ),
    MovingAverageIndicator(
      length: 7,
      color: Color.fromARGB(255, 255, 255, 255),
    ),
    MovingAverageIndicator(
      length: 25,
      color: Colors.green.shade600,
    ),
    MovingAverageIndicator(
      length: 99,
      color: Colors.pink.shade600,
    ),
  ];
  bool themeIsDark = true;
  var _mchannel;
  bool _loadingChart = false;

  @override
  void initState() {
    getKlineData();
    connectWebSocket();
    super.initState();
  }

  @override
  void dispose() async {
    if (_mchannel != null) {
      _mchannel.sink.close();
    }
    super.dispose();
  }

  Future<void> connectWebSocket() async {
    var public = Provider.of<Public>(context, listen: false);

    _mchannel = WebSocketChannel.connect(
      Uri.parse('${public.publicInfoMarket["market"]["wsUrl"]}'),
    );

    var marketCoin = public.activeMarket['symbol'];

    _mchannel.sink.add(jsonEncode({
      "event": "sub",
      "params": {
        "channel": "market_${marketCoin}_kline_$_currentInterval",
        "cb_id": public.activeMarket['symbol'],
      }
    }));

    _mchannel.sink.add(jsonEncode({
      "event": "sub",
      "params": {
        "channel": "market_${marketCoin}_depth_step0",
        "cb_id": marketCoin
      }
    }));

    _mchannel.sink.add(jsonEncode({
      "event": "sub",
      "params": {
        "channel": "market_${marketCoin}_ticker",
        "cb_id": marketCoin,
      }
    }));

    _mchannel.sink.add(jsonEncode({
      "event": "sub",
      "params": {
        "channel": "market_${marketCoin}_trade_ticker",
        "cb_id": marketCoin,
      }
    }));

    _mchannel.stream.listen((message) {
      extractStreamData(message, public);
    });
  }

  void extractStreamData(streamData, public) async {
    if (streamData != null) {
      var inflated = zlib.decode(streamData as List<int>);
      var data = utf8.decode(inflated);
      if (json.decode(data)['channel'] != null) {
        var marketData = json.decode(data);
        var marketCoin = public.activeMarket['symbol'];

        if (marketData['channel'] ==
            "market_${marketCoin}_kline_$_currentInterval") {
          var e = marketData['tick'];
          if (candles.isNotEmpty) {
            if (DateTime.parse(e['ds']) == candles[0].date) {
              setState(() {
                candles[0] = Candle(
                  date: DateTime.parse(e['ds']),
                  high: double.parse('${e['high']}'),
                  low: double.parse('${e['low']}'),
                  open: double.parse('${e['open']}'),
                  close: double.parse('${e['close']}'),
                  volume: double.parse('${e['vol']}'),
                );
              });
            } else {
              setState(() {
                candles.insert(
                    0,
                    Candle(
                      date: DateTime.parse(e['ds']),
                      high: double.parse('${e['high']}'),
                      low: double.parse('${e['low']}'),
                      open: double.parse('${e['open']}'),
                      close: double.parse('${e['close']}'),
                      volume: double.parse('${e['vol']}'),
                    ));
              });
            }
          }
        }

        if (marketData['channel'] == 'market_${marketCoin}_depth_step0') {
          public.setAsksAndBids(marketData['tick']);
        }

        if (marketData['channel'] == 'market_${marketCoin}_ticker') {
          public.setActiveMarketTick(marketData['tick'] ?? []);
          public.setLastPrice('${marketData['tick']['close']}');
        }

        if (marketData['channel'] == 'market_${marketCoin}_trade_ticker') {
          var _latestTradesAll = latestTrades;
          _latestTradesAll.addAll(marketData['tick']['data']);
          if (_latestTradesAll.length > 30) {
            _latestTradesAll.sublist(0, 30);
            setState(() {
              latestTrades = _latestTradesAll;
            });
          } else {
            setState(() {
              latestTrades = _latestTradesAll;
            });
          }
        }
      }
    }
  }

  Future<void> getKlineData() async {
    setState(() {
      _loadingChart = true;
    });
    var public = Provider.of<Public>(context, listen: false);
    public
        .fetchCandles(_currentInterval, public.activeMarket['symbol'])
        .then((value) {
      setState(() {
        candles = value;
        intervals = public.publicInfoMarket['market']['klineScale'];
      });
    });
    await public.getKlineData();
    setState(() {
      _loadingChart = false;
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var public = Provider.of<Public>(context, listen: true);

    List? asks = public.asks;
    List? bids = public.bids;

    var bidMax = bids.isNotEmpty
        ? (bids.reduce((current, next) =>
            double.parse('${current[1]}') > double.parse('${next[1]}')
                ? current
                : next)[1])
        : 0;
    var askMax = asks.isNotEmpty
        ? (asks.reduce((current, next) =>
            double.parse('${current[1]}') > double.parse('${next[1]}')
                ? current
                : next)[1])
        : 0;

    return Scaffold(
      appBar: klineHeader(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 5),
              child: Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      height: width * 0.2,
                      padding: EdgeInsets.only(
                        left: width * 0.05,
                        top: 10,
                      ),
                      margin: EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                '${getNumberString(context, double.parse('${public.activeMarketTick['close']}'))}',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: (double.parse(
                                                '${public.activeMarketTick['close']}') ==
                                            double.parse(
                                                '${public.activeMarketTick['open']}'))
                                        ? Colors.white
                                        : (((double.parse('${public.activeMarketTick['open']}') -
                                                        double.parse(
                                                            '${public.activeMarketTick['close']}')) /
                                                    double.parse(
                                                        '${public.activeMarketTick['open']}')) >
                                                0)
                                            ? greenlightchartColor
                                            : errorColor),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '≈ ${getNumberFormat(context, public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()][public.activeMarket['showName'].split('/')[0]])}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    ' ${(double.parse(public.activeMarketTick['rose']) * 100).toStringAsFixed(2)}%',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: double.parse(
                                                    public.activeMarketTick[
                                                            'rose'] ??
                                                        '0') >
                                                0
                                            ? greenlightchartColor
                                            : errorColor),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 15),
                            width: width * 0.4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(bottom: 2),
                                          child: Text(
                                            '24h High',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${getNumberString(context, double.parse('${public.activeMarketTick['high']}'))}',
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: 18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(bottom: 2),
                                            child: Text(
                                              '24h Vol(${public.activeMarket['showName'].split('/')[0]})',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${getNumberString(context, double.parse('${public.activeMarketTick['vol']}'))}',
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(bottom: 2),
                                          child: Text(
                                            '24h Low',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${getNumberString(context, double.parse('${public.activeMarketTick['low']}'))}',
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: 18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(bottom: 2),
                                            child: Text(
                                              '24h Vol(${public.activeMarket['showName'].split('/')[1]})',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${getNumberString(context, double.parse('${public.activeMarketTick['amount']}'))}',
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        bottom: 15,
                      ),
                      height: width * 0.9,
                      child: _loadingChart
                          ? CircularProgressIndicator.adaptive()
                          : Candlesticks(
                              style: CandleSticksStyle(
                                borderColor: Color(0xFF848E9C),
                                background: Color.fromARGB(255, 41, 44, 81),
                                primaryBull: Color(0xFF26A69A),
                                secondaryBull: Color(0xFF005940),
                                primaryBear: Color(0xFFEF5350),
                                secondaryBear: Color(0xFF82122B),
                                hoverIndicatorBackgroundColor:
                                    Color(0xFF4C525E),
                                primaryTextColor: Color(0xFF848E9C),
                                secondaryTextColor: Color(0XFFFFFFFF),
                                mobileCandleHoverColor:
                                    Color(0xFFF0B90A).withOpacity(0.2),
                                loadingColor: Color(0xFFF0B90A),
                                toolBarColor: Color.fromARGB(255, 26, 29, 63),
                              ),
                              candles: candles,
                              indicators: indicators,
                              actions: [
                                ToolBarAction(
                                  width: 50,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Center(
                                          child: Container(
                                            width: 200,
                                            color: Theme.of(context)
                                                .backgroundColor,
                                            child: Wrap(
                                              children: intervals
                                                  .map((e) => Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: SizedBox(
                                                          width: 50,
                                                          height: 30,
                                                          child:
                                                              RawMaterialButton(
                                                            elevation: 0,
                                                            fillColor:
                                                                const Color(
                                                                    0xFF494537),
                                                            onPressed:
                                                                () async {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();

                                                              setState(() {
                                                                candles = [];
                                                                _currentInterval =
                                                                    e;
                                                              });
                                                              if (_mchannel !=
                                                                  null) {
                                                                _mchannel.sink
                                                                    .close();
                                                              }
                                                              setState(() {
                                                                candles = [];
                                                                _currentInterval =
                                                                    e;
                                                              });
                                                              await getKlineData();
                                                              connectWebSocket();
                                                            },
                                                            child: Text(
                                                              e,
                                                              style:
                                                                  const TextStyle(
                                                                color: Color(
                                                                    0xFFF0B90A),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ))
                                                  .toList(),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    '$_currentInterval',
                                    style: TextStyle(color: secondaryTextColor),
                                  ),
                                ),
                                // ToolBarAction(
                                //   width: 100,
                                //   onPressed: () {
                                //     showDialog(
                                //       context: context,
                                //       builder: (context) {
                                //         return SymbolsSearchModal(
                                //           symbols: symbols,
                                //           onSelect: (value) {
                                //             // fetchCandles(value, currentInterval);
                                //             getKlineData();
                                //           },
                                //         );
                                //       },
                                //     );
                                //   },
                                //   child: Text(
                                //     currentSymbol,
                                //   ),
                                // )
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  TabBar(
                    onTap: (value) {
                      //
                    },
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'Order Book'),
                      Tab(text: 'Trades'),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.75,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 10, top: 10),
                                  width: width * 0.5,
                                  child: Text(
                                    'Bid',
                                    style: TextStyle(color: secondaryTextColor),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 10),
                                  width: width * 0.5,
                                  child: Text(
                                    'Ask',
                                    style: TextStyle(color: secondaryTextColor),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 10, top: 5),
                                  width: width * 0.50,
                                  child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: bids.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Stack(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                  bottom: 2, right: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    double.parse(
                                                                '${bids[index][1]}') >
                                                            10
                                                        ? double.parse(
                                                                '${bids[index][1]}')
                                                            .toStringAsFixed(2)
                                                        : double.parse(
                                                                '${bids[index][1]}')
                                                            .toStringAsPrecision(
                                                                4),
                                                    style: TextStyle(
                                                      color: secondaryTextColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    double.parse(
                                                            '${bids[index][0]}')
                                                        .toStringAsPrecision(7),
                                                    style: TextStyle(
                                                      color:
                                                          greenlightchartColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                color: Color.fromARGB(
                                                    71, 72, 163, 65),
                                                width: ((double.parse(
                                                                '${bids[index][1]}') /
                                                            double.parse(
                                                                '$bidMax')) *
                                                        2) *
                                                    100,
                                                height: 20,
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 10, top: 5),
                                  width: width * 0.50,
                                  child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: asks.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Stack(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                  bottom: 2, left: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    double.parse(
                                                            '${asks[index][0]}')
                                                        .toStringAsPrecision(7),
                                                    style: TextStyle(
                                                      color: errorColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    double.parse(
                                                                '${asks[index][1]}') >
                                                            10
                                                        ? double.parse(
                                                                '${asks[index][1]}')
                                                            .toStringAsFixed(2)
                                                        : double.parse(
                                                                '${asks[index][1]}')
                                                            .toStringAsPrecision(
                                                                4),
                                                    style: TextStyle(
                                                      color: secondaryTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                color: Color.fromARGB(
                                                    73, 175, 86, 76),
                                                width: ((double.parse(
                                                                '${asks[index][1]}') /
                                                            double.parse(
                                                                '$askMax')) *
                                                        2) *
                                                    100,
                                                height: 20,
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              ],
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 10, top: 10),
                                  width: width * 0.33,
                                  child: Text(
                                    'Time',
                                    style: TextStyle(color: secondaryTextColor),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 10),
                                  width: width * 0.33,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Price',
                                      style:
                                          TextStyle(color: secondaryTextColor),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 10, right: 10),
                                  width: width * 0.33,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Quantity',
                                      style:
                                          TextStyle(color: secondaryTextColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
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
          color: Theme.of(context).backgroundColor.withOpacity(0.5),
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
                      .where((element) => element
                          .toLowerCase()
                          .contains(symbolSearch.toLowerCase()))
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
          borderSide:
              BorderSide(width: 3, color: Color(0xFF494537)), //<-- SEE HER
        ),
        border: OutlineInputBorder(
          borderSide:
              BorderSide(width: 3, color: Color(0xFF494537)), //<-- SEE HER
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(width: 3, color: Color(0xFF494537)), //<-- SEE HER
        ),
      ),
      onChanged: onChanged,
    );
  }
}
