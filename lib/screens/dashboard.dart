import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/sidebar.dart';
import 'package:lyotrade/screens/dashboard/assets_info.dart';
import 'package:lyotrade/screens/dashboard/buy_crypto.dart';
import 'package:lyotrade/screens/dashboard/live_feed.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Dashboard extends StatefulWidget {
  static const routeName = '/dashboard';
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  var _channel;
  List _headerSymbols = [];

  _handleDrawer() async {
    _key.currentState?.openDrawer();
  }

  @override
  void initState() {
    getAssetsRate();
    checkLoginStatus();
    super.initState();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  Future<void> getAssetsRate() async {
    var public = Provider.of<Public>(context, listen: false);
    await public.assetsRate();
    await public.getFiatCoins();
    await public.getPublicInfoMarket();
    await setHeaderSymbols();
    connectWebSocket();
  }

  Future<void> setHeaderSymbols() async {
    var public = Provider.of<Public>(context, listen: false);

    for (int i = 0;
        i < public.publicInfoMarket['market']['headerSymbol'].length;
        i++) {
      _headerSymbols.add({
        'coin':
            public.publicInfoMarket['market']['headerSymbol'][i].split("/")[0],
        'market': public.publicInfoMarket['market']['headerSymbol'][i],
        'price': '0',
        'change': '0',
      });
      setState(() {
        _headerSymbols = _headerSymbols;
      });
    }
    return;
  }

  Future<void> checkLoginStatus() async {
    var auth = Provider.of<Auth>(context, listen: false);
    await auth.checkLogin(context);
  }

  Future<void> connectWebSocket() async {
    var public = Provider.of<Public>(context, listen: false);

    _channel = WebSocketChannel.connect(
      Uri.parse('${public.publicInfoMarket["market"]["wsUrl"]}'),
    );

    for (int i = 0;
        i < public.publicInfoMarket['market']['headerSymbol'].length;
        i++) {
      String marketCoin = public.publicInfoMarket['market']['headerSymbol'][i]
          .split('/')
          .join("")
          .toLowerCase();
      _channel.sink.add(jsonEncode({
        "event": "sub",
        "params": {
          "channel": "market_${marketCoin}_ticker",
          "cb_id": marketCoin,
        }
      }));
    }
    _channel.sink.add(jsonEncode({
      "event": "sub",
      "params": {"channel": "market_btcusdt_ticker", "cb_id": "btcusdt"}
    }));

    _channel.stream.listen((message) {
      extractStreamData(message);
    });
    // _channel.stream.listen((message) {
    //   _channel.sink.add('received!');
    // });
  }

  void extractStreamData(streamData) async {
    if (streamData != null) {
      var inflated = zlib.decode(streamData as List<int>);
      var data = utf8.decode(inflated);
      if (json.decode(data)['channel'] != null) {
        var marketData = json.decode(data);
        for (int i = 0; i < _headerSymbols.length; i++) {
          if (marketData['channel'].contains(
              RegExp("${_headerSymbols[i]['coin']}", caseSensitive: false))) {
            setState(() {
              _headerSymbols[i]['price'] = '${marketData['tick']['close']}';
              _headerSymbols[i]['change'] =
                  '${double.parse(marketData['tick']['rose']) * 100}';
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);

    return Scaffold(
      key: _key,
      appBar: appBar(context, _handleDrawer),
      drawer: sideBar(context, auth),
      body: SingleChildScrollView(
        child: Container(
          width: width,
          padding: EdgeInsets.only(
            top: width * 0.02,
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Welcome to LYOTrade!'),
              SizedBox(
                width: width,
                child: LiveFeed(
                  headerSymbols: _headerSymbols,
                ),
              ),
              SizedBox(
                width: width,
                child: const BuyCrypto(),
              ),
              SizedBox(
                width: width,
                child: AssetsInfo(
                  headerSymbols: _headerSymbols,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNav(context),
    );
  }
}
