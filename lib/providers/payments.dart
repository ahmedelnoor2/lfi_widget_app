import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Translate.utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/js.dart';

class Payments with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'exchange-token': '',
    'exchange-language': 'en_US',
  };

  // Change language
  bool _portugeseLang = false;

  bool get portugeseLang {
    return _portugeseLang;
  }

  void toggleEnLang() {
    _portugeseLang = !_portugeseLang;
    notifyListeners();
  }

  String getPortugeseTrans(value) {
    if (_portugeseLang) {
      return getPortugeseTranslate(value);
    } else {
      return value;
    }
  }

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

  Future<void> filterFiatSearchResults(query) async {
    if (query.isNotEmpty) {
      List dummyListData = [];
      for (var item in _fiatCurrencies) {
        if ((item['ticker'].toLowerCase()).contains(query.toLowerCase())) {
          dummyListData.add(item);
          notifyListeners();
        }
      }
      _fiatSearchCurrencies.clear();
      _fiatSearchCurrencies.addAll(dummyListData);

      return notifyListeners();
    } else {
      _fiatSearchCurrencies.clear();
      _fiatSearchCurrencies.addAll(_fiatCurrencies);
      return notifyListeners();
    }
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
        _selectedFiatCurrency =
            responseData['data'].firstWhere((item) => item['ticker'] == 'gbp');
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

  Future<void> filterSearchResults(query) async {
    if (query.isNotEmpty) {
      List dummyListData = [];
      for (var item in _cryptoCurrencies) {
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
      _cryptoSearchCurrencies.addAll(_cryptoCurrencies);
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

  Map _estimateMessage = {};

  Map get estimateMessage {
    return _estimateMessage;
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

      _estimateMessage = responseData;

      if (responseData['code'] == '0') {
        _estimateRate = responseData['data'];
        _estimateMessage = {};
        //print(_estimateRate);
        _estimateLoader = false;
        return notifyListeners();
      } else if (responseData['code'] == '4000') {
        snackAlert(ctx, SnackTypes.errors, responseData['msg']['message']);
        _estimateLoader = false;
        return notifyListeners();
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

  // Onramp
  Map _estimateOnrampRate = {};

  Map get estimateOnrampRate {
    return _estimateOnrampRate;
  }

  bool _isLoadingEstimate = false;

  bool get isLoadingEstimate {
    return _isLoadingEstimate;
  }

  void setisLoadingEstimate(value) {
    _isLoadingEstimate = value;
    return notifyListeners();
  }

  Future<void> getOnrampEstimateRate(ctx, formData) async {
    _isLoadingEstimate = true;
    notifyListeners();

    var url = Uri.https(
      lyoApiUrl,
      '/on-ramper/rate',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        if (responseData['data'].isNotEmpty) {
          _estimateOnrampRate = responseData['data'][0];
          _isLoadingEstimate = false;

          return notifyListeners();
        } else {
          snackAlert(ctx, SnackTypes.errors, 'This pair is not supported');
          _estimateOnrampRate = {};
          _estimateLoader = false;
          return notifyListeners();
        }
      } else if ((responseData['code'] == '400') ||
          (responseData['code'] == '500')) {
        snackAlert(ctx, SnackTypes.errors, responseData['msg']);
        _isLoadingEstimate = false;
        return notifyListeners();
      } else {
        _estimateRate = {
          'rate': 0,
        };
        _isLoadingEstimate = false;
        return notifyListeners();
      }
    } catch (error) {
      _estimateRate = {
        'rate': 0,
      };
      _isLoadingEstimate = false;
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

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);

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

    try {
      final response = await http.put(
        url,
        body: json.encode(postData),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _newKyc = responseData['data'];
        snackAlert(ctx, SnackTypes.success, 'Resent KYC verifcation');
        return notifyListeners();
      } else {
        showAlert(
          ctx,
          Icon(
            Icons.warning,
            color: warningColor,
          ),
          'Error',
          [
            const Text(
                'Failed to resend KYC verification, try again or contact to the support')
          ],
          'Ok',
        );
        snackAlert(
          ctx,
          SnackTypes.errors,
          'Failed to resend KYC verification, try again or contact to the support',
        );
        _newKyc = {};
        return notifyListeners();
      }
    } catch (error) {
      showAlert(
        ctx,
        Icon(
          Icons.warning,
          color: warningColor,
        ),
        'Error',
        [
          const Text(
              'Failed to resend KYC verification, try again or contact to the support')
        ],
        'Ok',
      );
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
        //  print(_pixCurrencyExchange);
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

      //  print(postData);

      final responseData = json.decode(response.body);
      // print(responseData);

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

  // Onramp fiat selected transaction
  Map _selectedOnrampFiatCurrency = {};

  Map get selectedOnrampFiatCurrency {
    return _selectedOnrampFiatCurrency;
  }

  void setSelectedOnrampFiatCurrency(selectCurrency) {
    _selectedOnrampFiatCurrency = selectCurrency;
    return notifyListeners();
  }

  // Onramp crypto selected transaction
  Map _selectedOnrampCryptoCurrency = {};

  Map get selectedOnrampCryptoCurrency {
    return _selectedOnrampCryptoCurrency;
  }

  Future<void> setSelectedOnrampCryptoCurrency(selectCurrency) async {
    _selectedOnrampCryptoCurrency = selectCurrency;
    return notifyListeners();
  }

  Map _defaultOnrampGateway = {};

  Map get defaultOnrampGateway {
    return _defaultOnrampGateway;
  }

  void setDefaultOnrampGateway(gateway) {
    _defaultOnrampGateway = gateway;
    return notifyListeners();
  }

  String _onRampIdentifier = '';

  String get onRampIdentifier {
    return _onRampIdentifier;
  }

  void setonRampIdentifier(data) {
    _onRampIdentifier = data;
    return notifyListeners();
  }

  int _tappedIdentifier = 0;

  int get tappedIdentifier {
    return _tappedIdentifier;
  }

  void setTappedIdentifier(index) {
    _tappedIdentifier = index;

    return notifyListeners();
  }

  List _onrampGateways = [];

  List get onrampGateways {
    return _onrampGateways;
  }

  void setOnrampGateways(gateways) {
    _onrampGateways = gateways;
    return notifyListeners();
  }

  List _paymentMethods = [];

  List get paymentMethods {
    return _paymentMethods;
  }

  var selectedpaymentmethod;
  var amount = '';

  void setpaymentMethods(data) {
    _paymentMethods = data;
    return notifyListeners();
  }

  // get on ramper details
  Map _onRamperDetails = {};

  Map get onRamperDetails {
    return _onRamperDetails;
  }

  List onrampfiatlist = [];

  List onrampfoundlist = [];

  List onRampCryptoList = [];

  List onRampCryptoFoundList = [];

  Future<void> getOnRamperDetails(ctx) async {
    var url = Uri.https(
      lyoApiUrl,
      '/on-ramper/gateway',
    );

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _onRamperDetails = responseData['data'];
        _onrampGateways = _onRamperDetails['gateways'];
        _paymentMethods = _onRamperDetails['gateways'][0]['paymentMethods'];
        selectedpaymentmethod =
            _onRamperDetails['gateways'][0]['paymentMethods'].first;

        _defaultOnrampGateway = _onRamperDetails['gateways'][0];
        _onRampIdentifier = _onRamperDetails['gateways'][0]['identifier'];
        _selectedOnrampFiatCurrency = _onRamperDetails['gateways'][0]
                ['fiatCurrencies']
            .firstWhere((item) => item['code'] == 'EUR');
        _selectedOnrampCryptoCurrency = _onRamperDetails['gateways'][0]
                ['cryptoCurrencies']
            .firstWhere((item) => item['code'] == 'BTC');
        onrampfiatlist = _onRamperDetails['gateways'][0]['fiatCurrencies'];
        onRampCryptoList = _onRamperDetails['gateways'][0]['cryptoCurrencies'];

        return notifyListeners();
      } else {
        _onRamperDetails = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      _onRamperDetails = {};
      // snackAlert(ctx, SnackTypes.errors, 'Server error, please try again.');
      return notifyListeners();
    }
  }

  void runFilter(String enteredKeyword) {
    ///print(enteredKeyword.toUpperCase());
    List results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = onrampfiatlist;
    } else {
      results = onrampfiatlist
          .where((item) =>
              item['code'].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();

      // print(results);
      // we use the toLowerCase() method to make it case-insensitive
    }

    onrampfoundlist = results;

    notifyListeners();
  }

  void runCryptoFilter(String enteredKeyword) {
    List results = [];

    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = onRampCryptoList;
    } else {
      results = onRampCryptoList
          .where((item) =>
              item['code'].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      //  print(results);
      // we use the toLowerCase() method to make it case-insensitive
    }

    onRampCryptoFoundList = results;
    // print(onRampCryptoFoundList);
    notifyListeners();
  }

  Map _formCallResponse = {};

  Map get formCallResponse {
    return _formCallResponse;
  }

  Future<void> callOnrampForm(ctx, formData) async {
    var url = Uri.https(
      lyoApiUrl,
      '/on-ramper/call-form',
    );
    try {
      final response = await http.post(
        url,
        body: jsonEncode(formData),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _formCallResponse = responseData['data'];
        Navigator.pop(ctx);
        return notifyListeners();
      } else {
        _formCallResponse = {};
        Navigator.pop(ctx);
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      _formCallResponse = {};
      Navigator.pop(ctx);
      snackAlert(ctx, SnackTypes.errors, 'Server error, please try again.');
      return notifyListeners();
    }
  }

  /////pix payment minimum with drawal amount & maximunm
  Map _minimumWithdarwalAmt = {};

  Map get minimumWithdarwalAmt {
    return _minimumWithdarwalAmt;
  }

  bool _cpfStatus = false;
  bool get cpfStatus {
    return _cpfStatus;
  }

  void setCpfStatus(bool value) {
    _cpfStatus = value;
    return notifyListeners();
  }

  Future<void> getminimumWithDrawalAmount(auth, formdata) async {
    headers['exchange-token'] = auth.loginVerificationToken;
    var url = Uri.https(apiUrl, '/fe-ex-api/pix/basic_info');
    print(url);
    try {
      final response =
          await http.post(url, headers: headers, body: jsonEncode(formdata));
      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['code'] == '0') {
        _minimumWithdarwalAmt = responseData['data'];

        notifyListeners();
      } else {
        _minimumWithdarwalAmt = {};

        return notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  Map _cpf = {};

  Map get cpf {
    return _cpf;
  }

  bool _isCpfLoading = false;

  bool get isCpfLoading {
    return _isCpfLoading;
  }

  Future<void> getCpf(ctx, auth, formdata) async {
    print(formdata);
    headers['exchange-token'] = auth.loginVerificationToken;
    var url = Uri.https(apiUrl, '/fe-ex-api/pix/valide_cpf');

    try {
      _isCpfLoading = true;
      final response =
          await http.post(url, headers: headers, body: jsonEncode(formdata));
      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['code'] == '0') {
        _cpf = responseData;
        Navigator.pushNamed(ctx, '/pix_payment_details');
        setCpfStatus(false);
        _isCpfLoading = false;
        notifyListeners();
      } else if (responseData['code'] == '106411') {
        _cpf = {};
        Navigator.pop(ctx);
        snackAlert(ctx, SnackTypes.errors, responseData['msg']);
        print('check...');
        print(_cpfStatus);
        _isCpfLoading = false;
        return notifyListeners();
      } else {
        _cpf = {};
        Navigator.pop(ctx);
        snackAlert(ctx, SnackTypes.errors, responseData['msg']);
        _isCpfLoading = false;
        return notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  /// pix create order
  Map _pixCreateOrder = {};

  Map get pixCreateOrder {
    return _pixCreateOrder;
  }

  bool _isCreateOrderLoading = false;
  bool get isCreateOrderLoading {
    return _isCreateOrderLoading;
  }

  Future<void> getCreatePixOrder(ctx, auth, formdata) async {
    print(formdata);
    _isCreateOrderLoading = true;

    /// url//
    headers['exchange-token'] = auth.loginVerificationToken;
    var url = Uri.https(apiUrl, '/fe-ex-api/pix/create_order');
    print(url);
    try {
      final response =
          await http.post(url, headers: headers, body: jsonEncode(formdata));
      final responseData = json.decode(response.body);
      print('cerate order ...........');
      print(responseData);
      if (responseData['code'] == '0') {
        _isCreateOrderLoading = false;
        Navigator.pushNamed(ctx, '/pix_process_payment');
        _pixCreateOrder = responseData['data'];
        snackAlert(ctx, SnackTypes.success, responseData['msg']);
        print(_pixCreateOrder);
        notifyListeners();
      } else {
        _pixCreateOrder = {};
        snackAlert(ctx, SnackTypes.warning, responseData['msg']);
        return notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  /// pix detail info
  Map _pixdetail = {};

  Map get pixdetail {
    return _pixdetail;
  }

  bool _ispixdetailLoading = false;
  bool get ispixdetailLoading {
    return _ispixdetailLoading;
  }

  String _payQr = "";

  String get payQr {
    return _payQr;
  }

  void resetPayQr() {
    _payQr = "";
    return notifyListeners();
  }

  Future<void> getPixDetailInfo(auth, formdata) async {
    _ispixdetailLoading = true;

    /// url//
    headers['exchange-token'] = auth.loginVerificationToken;
    var url = Uri.https(apiUrl, '/fe-ex-api/pix/detail_info');
    try {
      final response =
          await http.post(url, headers: headers, body: jsonEncode(formdata));
      print(response.body);
      final responseData = json.decode(response.body);
      print('Pix payment detail ...........');
      if (responseData['code'] == '0') {
        _ispixdetailLoading = false;
        _pixdetail = responseData['data'];
        if (_payQr.isEmpty) {
          _payQr = _pixdetail['qrCode'];
        }
        notifyListeners();
      } else {
        _pixdetail = {};

        return notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }
}