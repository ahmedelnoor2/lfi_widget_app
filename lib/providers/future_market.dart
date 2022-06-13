import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart/entity/index.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:k_chart/entity/k_line_entity.dart';

class FutureMarket with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
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

  Map get activeMarketTick {
    return _activeMarketTick;
  }

  Future<void> setActiveMarketTick(tick) async {
    _activeMarketTick = tick;
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

        for (var k in responseData['data']['contractList']) {
          _allMarkets[k['base']] = k;
          _allSearchMarket[k['base']] = k;
          if (k['base'] == 'BTC') {
            _activeMarket = k;
          }
        }

        return notifyListeners();
      }
    } catch (error) {
      print(error);
      return;
    }
  }

  // Open Positions
  List _openPositions = [];

  List get openPositions {
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

      if (responseData['code'] == 0) {
        _openPositions = responseData['data']['positionList'];
        return notifyListeners();
      } else {
        _openPositions = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
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

    var url = Uri.https(
      futApiUrl,
      '$futExApi/user/get_user_config',
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
}
