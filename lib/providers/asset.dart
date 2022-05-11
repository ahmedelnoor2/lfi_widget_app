// finance/v5/account_balance

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Asset with ChangeNotifier {
  Map _accountBalance = {};
  Map _p2pBalance = {};
  Map _marginBalance = {};
  Map _totalAccountBalance = {};
  Map _getCost = {};
  Map _changeAddress = {};

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
