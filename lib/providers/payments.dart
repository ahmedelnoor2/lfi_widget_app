import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Translate.utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Payments with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'exchange-token': '',
  };

  Map _selectedFiatCurrency = {};

  void setSelectedFiatCurrency(selectCurrency) {
    _selectedFiatCurrency = selectCurrency;
    return notifyListeners();
  }

  Map get selectedFiatCurrency {
    return _selectedFiatCurrency;
  }

  Map _selectedCryptoCurrency = {};

  void setSelectedCryptoCurrency(selectCurrency) {
    _selectedCryptoCurrency = selectCurrency;
    return notifyListeners();
  }

  Map get selectedCryptoCurrency {
    return _selectedCryptoCurrency;
  }

  // Currencies
  List _fiatCurrencies = [];
  List _fiatSearchCurrencies = [];

  List get fiatCurrencies {
    return _fiatCurrencies;
  }

  List get fiatSearchCurrencies {
    return _fiatSearchCurrencies;
  }

  Future<void> getFiatCurrencies(ctx, auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      paymentsApi,
      '/currencies/fiat',
    );

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _fiatCurrencies = responseData['data'];
        _fiatSearchCurrencies = responseData['data'];
        _selectedFiatCurrency = responseData['data'].last;
        return notifyListeners();
      } else if (responseData['code'] == '10002') {
        snackAlert(
            ctx, SnackTypes.warning, 'Session Expired, Please login back');
        Navigator.pushNamed(ctx, '/authentication');
      } else {
        _fiatCurrencies = [];
        _fiatSearchCurrencies = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  // Crypto Currencies
  List _cryptoCurrencies = [];
  List _cryptoSearchCurrencies = [];

  List get cryptoCurrencies {
    return _cryptoCurrencies;
  }

  List get cryptoSearchCurrencies {
    return _cryptoSearchCurrencies;
  }

  Future<void> filterSearchResults(query, _allCurrencies) async {
    if (query.isNotEmpty) {
      List dummyListData = [];
      for (var item in _allCurrencies) {
        if ((item['ticker'].toLowerCase()).contains(query.toLowerCase())) {
          dummyListData.add(item);
          notifyListeners();
        }
      }
      _cryptoSearchCurrencies.clear();
      _cryptoSearchCurrencies.addAll(dummyListData);

      return notifyListeners();
    } else {
      _cryptoSearchCurrencies.clear();
      _cryptoSearchCurrencies.addAll(_allCurrencies);
      return notifyListeners();
    }
  }

  Future<void> getCryptoCurrencies(ctx, auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      paymentsApi,
      '/currencies/crypto',
    );

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _cryptoCurrencies = responseData['data'];
        _cryptoSearchCurrencies = responseData['data'];
        _selectedCryptoCurrency = responseData['data'][0];
        return notifyListeners();
      } else if (responseData['code'] == '10002') {
        snackAlert(
            ctx, SnackTypes.warning, 'Session Expired, Please login back');
      } else {
        _cryptoCurrencies = [];
        _cryptoSearchCurrencies = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  // Estimate rate conversion
  bool _estimateLoader = false;

  bool get estimateLoader {
    return _estimateLoader;
  }

  Map _estimateRate = {};

  Map get estimateRate {
    return _estimateRate;
  }

  Future<void> getEstimateRate(ctx, auth, formData) async {
    _estimateLoader = true;
    notifyListeners();
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      paymentsApi,
      '/estimate',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _estimateRate = responseData['data'];
        _estimateLoader = false;
        return notifyListeners();
      } else if (responseData['code'] == '4000') {
        snackAlert(ctx, SnackTypes.errors, responseData['msg']['message']);
      } else if (responseData['code'] == '10002') {
        snackAlert(
            ctx, SnackTypes.warning, 'Session Expired, Please login back');
      } else {
        _estimateRate = {};
        _estimateLoader = false;
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      _estimateLoader = false;
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // Create Transaction
  Map _changenowTransaction = {};

  Map get changenowTransaction {
    return _changenowTransaction;
  }

  Future<void> createTransaction(ctx, auth, formData) async {
    _changenowTransaction = {};
    notifyListeners();
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      paymentsApi,
      '/transaction',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _changenowTransaction = responseData['data'];
        return notifyListeners();
      } else if (responseData['code'] == '4000') {
        snackAlert(ctx, SnackTypes.errors, responseData['msg']['message']);
      } else if (responseData['code'] == '10002') {
        snackAlert(
            ctx, SnackTypes.warning, 'Session Expired, Please login back');
      } else {
        _changenowTransaction = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      _estimateLoader = false;
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // Get all transactions
  List _allTransactions = [];

  List get allTransactions {
    return _allTransactions;
  }

  Future<void> getAllTransactions(ctx, auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      paymentsApi,
      '/user_transactions',
    );

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _allTransactions = responseData['data'];
        return notifyListeners();
      } else if (responseData['code'] == '4000') {
        snackAlert(ctx, SnackTypes.errors, responseData['msg']['message']);
      } else if (responseData['code'] == '10002') {
        snackAlert(
            ctx, SnackTypes.warning, 'Session Expired, Please login back');
      } else {
        _allTransactions = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }
}
