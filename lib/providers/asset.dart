// finance/v5/account_balance

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:lyotrade/utils/AppConstant.utils.dart';

class Asset with ChangeNotifier {
  Map _accountBalance = {};
  Map _p2pBalance = {};
  Map _marginBalance = {};
  Map _totalAccountBalance = {};
  Map _getCost = {};
  Map _changeAddress = {};
  List _digitialAss = [];
  List _allDigAsset = [];
  bool _hideBalances = false;
  final String _hideBalanceString = '******';

  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'exchange-token': '',
  };

  Map get accountBalance {
    return _accountBalance;
  }

  Map get p2pBalance {
    return _p2pBalance;
  }

  Map get marginBalance {
    return _marginBalance;
  }

  Map get totalAccountBalance {
    return _totalAccountBalance;
  }

  Map get getCost {
    return _getCost;
  }

  Map get changeAddress {
    return _changeAddress;
  }

  List get digitialAss {
    return _digitialAss;
  }

  List get allDigAsset {
    return _allDigAsset;
  }

  bool get hideBalances {
    return _hideBalances;
  }

  String get hideBalanceString {
    return _hideBalanceString;
  }

  void toggleHideBalances(value) {
    _hideBalances = value;
    notifyListeners();
  }

  void setDigAssets(digAsset) {
    _digitialAss = digAsset;
    notifyListeners();
  }

  Future<void> filterSearchResults(query) async {
    if (query.isNotEmpty) {
      List dummyListData = [];
      for (var item in _digitialAss) {
        if (item['coin'].contains(query)) {
          if (item['values']['depositOpen'] == 1) {
            dummyListData.add(item);
          }
          notifyListeners();
        }
      }
      _allDigAsset.clear();
      _allDigAsset.addAll(dummyListData);
      return;
    } else {
      _allDigAsset.clear();
      _allDigAsset.addAll(_digitialAss);
      notifyListeners();
      return;
    }
  }

  Future<void> getTotalBalance(auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/finance/total_account_balance',
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
        _totalAccountBalance = responseData['data'];
      } else {
        _totalAccountBalance = {};
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getAccountBalance(auth, coinSymbols) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/finance/v5/account_balance',
    );

    var postData = json.encode({coinSymbols: coinSymbols});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _accountBalance = responseData['data'];
      } else {
        _accountBalance = {};
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getP2pBalance(auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/finance/v4/otc_account_list',
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
        _p2pBalance = responseData['data'];
      } else {
        _p2pBalance = {};
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getMarginBalance(auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/lever/finance/balance',
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
        _marginBalance = responseData['data'];
      } else {
        _marginBalance = {};
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getCoinCosts(auth, coin) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/cost/Getcost',
    );

    var postData = json.encode({"symbol": coin});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _getCost = responseData['data'];
      } else if (responseData['code'] == '10002') {
        _getCost = {};
      } else {
        _getCost = {};
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getChangeAddress(auth, coin) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/finance/get_charge_address',
    );

    var postData = json.encode({"symbol": coin});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _changeAddress = responseData['data'];
      } else {
        _changeAddress = {};
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }
}
