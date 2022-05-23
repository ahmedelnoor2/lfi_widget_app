import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/trade/common/header.dart';
import 'package:lyotrade/screens/trade/market_header.dart';
import 'package:lyotrade/screens/trade/open_orders.dart';
import 'package:lyotrade/screens/trade/order_book.dart';
import 'package:lyotrade/screens/trade/trade_form.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Trade extends StatefulWidget {
  static const routeName = '/trade';
  const Trade({Key? key}) : super(key: key);

  @override
  State<Trade> createState() => _TradeState();
}

class _TradeState extends State<Trade> with SingleTickerProviderStateMixin {
  var _channel;

  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  String _lastPrice = '';
  bool _isLastPriceUpdate = false;

  @override
  void initState() {
    connectWebSocket();
    super.initState();
  }

  @override
  void dispose() async {
    if (_channel != null) {
      _channel.sink.close();
    }
    super.dispose();
  }

  Future<void> connectWebSocket() async {
    var public = Provider.of<Public>(context, listen: false);

    _channel = WebSocketChannel.connect(
      Uri.parse('${public.publicInfoMarket["market"]["wsUrl"]}'),
    );

    for (int i = 0; i < public.headerSymbols.length; i++) {
      String marketCoin =
          public.headerSymbols[i]['market'].split('/').join("").toLowerCase();
      _channel.sink.add(jsonEncode({
        "event": "sub",
        "params": {
          "channel": "market_btcusdt_trade_ticker",
          "cb_id": marketCoin,
          "top": 100
        }
      }));
    }
    _channel.sink.add(jsonEncode({
      "event": "sub",
      "params": {"channel": "market_btcusdt_depth_step0", "cb_id": "btcusdt"}
    }));

    _channel.stream.listen((message) {
      extractStreamData(message, public);
    });
    // _channel.stream.listen((message) {
    //   _channel.sink.add('received!');
    // });
  }

  void extractStreamData(streamData, public) async {
    if (streamData != null) {
      var inflated = zlib.decode(streamData as List<int>);
      var data = utf8.decode(inflated);
      if (json.decode(data)['channel'] != null) {
        var marketData = json.decode(data);
        if (marketData['channel'] == 'market_btcusdt_depth_step0') {
          // print(marketData['tick']);
          public.setAsksAndBids(marketData['tick']);
        }
        if (marketData['channel'] == 'market_btcusdt_trade_ticker') {
          public.setLastPrice('${marketData['tick']['data'][0]['price']}');
          setState(() {
            _lastPrice = '${marketData['tick']['data'][0]['price']}';
          });
        }
      }
    }
  }

  void setAmountField(value) {
    setState(() {
      _lastPrice = '$value';
      // _isLastPriceUpdate = true;
    });
  }

  void toggleIsPriceUpdate() {
    print('toggle');
    setState(() {
      _isLastPriceUpdate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var public = Provider.of<Public>(context, listen: true);

    return Scaffold(
      appBar: appHeader(context, _tabController),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MarketHeader(),
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                    width: width * 0.4,
                    child: OrderBook(
                      asks: public.asks,
                      bids: public.bids,
                      lastPrice: public.lastPrice,
                      setAmountField: setAmountField,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    width: width * 0.5,
                    child: TradeForm(
                      lastPrice: _lastPrice,
                      isLastPriceUpdate: _isLastPriceUpdate,
                      toggleIsPriceUpdate: toggleIsPriceUpdate,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: SizedBox(
                height: height,
                child: OpenOrders(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNav(context),
    );
  }
}
