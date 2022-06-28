import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/sidebar.dart';
import 'package:lyotrade/screens/dashboard/announcement.dart';
import 'package:lyotrade/screens/dashboard/assets_info.dart';
import 'package:lyotrade/screens/dashboard/buy_crypto.dart';
import 'package:lyotrade/screens/dashboard/carousal.dart';
import 'package:lyotrade/screens/dashboard/hotlinks.dart';
import 'package:lyotrade/screens/dashboard/latest_listing.dart';
import 'package:lyotrade/screens/dashboard/live_feed.dart';
import 'package:lyotrade/screens/dashboard/search_bar.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:url_launcher/url_launcher.dart';

class Dashboard extends StatefulWidget {
  static const routeName = '/dashboard';
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  var _channel;
  final Uri _url = Uri.parse('https://flutter.dev');

  _handleDrawer() async {
    _key.currentState?.openDrawer();
  }

  @override
  void initState() {
    // checkScreenSize();
    getAssetsRate();
    checkLoginStatus();
    super.initState();
  }

  @override
  void dispose() async {
    if (_channel != null) {
      _channel.sink.close();
    }
    super.dispose();
  }

  Future<void> checkScreenSize() async {
    width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      if (width >= 480) {
        if (await canLaunchUrl(_url)) {
          await launchUrl(_url);
        } else {
          // can't launch url, there is some error
          throw "Could not launch $_url";
        }
      } else {
        getAssetsRate();
        checkLoginStatus();
      }
    } else {
      getAssetsRate();
      checkLoginStatus();
    }
  }

  Future<void> getAssetsRate() async {
    var public = Provider.of<Public>(context, listen: false);
    await public.assetsRate();
    await public.getFiatCoins();
    await public.getPublicInfoMarket();
    if (public.headerSymbols.isEmpty) {
      await setHeaderSymbols();
    }
    connectWebSocket();
  }

  Future<void> setHeaderSymbols() async {
    var public = Provider.of<Public>(context, listen: false);
    List _headerSymbols = [];
    List _headerSybolsToAdd = [];

    for (int i = 0;
        i <
            public
                .publicInfoMarket['market']['home_symbol_show']
                    ['recommend_symbol_list']
                .length;
        i++) {
      _headerSybolsToAdd.add(public.publicInfoMarket['market']
          ['home_symbol_show']['recommend_symbol_list'][i]);
      _headerSymbols.add({
        'coin': public.publicInfoMarket['market']['home_symbol_show']
                ['recommend_symbol_list'][i]
            .split("/")[0],
        'market': public.publicInfoMarket['market']['home_symbol_show']
            ['recommend_symbol_list'][i],
        'price': '0',
        'change': '0',
      });
    }

    for (int i = 0;
        i < public.publicInfoMarket['market']['headerSymbol'].length;
        i++) {
      if (!_headerSybolsToAdd
          .contains(public.publicInfoMarket['market']['headerSymbol'][i])) {
        _headerSybolsToAdd
            .add(public.publicInfoMarket['market']['headerSymbol'][i]);
        _headerSymbols.add({
          'coin': public.publicInfoMarket['market']['headerSymbol'][i]
              .split("/")[0],
          'market': public.publicInfoMarket['market']['headerSymbol'][i],
          'price': '0',
          'change': '0',
        });
      }
    }

    await public.setHeaderSymbols(_headerSymbols);
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

    for (int i = 0; i < public.headerSymbols.length; i++) {
      String marketCoin =
          public.headerSymbols[i]['market'].split('/').join("").toLowerCase();

      _channel.sink.add(jsonEncode({
        "event": "sub",
        "params": {
          "channel": "market_${marketCoin}_ticker",
          "cb_id": marketCoin,
        }
      }));
    }

    _channel.stream.listen((message) {
      extractStreamData(message, public);
    });
  }

  void extractStreamData(streamData, public) async {
    if (streamData != null) {
      var inflated =
          GZipDecoder().decodeBytes(streamData as List<int>, verify: false);
      // var inflated = zlib.decode(streamData as List<int>);
      var data = utf8.decode(inflated);
      // print(data);
      if (json.decode(data)['channel'] != null) {
        var marketData = json.decode(data);
        for (int i = 0; i < public.headerSymbols.length; i++) {
          if (public.headerSymbols[i]['coin'] == 'LYO1') {
            public.setListingSymbol(public.headerSymbols[i]);
          }
          if (marketData['channel'].contains(RegExp(
              "${public.headerSymbols[i]['coin']}",
              caseSensitive: false))) {
            var _headerSymbols = public.headerSymbols;
            _headerSymbols[i]['price'] = '${marketData['tick']['close']}';
            _headerSymbols[i]['change'] =
                '${double.parse(marketData['tick']['rose']) * 100}';
            await public.setHeaderSymbols(_headerSymbols);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

    return Scaffold(
      key: _key,
      appBar: hiddenAppBar(),
      drawer: const SideBar(),
      body: SingleChildScrollView(
        child: Container(
          width: width,
          padding: EdgeInsets.all(width * 0.015),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SearchBar(handleDrawer: _handleDrawer),
              Carousal(),
              Announcement(),
              LiveFeed(
                headerSymbols: public.headerSymbols,
              ),
              BuyCrypto(channel: _channel),
              LatestListing(),
              Hotlinks(channel: _channel),
              AssetsInfo(
                headerSymbols: public.headerSymbols,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNav(context, auth),
    );
  }
}
