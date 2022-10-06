import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart/entity/index.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:lyotrade/utils/Translate.utils.dart';

class FutureMarket with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'exchange-language': '',
  };

  Map _activeMarket = {
    "showName": "BTC/USDT",
    "symbol": "btcusdt",
  };
  Map _publicInfoMarket = {};
  Map _allMarkets = {};
  Map _allSearchMarket = {};

  Map get publicInfoMarket {
    return _publicInfoMarket;
  }

  Map get activeMarket {
    return _activeMarket;
  }

  Map get allMarkets {
    return _allMarkets;
  }

  Map get allSearchMarket {
    return _allSearchMarket;
  }

  Future<void> setActiveMarket(market) async {
    _activeMarket = market;
    return notifyListeners();
  }

  Future<void> filterMarketSearchResults(
      query, _searchAllMarkets, sMarketSort) async {
    if (query.isNotEmpty) {
      List dummyListData = [];
      for (var item in _searchAllMarkets[sMarketSort]) {
        if ((item['contractOtherName'].toLowerCase())
            .contains(query.toLowerCase())) {
          dummyListData.add(item);
          notifyListeners();
        }
      }
      _allSearchMarket[sMarketSort].clear();
      _allSearchMarket[sMarketSort].addAll(dummyListData);
      notifyListeners();
      return;
    } else {
      _allSearchMarket[sMarketSort].clear();
      _allSearchMarket[sMarketSort].addAll(_searchAllMarkets[sMarketSort]);
      notifyListeners();
      return;
    }
  }

  // ASKS and BIDS
  List _asks = [];
  List _bids = [];

  List get asks {
    return _asks;
  }

  List get bids {
    return _bids;
  }

  Future<void> setAsksAndBids(tickerData) async {
    _asks = tickerData['asks'];
    _bids = tickerData['buys'];
    notifyListeners();
  }

  // Market Active Ticke
  Map _activeMarketTick = {};
  Map _activeMarketAllTicks = {};

  Map get activeMarketTick {
    return _activeMarketTick;
  }

  Map get activeMarketAllTicks {
    return _activeMarketAllTicks;
  }

  Future<void> setActiveMarketTick(tick) async {
    _activeMarketTick = tick;
    notifyListeners();
  }

  Future<void> setActiveMarketAllTicks(tick, market) async {
    _activeMarketAllTicks[market.split('_')[2]] = tick;
    notifyListeners();
  }

  //Market Last Price
  String _lastPrice = '0';

  String get lastPrice {
    return _lastPrice;
  }

  Future<void> setLastPrice(price) async {
    _lastPrice = price;
    notifyListeners();
  }

  Future<void> getPublicInfoMarket() async {
    var url = Uri.https(
      futApiUrl,
      '$futExApi/common/public_info',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == "0") {
        _publicInfoMarket = responseData['data'];

        for (var m in responseData['data']['marginCoinList']) {
          _allMarkets[m] = [];
          _allSearchMarket[m] = [];
          for (var k in responseData['data']['contractList']) {
            _allMarkets[m].add(k);
            _allSearchMarket[m].add(k);
            if (k['base'] == 'BTC') {
              _activeMarket = k;
            }
          }
        }

        return notifyListeners();
      }
    } catch (error) {
      print(error);
      return;
    }
  }

  // Spot market info
  Map _publicSpotInfoMarket = {};

  Map get publicSpotInfoMarket {
    return _publicSpotInfoMarket;
  }

  Future<void> getPublicSpotInfoMarket() async {
    var url = Uri.https(
      apiUrl,
      '$exApi/common/public_info_market',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == "0") {
        _publicSpotInfoMarket = responseData['data'];
        return notifyListeners();
      } else {
        _publicSpotInfoMarket = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      return;
    }
  }

  // Open Positions
  Map _openPositions = {};

  Map get openPositions {
    return _openPositions;
  }

  Future<void> getOpenPositions(ctx, auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      futApiUrl,
      '$futExApi/position/get_assets_list',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _openPositions = responseData['data'];
        return notifyListeners();
      } else {
        _openPositions = {};
        return notifyListeners();
      }
    } catch (error) {
      _openPositions = {};
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // Market Info
  Map _marketInfo = {};

  Map get marketInfo {
    return _marketInfo;
  }

  Future<void> getMarketInfo(ctx, contractId) async {
    var url = Uri.https(
      futApiUrl,
      '$futExApi/common/public_market_info',
    );

    var postData = json.encode({'contractId': contractId});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _marketInfo = responseData['data'];
        return notifyListeners();
      } else {
        _marketInfo = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  // User Configuration
  Map _userConfiguration = {};

  Map get userConfiguration {
    return _userConfiguration;
  }

  Future<void> getUserConfiguration(ctx, auth, contractId) async {
    headers['exchange-token'] = auth.loginVerificationToken;
    headers['exchange-language'] = 'en_US';

    var url = Uri.https(
      futApiUrl,
      '$futExApi/user/get_user_config',
    );

    var postData = json.encode({
      'contractId': contractId,
    });

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _userConfiguration = responseData['data'];
        return notifyListeners();
      } else {
        _userConfiguration = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  // Update user marging model

  Future<void> updateUserMarginModel(ctx, auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      futApiUrl,
      '$futExApi/user/margin_model_edit',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, "Margin mode changed");
      } else {
        snackAlert(ctx, SnackTypes.errors, "${responseData['msg']}");
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  // Update level
  Future<void> updateLeverageLevel(ctx, auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      futApiUrl,
      '$futExApi/user/level_edit',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, "Leverage level updated");
      } else {
        snackAlert(ctx, SnackTypes.errors, "${responseData['msg']}");
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  // Update level
  Future<void> updateUserConfigs(ctx, auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      futApiUrl,
      '$futExApi/user/edit_user_page_config',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      print(responseData);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, "Configuration updated");
      } else {
        snackAlert(ctx, SnackTypes.errors, getTranslate(responseData['msg']));
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  Future<void> makeSpotToFutureTransfer(ctx, auth, formData) async {
    /*
    * Params
      amount: "1"
      coinSymbol: "USDT"
    */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      futApiUrl,
      '$exApi/web/futures_transfer',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, 'Transfer successful');
      } else if (responseData['code'] == 10002) {
        snackAlert(ctx, SnackTypes.warning, 'Please login to access');
        Navigator.pushNamed(ctx, '/authentication');
      } else {
        snackAlert(ctx, SnackTypes.errors, '${responseData['msg']}');
      }
    } catch (error) {
      print(error);
      snackAlert(ctx, SnackTypes.errors, 'Server error, please try again');
      // throw error;
    }
  }

  Future<void> makeFutureToSpotTransfer(ctx, auth, formData) async {
    /*
    * Params
      amount: "1"
      coinSymbol: "USDT"
    */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      futApiUrl,
      '$futExApi/assets/saas_trans/co_to_ex',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, 'Transfer successful');
      } else if (responseData['code'] == 10002) {
        snackAlert(ctx, SnackTypes.warning, 'Please login to access');
        Navigator.pushNamed(ctx, '/authentication');
      } else {
        snackAlert(ctx, SnackTypes.errors, '${responseData['msg']}');
      }
    } catch (error) {
      print(error);
      snackAlert(ctx, SnackTypes.errors, 'Server error, please try again');
      // throw error;
    }
  }

  // Order Create
  Future<void> createOrder(ctx, auth, formData) async {
    /*
    * Params
    contractId: 1,
    isConditionOrder: false,
    isOto: false,
    leverageLevel: 20,
    open: "OPEN",
    positionType: 1,
    price: 1000,
    side: "BUY",
    stopLossPrice: 0,
    stopLossTrigger: null,
    stopLossType: 2,
    takerProfitPrice: 0,
    takerProfitTrigger: null,
    takerProfitType: 2,
    triggerPrice: null,
    type: 1,
    volume: "10",
    */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      futApiUrl,
      '$futExApi/order/order_create',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, 'Order successfully created');
      } else if (responseData['code'] == '10002') {
        snackAlert(ctx, SnackTypes.warning, 'Please login to access');
      } else {
        snackAlert(
            ctx, SnackTypes.errors, '${getTranslate(responseData['msg'])}');
      }
    } catch (error) {
      print(error);
      snackAlert(ctx, SnackTypes.errors, 'Server error, please try again');
      // throw error;
    }
  }

  // Order Cancel
  Future<void> cancelLimitOrder(ctx, auth, formData) async {
    /*
    * Params
    contractId: 1,
    isConditionOrder: false,
    orderId: "1163227467630649180",
    */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      futApiUrl,
      '$futExApi/order/order_cancel',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, 'Order successfully cancelled');
      } else if (responseData['code'] == 10002) {
        snackAlert(ctx, SnackTypes.warning, 'Please login to access');
        Navigator.pushNamed(ctx, '/authentication');
      } else {
        snackAlert(ctx, SnackTypes.errors, '${responseData['msg']}');
      }
    } catch (error) {
      print(error);
      snackAlert(ctx, SnackTypes.errors, 'Server error, please try again');
      // throw error;
    }
  }

  // Current order list
  List _currentOrders = [];

  List get currentOrders {
    return _currentOrders;
  }

  Future<void> getCurrentOrders(ctx, auth, contractId) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      futApiUrl,
      '$futExApi/order/current_order_list',
    );

    var postData = json.encode({'contractId': contractId});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _currentOrders = responseData['data']['orderList'];
        return notifyListeners();
      } else {
        _currentOrders = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Server error, please try again');
      // throw error;
    }
  }

  // Trigger order list
  List _triggerOrders = [];

  List get triggerOrders {
    return _triggerOrders;
  }

  Future<void> getTriggerOrders(ctx, auth, contractId) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      futApiUrl,
      '$futExApi/order/trigger_order_list',
    );

    var postData = json.encode({'contractId': contractId});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _triggerOrders = responseData['data']['trigOrderList'];
        return notifyListeners();
      } else {
        _triggerOrders = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);

      ///  snackAlert(ctx, SnackTypes.errors, 'Server error, please try again .........');
      // throw error;
    }
  }
}
