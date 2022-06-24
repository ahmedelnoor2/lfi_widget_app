import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Translate.utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DexProvider with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'exchange-token': '',
  };

  // Active currency
  Map _fromActiveCurrency = {};

  Map get fromActiveCurrency {
    return _fromActiveCurrency;
  }

  Map _toActiveCurrency = {};

  Map get toActiveCurrency {
    return _toActiveCurrency;
  }

  void swapFromAndTo() {
    var _newFromActiveCurrency = _toActiveCurrency;
    var _newToActiveCurrecy = _fromActiveCurrency;

    _toActiveCurrency = _newToActiveCurrecy;
    _fromActiveCurrency = _newFromActiveCurrency;
    return notifyListeners();
  }

  // Get all currencies
  List _allCurrencies = [];

  List get allCurrencies {
    return _allCurrencies;
  }

  Future<void> getAllCurrencies(ctx, auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    final queryParameters = {
      'api_key': dexApiKey,
      'active': 'true',
    };

    var url = Uri.https(dexSwapApi, '/v1/currencies/', queryParameters);

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData.length > 0) {
        _allCurrencies = responseData;
        _fromActiveCurrency = _allCurrencies[0];
        for (var currency in _allCurrencies) {
          if (currency['ticker'] == 'usdterc20') {
            _toActiveCurrency = currency;
          }
        }
        return notifyListeners();
      } else {
        _allCurrencies = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // Get estimation
  Map _estimateValue = {};

  Map get estimateValue {
    return _estimateValue;
  }

  Future<void> estimateExchangeValue(
    ctx,
    auth,
    fromCurrency,
    toCurrency,
  ) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    final queryParameters = {'api_key': dexApiKey};

    var url = Uri.https(dexSwapApi,
        '/v1/exchange-amount/1/${fromCurrency}_$toCurrency?', queryParameters);

    print('call');

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);
      print(responseData);

      if (responseData.isNotEmpty) {
        _estimateValue = responseData;
        return notifyListeners();
      } else {
        _estimateValue = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }
}
