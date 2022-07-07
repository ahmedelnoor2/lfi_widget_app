import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/trade/common/header.dart';
import 'package:lyotrade/screens/trade/common/market_drawer.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:k_chart/chart_translations.dart';
import 'package:k_chart/flutter_k_chart.dart';

class KlineChart extends StatefulWidget {
  static const routeName = '/kline_chart';
  const KlineChart({Key? key}) : super(key: key);

  @override
  State<KlineChart> createState() => _KlineChartState();
}

class _KlineChartState extends State<KlineChart>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  //Kline
  List<KLineEntity> datas = [];
  bool showLoading = true;
  MainState _mainState = MainState.MA;
  bool _volHidden = false;
  SecondaryState _secondaryState = SecondaryState.MACD;
  bool isLine = false;
  bool isChinese = false;
  bool _hideGrid = true;
  bool _showNowPrice = true;
  List<DepthEntity>? _bids, _asks;
  bool isChangeUI = true;
  bool _isTrendLine = false;
  bool _priceLeft = false;
  VerticalTextAlignment _verticalTextAlignment = VerticalTextAlignment.left;

  ChartStyle chartStyle = ChartStyle();
  ChartColors chartColors = ChartColors();
  List<String> symbols = [];
  List latestTrades = [];
  String currentSymbol = '';
  String _currentInterval = '30min';
  List intervals = ['30min'];
  bool themeIsDark = true;
  var _mchannel;
  bool _loadingChart = false;
  bool? _upDirection;
  double _lastPriceCheck = 0.00;

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
      // var inflated = zlib.decode(streamData as List<int>);
      var inflated =
          GZipDecoder().decodeBytes(streamData as List<int>, verify: false);
      var data = utf8.decode(inflated);
      if (json.decode(data)['channel'] != null) {
        var marketData = json.decode(data);
        var marketCoin = public.activeMarket['symbol'];

        if (marketData['channel'] ==
            "market_${marketCoin}_kline_$_currentInterval") {
          var e = marketData['tick'];

          if (datas.isNotEmpty) {
            if (DateTime.parse(e['ds']) ==
                DateTime.fromMillisecondsSinceEpoch(datas.last.time!)) {
              setState(() {
                datas.last = KLineEntity.fromCustom(
                  time: DateTime.parse('${e['ds']}').millisecondsSinceEpoch,
                  high: double.parse('${e['high']}'),
                  low: double.parse('${e['low']}'),
                  open: double.parse('${e['open']}'),
                  close: double.parse('${e['close']}'),
                  vol: double.parse('${e['vol']}'),
                );
              });
              DataUtil.calculate(datas);
            } else {
              setState(() {
                datas.add(
                  KLineEntity.fromCustom(
                    time: DateTime.parse('${e['ds']}').millisecondsSinceEpoch,
                    high: double.parse('${e['high']}'),
                    low: double.parse('${e['low']}'),
                    open: double.parse('${e['open']}'),
                    close: double.parse('${e['close']}'),
                    vol: double.parse('${e['vol']}'),
                  ),
                );
              });
              DataUtil.calculate(datas);
            }
          }
        }

        if (marketData['channel'] == 'market_${marketCoin}_depth_step0') {
          public.setAsksAndBids(marketData['tick']);
        }

        if (marketData['channel'] == 'market_${marketCoin}_ticker') {
          public.setActiveMarketTick(marketData['tick'] ?? []);
          public.setLastPrice('${marketData['tick']['close']}');

          if (_lastPriceCheck >
              double.parse('${marketData['tick']['close']}')) {
            setState(() {
              _upDirection = true;
              _lastPriceCheck = double.parse('${marketData['tick']['close']}');
            });
          } else if (_lastPriceCheck <
              double.parse('${marketData['tick']['close']}')) {
            setState(() {
              _upDirection = false;
              _lastPriceCheck = double.parse('${marketData['tick']['close']}');
            });
          } else {
            setState(() {
              _upDirection = null;
              _lastPriceCheck = double.parse('${marketData['tick']['close']}');
            });
          }
        }

        if (marketData['channel'] == 'market_${marketCoin}_trade_ticker') {
          var _latestTradesAll = latestTrades;
          _latestTradesAll.insertAll(0, marketData['tick']['data']);
          if (_latestTradesAll.length > 21) {
            var _subLastTradesAll = _latestTradesAll.sublist(0, 21);
            setState(() {
              latestTrades = _subLastTradesAll;
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
      chartColors.bgColor = [
        Color.fromARGB(255, 41, 44, 81),
        Color.fromARGB(255, 41, 44, 81),
      ];
    });
    var public = Provider.of<Public>(context, listen: false);

    public
        .fetchKlkines(_currentInterval, public.activeMarket['symbol'])
        .then((value) {
      setState(() {
        datas = List.from(value.reversed);
        intervals = public.publicInfoMarket['market']['klineScale'];
      });
    });

    await public.getKlineData();
    setState(() {
      _loadingChart = false;
    });
    return;
  }

  void updateMarket() {
    if (_mchannel != null) {
      _mchannel.sink.close();
    }
    setState(() {
      datas = [];
      _currentInterval = '30min';
    });
    connectWebSocket();
    getKlineData();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var _currentRoute = ModalRoute.of(context)!.settings.name;

    var public = Provider.of<Public>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

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
      key: _scaffoldKey,
      drawer: MarketDrawer(
        scaffoldKey: _scaffoldKey,
        updateMarket: updateMarket,
      ),
      appBar:
          klineHeader(context, _scaffoldKey, public.activeMarket['showName']),
      body: RefreshIndicator(
        onRefresh: () async {
          getKlineData();
          connectWebSocket();
          await Future.delayed(const Duration(seconds: 2));
        },
        child: SingleChildScrollView(
          child: SizedBox(
            height: height * 1.6,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    public.activeMarketTick.isNotEmpty
                                        ? '${getNumberString(context, double.parse('${public.activeMarketTick['close']}'))}'
                                        : '0.00',
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: _upDirection == false
                                          ? greenIndicator
                                          : _upDirection == true
                                              ? redIndicator
                                              : Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '≈ ${getNumberFormat(context, public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()][public.activeMarket['showName'].split('/')[0]])}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        public.activeMarketTick.isNotEmpty
                                            ? ' ${(double.parse(public.activeMarketTick['rose']) * 100).toStringAsFixed(2)}%'
                                            : '--%',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: public
                                                    .activeMarketTick.isNotEmpty
                                                ? double.parse(
                                                            public.activeMarketTick[
                                                                    'rose'] ??
                                                                '0') >
                                                        0
                                                    ? greenIndicator
                                                    : redIndicator
                                                : secondaryTextColor),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.only(right: 15),
                                width: width * 0.4,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 2),
                                              child: Text(
                                                '24h High',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              public.activeMarketTick.isNotEmpty
                                                  ? '${getNumberString(context, double.parse('${public.activeMarketTick['high']}'))}'
                                                  : '0.00',
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
                                                padding:
                                                    EdgeInsets.only(bottom: 2),
                                                child: Text(
                                                  '24h Vol(${public.activeMarket['showName'].split('/')[0]})',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: secondaryTextColor,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                public.activeMarketTick
                                                        .isNotEmpty
                                                    ? '${getNumberString(context, double.parse('${public.activeMarketTick['vol']}'))}'
                                                    : '0.00',
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 2),
                                              child: Text(
                                                '24h Low',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              public.activeMarketTick.isNotEmpty
                                                  ? '${getNumberString(context, double.parse('${public.activeMarketTick['low']}'))}'
                                                  : '0.00',
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
                                                padding:
                                                    EdgeInsets.only(bottom: 2),
                                                child: Text(
                                                  '24h Vol(${public.activeMarket['showName'].split('/')[1]})',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: secondaryTextColor,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                public.activeMarketTick
                                                        .isNotEmpty
                                                    ? '${getNumberString(context, double.parse('${public.activeMarketTick['amount']}'))}'
                                                    : '0.00',
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
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 26, 29, 63)),
                              // padding: EdgeInsets.all(5),
                              height: 30,
                              child: Row(
                                children: [
                                  TextButton(
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
                                                                  datas = [];
                                                                  _currentInterval =
                                                                      e;
                                                                });
                                                                if (_mchannel !=
                                                                    null) {
                                                                  _mchannel.sink
                                                                      .close();
                                                                }
                                                                setState(() {
                                                                  datas = [];
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
                                      _currentInterval,
                                      style: TextStyle(
                                        color: linkColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: width * 0.87,
                              child: _loadingChart
                                  ? Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    )
                                  : KChartWidget(
                                      datas, // Required，Data must be an ordered list，(history=>now)
                                      chartStyle, // Required for styling purposes
                                      chartColors, // Required for styling purposes
                                      isLine:
                                          isLine, // Decide whether it is k-line or time-sharing
                                      mainState:
                                          _mainState, // Decide what the main view shows
                                      secondaryState:
                                          _secondaryState, // Decide what the sub view shows
                                      fixedLength:
                                          2, // Displayed decimal precision
                                      timeFormat:
                                          TimeFormat.YEAR_MONTH_DAY_WITH_HOUR,
                                      isTapShowInfoDialog: true,
                                      materialInfoDialog: false,
                                      onLoadMore: (bool
                                          a) {}, // Called when the data scrolls to the end. When a is true, it means the user is pulled to the end of the right side of the data. When a
                                      // is false, it means the user is pulled to the end of the left side of the data.
                                      maDayList: [
                                        7,
                                        25,
                                        99,
                                      ], // Display of MA,This parameter must be equal to DataUtil.calculate‘s maDayList
                                      translations:
                                          kChartTranslations, // Graphic language
                                      volHidden: false, // hide volume
                                      showNowPrice: true, // show now price
                                      isOnDrag:
                                          (isDrag) {}, // true is on Drag.Don't load data while Draging.
                                      onSecondaryTap:
                                          () {}, // on secondary rect taped.
                                      isTrendLine:
                                          false, // You can use Trendline by long-pressing and moving your finger after setting true to isTrendLine property.
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.83,
                  child: Card(
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
                          height: height * 0.758,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: 10, top: 10),
                                        width: width * 0.5,
                                        child: Text(
                                          'Bid',
                                          style: TextStyle(
                                              color: secondaryTextColor),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top: 10),
                                        width: width * 0.5,
                                        child: Text(
                                          'Ask',
                                          style: TextStyle(
                                              color: secondaryTextColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: 10, top: 5),
                                        width: width * 0.50,
                                        child: Column(
                                          children: bids
                                              .map(
                                                (bid) => Stack(
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
                                                                        '${bid[1]}') >
                                                                    10
                                                                ? double.parse(
                                                                        '${bid[1]}')
                                                                    .toStringAsFixed(
                                                                        2)
                                                                : double.parse(
                                                                        '${bid[1]}')
                                                                    .toStringAsPrecision(
                                                                        4),
                                                            style: TextStyle(
                                                              color:
                                                                  secondaryTextColor,
                                                            ),
                                                          ),
                                                          Text(
                                                            double.parse(
                                                                    '${bid[0]}')
                                                                .toStringAsPrecision(
                                                                    7),
                                                            style: TextStyle(
                                                              color:
                                                                  greenlightchartColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Container(
                                                        color: Color.fromARGB(
                                                            71, 72, 163, 65),
                                                        width: ((double.parse(
                                                                        '${bid[1]}') /
                                                                    double.parse(
                                                                        '$bidMax')) *
                                                                2) *
                                                            100,
                                                        height: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.only(right: 10, top: 5),
                                        width: width * 0.50,
                                        child: Column(
                                          children: asks
                                              .map(
                                                (ask) => Stack(
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
                                                                    '${ask[0]}')
                                                                .toStringAsPrecision(
                                                                    7),
                                                            style: TextStyle(
                                                              color: errorColor,
                                                            ),
                                                          ),
                                                          Text(
                                                            double.parse(
                                                                        '${ask[1]}') >
                                                                    10
                                                                ? double.parse(
                                                                        '${ask[1]}')
                                                                    .toStringAsFixed(
                                                                        2)
                                                                : double.parse(
                                                                        '${ask[1]}')
                                                                    .toStringAsPrecision(
                                                                        4),
                                                            style: TextStyle(
                                                              color:
                                                                  secondaryTextColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Container(
                                                        color: Color.fromARGB(
                                                            73, 175, 86, 76),
                                                        width: ((double.parse(
                                                                        '${ask[1]}') /
                                                                    double.parse(
                                                                        '$askMax')) *
                                                                2) *
                                                            100,
                                                        height: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: 10, top: 10),
                                        width: width * 0.33,
                                        child: Text(
                                          'Time',
                                          style: TextStyle(
                                              color: secondaryTextColor),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top: 10),
                                        width: width * 0.33,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Price',
                                            style: TextStyle(
                                                color: secondaryTextColor),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.only(top: 10, right: 10),
                                        width: width * 0.33,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            'Quantity',
                                            style: TextStyle(
                                                color: secondaryTextColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: latestTrades.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 10, top: 5),
                                            width: width * 0.33,
                                            child: Text(
                                              '${DateFormat('hh:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(latestTrades[index]['ts']))}',
                                              style: TextStyle(
                                                  color: secondaryTextColor),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(top: 5),
                                            width: width * 0.33,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${getNumberString(context, double.parse('${latestTrades[index]['price']}'))}',
                                                style: TextStyle(
                                                    color: latestTrades[index]
                                                                ['side'] ==
                                                            'SELL'
                                                        ? errorColor
                                                        : greenlightchartColor),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 5, right: 10),
                                            width: width * 0.33,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                double.parse(
                                                        '${latestTrades[index]['vol']}')
                                                    .toStringAsFixed(6),
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          _currentRoute == '/market' ? bottomNav(context, auth) : null,
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
