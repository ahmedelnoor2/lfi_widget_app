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
        _selectedCryptoCurrency = responseData['data']
            .firstWhere((item) => item['ticker'] == 'usdttrc20');
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
        _estimateRate = {
          'value': 0,
        };
        _estimateLoader = false;
        return notifyListeners();
      }
    } catch (error) {
      _estimateRate = {
        'value': 0,
      };
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

  // Get TX details
  Map _getTxDetails = {};

  Map get getTxDetails {
    return _getTxDetails;
  }

  Future<void> decryptPixQR(postData) async {
    var url = Uri.https(
      lyoApiUrl,
      '/payment_gateway/pix/get_tx_details',
    );

    try {
      final response = await http.post(
        url,
        body: json.encode(postData),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _getTxDetails = responseData['data'];
        return notifyListeners();
      } else {
        _getTxDetails = {};
        return notifyListeners();
      }
    } catch (error) {
      _getTxDetails = {};
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // Get all transactions
  List _allPixTransactions = [];

  List get allPixTransactions {
    return _allPixTransactions;
  }

  Future<void> getAllPixTransactions(uuid) async {
    var url = Uri.https(
      lyoApiUrl,
      '/payment_gateway/pix/get_client_kyc_transactions/$uuid',
    );

    print(uuid);

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      print(responseData);

      if (responseData['code'] == '0') {
        _allPixTransactions = responseData['data'];
        return notifyListeners();
      } else {
        _allPixTransactions = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      _allPixTransactions = [];
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // PIX payment providers
  Map _pixKycClients = {};

  Map get pixKycClients {
    return _pixKycClients;
  }

  Future<void> getKycVerificationDetails(postData) async {
    var url = Uri.https(
      lyoApiUrl,
      '/payment_gateway/pix/list_pix_kyc_clients',
    );

    try {
      final response = await http.post(
        url,
        body: json.encode(postData),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _pixKycClients = responseData['data'];
        return notifyListeners();
      } else {
        _pixKycClients = {};
        return notifyListeners();
      }
    } catch (error) {
      _pixKycClients = {};
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // New KYC
  Map _newKyc = {};

  Map get newKyc {
    return _newKyc;
  }

  Future<void> requestKyc(ctx, postData) async {
    var url = Uri.https(
      lyoApiUrl,
      '/payment_gateway/pix/kyc',
    );

    try {
      final response = await http.post(
        url,
        body: json.encode(postData),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _newKyc = responseData['data'];
        return notifyListeners();
      } else {
        Navigator.pop(ctx);
        snackAlert(ctx, SnackTypes.errors, responseData['msg']);
        _newKyc = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      _newKyc = {};
      Navigator.pop(ctx);
      snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  Future<void> reRequestKyc(ctx, postData) async {
    var url = Uri.https(
      lyoApiUrl,
      '/payment_gateway/pix/kyc',
    );

    print(postData);

    try {
      final response = await http.put(
        url,
        body: json.encode(postData),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      print(responseData);

      if (responseData['code'] == '0') {
        _newKyc = responseData['data'];
        snackAlert(ctx, SnackTypes.success, 'Resent KYC verifcation');
        return notifyListeners();
      } else {
        snackAlert(
          ctx,
          SnackTypes.errors,
          'Failed to resend KYC verification, try again or contact to the support',
        );
        _newKyc = {};
        return notifyListeners();
      }
    } catch (error) {
      snackAlert(
        ctx,
        SnackTypes.errors,
        'Failed to resend KYC verification, please contact to the support',
      );
      print(error);
      _newKyc = {};
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // Pix Commission Rate
  double _pixCurrencyCommission = 0;

  double get pixCurrencyCommission {
    return _pixCurrencyCommission;
  }

  Future<void> getPixCurrencyCommissionRate() async {
    var url = Uri.https(
      lyoApiUrl,
      '/payment_gateway/pix-setting/get-commission',
    );

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0' || responseData['code'] == '200') {
        _pixCurrencyCommission =
            double.parse(responseData['data']['processingFees']);
        return notifyListeners();
      } else {
        _pixCurrencyCommission = 0;
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // Pix Currency Exchange Rate
  double _pixCurrencyExchange = 5.6;

  double get pixCurrencyExchange {
    return _pixCurrencyExchange;
  }

  Future<void> getPixCurrencyExchangeRate(postData) async {
    var url = Uri.https(
      lyoApiUrl,
      '/payment_gateway/pix/get_exchange_rate',
    );

    try {
      final response = await http.post(
        url,
        body: json.encode(postData),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _pixCurrencyExchange = double.parse(responseData['data']['price']);
        return notifyListeners();
      } else {
        _pixCurrencyExchange = 5.6;
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // PIX client transactions
  Map _kycTransaction = {};

  Map get kycTransaction {
    return _kycTransaction;
  }

  Future<void> clearKycTransactions() async {
    _kycTransaction = {};
    return notifyListeners();
  }

  Future<void> getKycVerificationTransaction(uuid) async {
    var url = Uri.https(
      lyoApiUrl,
      '/payment_gateway/pix/get_client_kyc_transactions/$uuid',
    );

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _kycTransaction = responseData['data'][0];
        return notifyListeners();
      } else {
        _kycTransaction = {};
        return notifyListeners();
      }
    } catch (error) {
      _kycTransaction = {};
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  //
  String _awaitingTime = '00:00:00';

  String get awaitingTime {
    return _awaitingTime;
  }

  void setAwaitingTime(value) {
    _awaitingTime = value;
    notifyListeners();
  }

  //
  int _clientUpdateCall = 10;

  int get clientUpdateCall {
    return _clientUpdateCall;
  }

  void setClientUpdateCall(value) {
    _clientUpdateCall = value;
    notifyListeners();
  }

  // PIX create new transaction
  Map _pixNewTransaction = {};

  Map get pixNewTransaction {
    return _pixNewTransaction;
  }

  String _transactionValue = '--';

  String get transactionValue {
    return _transactionValue;
  }

  Future<void> createNewPixTransaction(ctx, postData, txValue) async {
    var url = Uri.https(
      lyoApiUrl,
      '/payment_gateway/pix/create_transaction',
    );

    try {
      final response = await http.post(
        url,
        body: json.encode(postData),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _transactionValue = txValue;
        _pixNewTransaction = responseData['data'];
        return notifyListeners();
      } else {
        snackAlert(ctx, SnackTypes.errors, responseData['error'][0]);
        _transactionValue = '--';
        _pixNewTransaction = {};
        return notifyListeners();
      }
    } catch (error) {
      _transactionValue = '--';
      _pixNewTransaction = {};
      print(error);
      snackAlert(ctx, SnackTypes.errors, 'Server error, please try again.');
      return notifyListeners();
    }
  }

  // Select Transaction
  Map _selectedTransaction = {};

  Map get selectedTransaction {
    return _selectedTransaction;
  }

  Future<void> setSelectedTransaction(transaction) async {
    _selectedTransaction = transaction;
    return notifyListeners();
  }
}
