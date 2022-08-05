import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart/entity/index.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:lyotrade/utils/Translate.utils.dart';

class Public with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
  };
  Map<String, String> headers1 = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'exchange-token':
        'c5fa97c1140aafea1ef1e84b67503d5e0db18d0ca0ff4819a0ca3f24722407df'
  };
  Map _rate = {};
  Map _publicInfoMarket = {};
  Map _allMarkets = {};
  Map _allMarginMarkets = {};
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

  Map _activeMarginMarket = {
    "showName": "BTC/USDT",
    "symbol": "btcusdt",
  };
  Map _activeMarginMarketTick = {};
  Map _activeMarginMarketAllTicks = {};

  Map _allSearchMarket = {};

  Map _allMarginSearchMarket = {};

  List _headerSymbols = [];

  List _asks = [];
  List _bids = [];
  String _lastPrice = '0';

  List _stakeLists = [];
  Map _stakeInfo = {};

  List _klineData = [];

  String _amountField = '';
  bool _amountFieldUpdate = false;

  Map _listingSymbol = {};

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

  Map get activeMarginMarket {
    return _activeMarginMarket;
  }

  Map get activeMarketTick {
    return _activeMarketTick;
  }

  Map get activeMarginMarketTick {
    return _activeMarginMarketTick;
  }

  Map get activeMarketAllTicks {
    return _activeMarketAllTicks;
  }

  Map get activeMarginMarketAllTicks {
    return _activeMarginMarketAllTicks;
  }

  Map get allMarkets {
    return _allMarkets;
  }

  Map get allMarginMarkets {
    return _allMarginMarkets;
  }

  String get amountField {
    return _amountField;
  }

  bool get amountFieldUpdate {
    return _amountFieldUpdate;
  }

  Map get allSearchMarket {
    return _allSearchMarket;
  }

  Map get allMarginSearchMarket {
    return _allMarginSearchMarket;
  }

  List get klineData {
    return _klineData;
  }

  List get stakeLists {
    return _stakeLists;
  }

  Map get stakeInfo {
    return _stakeInfo;
  }

  Map get listingSymbol {
    return _listingSymbol;
  }

  Future<void> setAmountField(value) async {
    _amountField = '$value';
    _amountFieldUpdate = true;
    return notifyListeners();
  }

  Future<void> amountFieldDisable() async {
    _amountFieldUpdate = false;
    return notifyListeners();
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

  Future<void> setActiveMarginMarket(market) async {
    _activeMarginMarket = market;
    return notifyListeners();
  }

  Future<void> setActiveMarketTick(tick) async {
    _activeMarketTick = tick;
    notifyListeners();
  }

  Future<void> setActiveMarginMarketTick(tick) async {
    _activeMarginMarketTick = tick;
    notifyListeners();
  }

  Future<void> setActiveMarketAllTicks(tick, market) async {
    _activeMarketAllTicks[market.split('_')[1]] = tick;
    notifyListeners();
  }

  Future<void> setActiveMarginMarketAllTicks(tick, market) async {
    _activeMarginMarketAllTicks[market.split('_')[1]] = tick;
    notifyListeners();
  }

  Future<void> changeCurrency(fiatSymbol) async {
    _activeCurrency = _currencies.firstWhere(
      (currency) => currency['fiat_symbol'] == fiatSymbol,
    );
    return notifyListeners();
  }

  Future<void> setAllSearchMarket(allSearchmarket) async {
    _allSearchMarket = allSearchMarket;
    return notifyListeners();
  }

  Future<void> setListingSymbol(listingSymbol) async {
    _listingSymbol = listingSymbol;
    return notifyListeners();
  }

  Future<void> checkSocket(ctx) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/common/checkVisitStatus',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      print(responseData);
    } catch (error) {
      if ('$error'.contains('SocketException')) {
        showAlert(
          ctx,
          Container(),
          'Network Error',
          [
            Text('Please check your network connection.'),
          ],
          'Exit',
        );
      }
      return;
    }
  }

  // Get public info
  Map _publicInfo = {};

  Map get publicInfo {
    return _publicInfo;
  }

  Future<void> getPublicInfo() async {
    var url = Uri.https(
      lyoApiUrl,
      '$lyoPubApi/fePublicInfo/en_US',
    );

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);
      // print(json.decode(response.body.split('window.publicInfo=')[1]));
      _publicInfo = responseData;
      return notifyListeners();
    } catch (error) {
      print(error);
      // throw error;
      return;
    }
  }

  Future<void> filterMarketSearchResults(
    query,
    _searchAllMarkets,
    sMarketSort,
  ) async {
    if (query.isNotEmpty) {
      List dummyListData = [];
      for (var item in _searchAllMarkets) {
        if (item['symbol'].contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      _allSearchMarket[sMarketSort].clear();
      _allSearchMarket[sMarketSort].addAll(dummyListData);
      notifyListeners();
      return;
    } else {
      _allSearchMarket[sMarketSort].clear();
      _allSearchMarket[sMarketSort].addAll(_searchAllMarkets);
      notifyListeners();
      return;
    }
  }

  Future<void> filterMarginMarketSearchResults(
    query,
    _searchAllMarkets,
    sMarketSort,
  ) async {
    if (query.isNotEmpty) {
      List dummyListData = [];
      for (var item in _searchAllMarkets) {
        if (item['symbol'].contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      _allSearchMarket[sMarketSort].clear();
      _allSearchMarket[sMarketSort].addAll(dummyListData);
      notifyListeners();
      return;
    } else {
      _allSearchMarket[sMarketSort].clear();
      _allSearchMarket[sMarketSort].addAll(_searchAllMarkets);
      notifyListeners();
      return;
    }
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
          _allSearchMarket[k] = [];
          _allMarginMarkets[k] = [];
          _allMarginSearchMarket[k] = [];
          var _allMarketsMapo = Map<String, dynamic>.from(_allMarketsMap[k]);
          for (var m in _allMarketsMapo.values) {
            if (m['is_open_lever'] == 1) {
              _allMarginMarkets[k].add(m);
              _allMarginSearchMarket[k].add(m);
            }
            if (m['symbol'] == 'btcusdt') {
              _activeMarket = m;
              _activeMarginMarket = m;
            }
            _allMarkets[k].add(m);
            _allSearchMarket[k].add(m);
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
      print(error);
      return;
    }
  }

  Future<void> getStakeLists() async {
    var url = Uri.https(
      apiUrl,
      '$incrementApi/noToken/increment/project_list',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 0) {
        _stakeLists = responseData['data'];
        return notifyListeners();
      } else {
        _stakeLists = [];
        return notifyListeners();
      }
    } catch (error) {
      // throw error;
      print(error);
      return;
    }
  }

  Future<void> getStakeInfo(stakeId) async {
    var url = Uri.https(
      apiUrl,
      '$incrementApi/noToken/increment/project_info',
    );

    var postData = json.encode({'id': stakeId});

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 0) {
        _stakeInfo = responseData['data'];
        return notifyListeners();
      } else {
        _stakeInfo = {};
        return notifyListeners();
      }
    } catch (error) {
      // throw error;
      print(error);
      return;
    }
  }

  Future<void> getKlineData() async {
    var url = Uri.parse(
        'https://$openApiUrl/sapi/v1/klines?symbol=btcusdt&interval=30min');

    try {
      final response = await http.get(url);

      final responseData = json.decode(response.body);
      _klineData = responseData;
      return notifyListeners();
    } catch (error) {
      // throw error;
      return;
    }
  }

  Future<List<KLineEntity>> fetchKlkines(interval, symbol) async {
    var uri = Uri.parse(
        'https://$openApiUrl/sapi/v1/klines?symbol=$symbol&interval=$interval&limit=500');
    final res = await http.get(uri);
    return (jsonDecode(res.body) as List<dynamic>).map(
      (e) {
        return KLineEntity.fromCustom(
          time: e['idx'],
          high: double.parse(e['high']),
          low: double.parse(e['low']),
          open: double.parse(e['open']),
          close: double.parse(e['close']),
          vol: double.parse(e['vol']),
        );
      },
    ).toList();
    // .reversed
    // .toList();
  }

  Future<List<String>> fetchSymbols() async {
    final uri = Uri.parse("https://api.binance.com/api/v3/ticker/price");
    final res = await http.get(uri);
    return (jsonDecode(res.body) as List<dynamic>)
        .map((e) => e["symbol"] as String)
        .toList();
  }

  // Banners
  List _banners = [];

  List get banners {
    return _banners;
  }

  Future<void> getBanners() async {
    var url = Uri.https(
      lyoApiUrl,
      'admin/public/get_banner',
    );

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == "0") {
        _banners = responseData['data'];
        return notifyListeners();
      } else {
        _banners = [];
        return notifyListeners();
      }
    } catch (error) {
      // throw error;
      print(error);
      return;
    }
  }

  List _marketrecommendedsymbol = [];

  List get marketrecoomendsymbol {
    return _marketrecommendedsymbol;
  }

  bool isrecommended = true;

  Future<void> getrecomendedsybol(auth) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/common/market_recommend_symbol',
    );
    try {
      final response = await http.post(url, headers: headers1);
      print(response.statusCode);
      final responseData = json.decode(response.body);

      if (responseData['code'] == "0") {
        var data = responseData['data'];
        _marketrecommendedsymbol = data['recommendSymbol'].split(',');
        print(_marketrecommendedsymbol);
        isrecommended = false;
        return notifyListeners();
      } else {
        _banners = [];
        isrecommended = false;
        return notifyListeners();
      }
    } catch (error) {
      // throw error;
      print(error);
      return;
    }
  }

  // Notice Info
  List _noticeInfo = [
    {
      "title": "LYO Credit is not lited on Coingecko",
    }
  ];

  List get noticeInfo {
    return _noticeInfo;
  }

  Future<void> getNoticeInfo() async {
    var url = Uri.https(
      apiUrl,
      '$exApi/notice/notice_info_list',
    );

    var postParams = jsonEncode({"keyword": "", "page": 1, "pageSize": 9});

    try {
      final response = await http.post(url, body: postParams, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _noticeInfo = responseData['data']['noticeInfoList'];
        return notifyListeners();
      } else {
        _noticeInfo = [
          {
            "title": "LYO Credit is not lited on Coingecko",
          }
        ];
        return notifyListeners();
      }
    } catch (error) {
      // throw error;
      print(error);
      return;
    }
  }

  // Selected announcement
  Map _selectedAnnouncement = {};

  Map get selectedAnnouncement {
    return _selectedAnnouncement;
  }

  void setSelectedAnnouncement(value) {
    _selectedAnnouncement = value;
    return notifyListeners();
  }

  /////get favourit market//.........

  List _favMarketList = [];

  List get favMarketList {
    return _favMarketList;
  }

  List<dynamic> _selectedItems = [];

  List get selectedItems {
    return _selectedItems;
  }

  bool isfavloading = true;
  Future<void> getFavMarketList(ctx, formData) async {
    var url = Uri.https(
      lyoApiUrl,
      '$getfavmarkert/favorite-market'
    );

    var postData = json.encode(formData);
   print(postData);
    try {
      final response = await http.post(url, body: postData);
      print(response.statusCode);

      print(response.body);

      final responseData = json.decode(response.body);
      if (responseData['code'] == '0') {
      //  _favMarketList = responseData['data'];
        snackAlert(
            ctx, SnackTypes.success, 'Successfully Added');
        notifyListeners();
        return;
      } else {
        snackAlert(ctx, SnackTypes.errors, getTranslate(responseData['msg']));
      }

      return;
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Server Error!');
      return;
      // throw error;
    }
  }
}
