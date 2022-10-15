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
    'exchange-language': 'en_US',
  };

  // Active currency
  Map _fromActiveCurrency = {};

  Map get fromActiveCurrency {
    return _fromActiveCurrency;
  }

  void setFromActiveCurrency(currency) {
    _fromActiveCurrency = currency;
    return notifyListeners();
  }

  Map _toActiveCurrency = {};

  Map get toActiveCurrency {
    return _toActiveCurrency;
  }

  void setToActiveCurrency(currency) {
    _toActiveCurrency = currency;
    return notifyListeners();
  }

  Future<void> swapFromAndTo() async {
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

    var url =
        Uri.https(dexSwapApi, '$exDexSwap/v1/currencies/', queryParameters);

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData.length > 0) {
        _allCurrencies = responseData;
        _fromActiveCurrency = _allCurrencies[0];
        for (var currency in _allCurrencies) {
          if (currency['ticker'] == 'usdttrc20') {
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
    amount,
    fromCurrency,
    toCurrency,
  ) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    final queryParameters = {'api_key': dexApiKey};

    var url = Uri.https(
        dexSwapApi,
        '$exDexSwap/v1/exchange-amount/$amount/${fromCurrency}_$toCurrency',
        queryParameters);

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData.isNotEmpty) {
        if (responseData['error'] != null) {
          snackAlert(ctx, SnackTypes.errors, responseData['message']);
          _estimateValue = {};
          return notifyListeners();
        } else {
          _estimateValue = responseData;
          return notifyListeners();
        }
      } else {
        _estimateValue = {};
        return notifyListeners();
      }
    } catch (error) {
      // print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // Get estimation
  Map _minimumValue = {};

  Map get minimumValue {
    return _minimumValue;
  }

  Future<void> estimateMinimumValue(
    ctx,
    auth,
    fromCurrency,
    toCurrency,
  ) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    final queryParameters = {'api_key': dexApiKey};

    var url = Uri.https(
      dexSwapApi,
      '$exDexSwap/v1/exchange-range/${fromCurrency}_$toCurrency',
      queryParameters,
    );

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData.isNotEmpty) {
        _minimumValue = responseData;
        return notifyListeners();
      } else {
        _minimumValue = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // Get estimation
  Map _verifyAddress = {};

  Map get verifyAddress {
    return _verifyAddress;
  }

  Future<void> validateAddress(
    ctx,
    auth,
    formData,
  ) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      dexSwapApi,
      '$exDexSwap/v2/validate/address',
      formData,
    );

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData.isNotEmpty) {
        _verifyAddress = responseData;
        return notifyListeners();
      } else {
        _verifyAddress = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      snackAlert(ctx, SnackTypes.errors, 'Server error');
    }
  }

  // Get estimation
  Map _processPayment = {};

  Map get processPayment {
    return _processPayment;
  }

  Future<void> clearPaymentProcess() async {
    _processPayment = {};
    return notifyListeners();
  }

  Future<void> processSwapPayment(ctx, formData) async {
    var url = Uri.https(
      dexSwapApi,
      '$exDexSwap/v1/transactions/$dexApiKey',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData.isNotEmpty) {
        _processPayment = responseData;
        snackAlert(ctx, SnackTypes.success,
            'Transaction created, waiting for the payment');
        return notifyListeners();
      } else {
        _processPayment = {};
        snackAlert(
            ctx, SnackTypes.success, 'Transaction failed please try again');
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      _processPayment = {};
      snackAlert(ctx, SnackTypes.errors, 'Server Error.');
      return;
    }
  }
}
