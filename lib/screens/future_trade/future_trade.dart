import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/future_market.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/future_trade/common/future_market_drawer.dart';
import 'package:lyotrade/screens/future_trade/future_header_details.dart';
import 'package:lyotrade/screens/future_trade/future_market_header.dart';
import 'package:lyotrade/screens/future_trade/future_open_orders.dart';
import 'package:lyotrade/screens/future_trade/future_order_book.dart';
import 'package:lyotrade/screens/future_trade/future_trade_form.dart';
import 'package:lyotrade/screens/trade/margin/margin_trade_form.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FutureTrade extends StatefulWidget {
  static const routeName = '/future_trade';
  const FutureTrade({Key? key}) : super(key: key);

  @override
  State<FutureTrade> createState() => _FutureTradeState();
}

class _FutureTradeState extends State<FutureTrade> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _channel;

  @override
  void initState() {
    getAllMarkets();
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
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);

    _channel = WebSocketChannel.connect(
      Uri.parse('${futureMarket.publicInfoMarket["wsUrl"]}'),
    );

    String marketCoin =
        futureMarket.activeMarket['contractOtherName'].toLowerCase();

    _channel.sink.add(jsonEncode({
      "event": "sub",
      "params": {
        "channel": "market_e_${marketCoin}_depth_step0",
        "cb_id": marketCoin
      }
    }));

    _channel.sink.add(jsonEncode({
      "event": "sub",
      "params": {
        "channel": "market_e_${marketCoin}_ticker",
        "cb_id": marketCoin,
      }
    }));

    _channel.stream.listen((message) {
      extractStreamData(message, futureMarket);
    });
  }

  void extractStreamData(streamData, futureMarket) async {
    String marketCoin =
        futureMarket.activeMarket['contractOtherName'].toLowerCase();
    if (streamData != null) {
      // var inflated = zlib.decode(streamData as List<int>);
      var inflated =
          GZipDecoder().decodeBytes(streamData as List<int>, verify: false);
      var data = utf8.decode(inflated);
      if (json.decode(data)['channel'] != null) {
        var marketData = json.decode(data);
        // print(marketData);
        if (marketData['channel'] == 'market_e_${marketCoin}_depth_step0') {
          futureMarket.setAsksAndBids(marketData['tick']);
        }
        // if (marketData['channel'] == 'market_${marketCoin}_trade_ticker') {
        //   public.setLastPrice('${marketData['tick']['data'][0]['price']}');
        // }

        if (marketData['channel'] == 'market_e_${marketCoin}_ticker') {
          futureMarket.setActiveMarketTick(marketData['tick'] ?? []);
          futureMarket.setLastPrice('${marketData['tick']['close']}');
        }
      }
    }
  }

  void updateMarket() {
    if (_channel != null) {
      _channel.sink.close();
    }
    connectWebSocket();
  }

  Future<void> getAllMarkets() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);

    await futureMarket.getPublicInfoMarket();
    connectWebSocket();
    await futureMarket.getPublicSpotInfoMarket();
    await futureMarket.getMarketInfo(
      context,
      futureMarket.activeMarket['id'],
    );
    setAvailalbePrice();
    futureMarket.getUserConfiguration(
        context, auth, futureMarket.activeMarket['id']);
  }

  Future<void> setAvailalbePrice() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);

    if (auth.isAuthenticated) {
      var asset = Provider.of<Asset>(context, listen: false);
      // getOpenPositions
      await futureMarket.getOpenPositions(context, auth);
      await asset.getAccountBalance(
        context,
        auth,
        "${futureMarket.activeMarket['symbol'].split('-')[0]},${futureMarket.activeMarket['symbol'].split('-')[1]}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var futureMarket = Provider.of<FutureMarket>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

    return WillPopScope(
      onWillPop: () {
        return onAndroidBackPress(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: hiddenAppBar(),
        drawer: FutureMarketDrawer(
          scaffoldKey: _scaffoldKey,
          updateMarket: updateMarket,
        ),
        body: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureMarketHeader(scaffoldKey: _scaffoldKey),
                  FutureHeaderDetails(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                        width: width * 0.4,
                        child: FutureOrderBook(
                          asks: futureMarket.asks,
                          bids: futureMarket.bids,
                          lastPrice: futureMarket.lastPrice,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        width: width * 0.58,
                        child: FutureTradeForm(
                          scaffoldKey: _scaffoldKey,
                          lastPrice: futureMarket.lastPrice,
                        ),
                      ),
                    ],
                  ),
                  FutureOpenOrders(),
                ],
              ),
            )),
        bottomNavigationBar: bottomNav(context, auth),
      ),
    );
  }
}
