import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/utils/AppConstant.utils.dart';

class Public with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
  };

  Map _rate = {};
  Map _publicInfoMarket = {};
  Map _allMarkets = {};
  List _currencies = [];
  Map _activeCurrency = {
    "fiat_symbol": "usd",
    "icon": "/upload/aa.jpg",
    "fiat_icon": "\$",
  };
  Map _activeMarket = {
    "showName": "BTC/USDT",
    "symbol": "btcusdt",
  };
  Map _activeMarketTick = {};
  Map _activeMarketAllTicks = {};

  List _headerSymbols = [];

  List _asks = [];
  List _bids = [];
  String _lastPrice = '0';

  Map get rate {
    return _rate;
  }

  Map get activeCurrency {
    return _activeCurrency;
  }

  List get currencies {
    return _currencies;
  }

  Map get publicInfoMarket {
    return _publicInfoMarket;
  }

  List get headerSymbols {
    return _headerSymbols;
  }

  List get asks {
    return _asks;
  }

  List get bids {
    return _bids;
  }

  String get lastPrice {
    return _lastPrice;
  }

  Map get activeMarket {
    return _activeMarket;
  }

  Map get activeMarketTick {
    return _activeMarketTick;
  }

  Map get activeMarketAllTicks {
    return _activeMarketAllTicks;
  }

  Map get allMarkets {
    return _allMarkets;
  }

  Future<void> setHeaderSymbols(headerSymb) async {
    _headerSymbols = headerSymb;
    return notifyListeners();
  }

  Future<void> setAsksAndBids(tickerData) async {
    _asks = tickerData['asks'];
    _bids = tickerData['buys'];
    notifyListeners();
  }

  Future<void> setLastPrice(price) async {
    _lastPrice = price;
    notifyListeners();
  }

  Future<void> setActiveMarket(market) async {
    _activeMarket = market;
    return notifyListeners();
  }

  Future<void> setActiveMarketTick(tick) async {
    _activeMarketTick = tick;
    notifyListeners();
  }

  Future<void> setActiveMarketAllTicks(tick, market) async {
    _activeMarketAllTicks[market.split('_')[1]] = tick;
    notifyListeners();
  }

  Future<void> changeCurrency(fiatSymbol) async {
    _activeCurrency = _currencies.firstWhere(
      (currency) => currency['fiat_symbol'] == fiatSymbol,
    );
    return notifyListeners();
  }

  Future<void> getFiatCoins() async {
    var url = Uri.https(
      apiUrl,
      '$exApi/common/getFaitCoinList',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);
      if (responseData['code'] == "0") {
        _currencies = responseData['data'];
        return notifyListeners();
      }
    } catch (error) {
      // throw error;
      return;
    }
  }

  Future<void> getPublicInfoMarket() async {
    var url = Uri.https(
      apiUrl,
      '$exApi/common/public_info_market',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == "0") {
        _publicInfoMarket = responseData['data'];

        var _allMarketsMap =
            Map<String, dynamic>.from(responseData['data']['market']['market']);

        for (var k in _allMarketsMap.keys) {
          _allMarkets[k] = [];
          var _allMarketsMapo = Map<String, dynamic>.from(_allMarketsMap[k]);
          for (var m in _allMarketsMapo.values) {
            _allMarkets[k].add(m);
          }
        }
        // responseData['data']['market']['market'].values((val) => print(val));
        // _allMarketsMap.values((_allMarketVal) {
        //   var _allMarketValMap = Map<String, dynamic>.from(_allMarketVal);
        //   var alMarket =
        //       _allMarketValMap.map((mkey, _allMarketValO) => _allMarketValO);
        //   print(alMarket);
        //   // print(_allMarketValMap['HNT/USDT']);
        //   // return _allMarketVal;
        // });
        // print(_allMarketsMap.runtimeType);

        return notifyListeners();
      }
    } catch (error) {
      // throw error;
      return;
    }
  }

  Future<void> assetsRate() async {
    var url = Uri.https(
      apiUrl,
      '$exApi/common/rateV2',
    );

    var postData = json.encode({
      "fiat": _activeCurrency['fiat_symbol'].toUpperCase(),
    });

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == "0") {
        _rate = responseData['data']['rate'];
        return notifyListeners();
      }
    } catch (error) {
      // throw error;
      return;
    }
  }
}
