import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart/entity/index.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/screens/take_loan/take_loan.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';

class LoanProvider with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'exchange-token',
    'Authorization': 'd0435db6-d4f5-4065-8024-c62684de12fb',
  };

  Map<String, String> headers1 = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Accept': 'exchange-token',
    'Authorization': 'd0435db6-d4f5-4065-8024-c62684de12fb',
  };

  List _fromCurrenciesList = [];

  List get fromCurrenciesList {
    return _fromCurrenciesList;
  }

  String _selectedFromCurrencyCoin = 'BTC(Bitcoin)';

  String get selectedFromCurrencyCoin {
    return _selectedFromCurrencyCoin;
  }

  void setSelectedFromCurrencyCoin(coin) {
    _selectedFromCurrencyCoin = coin;
    notifyListeners();
  }

  Map _fromCurrencies = {};

  Map get fromCurrencies {
    return _fromCurrencies;
  }

  Map _fromSelectedCurrency = {};

  Map get fromSelectedCurrency {
    return _fromSelectedCurrency;
  }

  void setFromSelectedCurrency(currency) {
    _fromSelectedCurrency = currency;
    notifyListeners();
  }

/////to cuurency//
  ///
  List _toCurrenciesList = [];

  List get toCurrenciesList {
    return _toCurrenciesList;
  }

  String _selectedToCurrencyCoin = "USDT(TRX)";

  String get selectedToCurrencyCoin {
    return _selectedToCurrencyCoin;
  }

  void setSelectedToCurrencyCoin(coin) {
    _selectedToCurrencyCoin = coin;
    notifyListeners();
  }

  Map _toCurrencies = {};

  Map get toCurrencies {
    return _toCurrencies;
  }

  Map _toSelectedCurrency = {};

  Map get toSelectedCurrency {
    return _toSelectedCurrency;
  }

  void setToSelectedCurrency(currency) {
    _toSelectedCurrency = currency;
    notifyListeners();
  }

  Future<void> getCurrencies(public) async {
    var url = Uri.https(
      loanApiUrl,
      '$loanApiVersion/assets',
    );

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      if (responseData['result']) {
        var myresponsedata = responseData['response'];

        /// filtering data
        _fromCurrenciesList.clear();
        for (var resData in myresponsedata) {
          if ((resData['is_loan_deposit_enabled'] == true) &&
              (resData['is_stable'] == false)) {
            _fromCurrencies['${resData['code']}(${resData['name']})'] = resData;
            _fromCurrenciesList.add('${resData['code']}(${resData['name']})');
            if ('${resData['code']}(${resData['name']})' ==
                _selectedFromCurrencyCoin) {
              _fromSelectedCurrency = resData;

              from_code = _fromSelectedCurrency['code'];
              from_network = _fromSelectedCurrency['network'];
            }
          }
        }

        _toCurrenciesList.clear();

        for (var resData in myresponsedata) {
          if ((resData['is_stable'] == true) &&
              (resData['is_loan_receive_enabled'] == true)) {
            if (public.publicInfoMarket['market']['followCoinList']
                .containsKey('${resData['code']}')) {
              _toCurrencies['${resData['code']}(${resData['network']})'] =
                  resData;
              _toCurrenciesList
                  .add('${resData['code']}(${resData['network']})');

              if ('${resData['code']}(${resData['network']})' ==
                  _selectedToCurrencyCoin) {
                _toSelectedCurrency = resData;
                to_code = _toSelectedCurrency['code'];
                to_network = _toSelectedCurrency['network'];
              }
            }
          }
        }

        return notifyListeners();
      } else {
        _fromCurrenciesList = [];
        _toCurrenciesList = [];

        return notifyListeners();
      }
    } catch (error) {
      print(error);

      return;
    }
  }

////Loan estimates api//
  ///
  Map _loanestimate = {};

  Map get loanestimate {
    return _loanestimate;
  }

  String from_code = 'BTC';
  String from_network = 'BTC';
  String to_code = 'USDT';
  String to_network = 'ETH';
  var amount = '1';
  var exchange = 'direct';
  var ltv_percent = 0.5;

  final TextEditingController _textEditingControllereciver =
      TextEditingController();

  var reciveramount = '';
  var senderamount = '';

  Future<void> getloanestimate(ctx) async {
    var url = Uri.https(loanApiUrl, loansApiestimate, {
      'from_code': from_code,
      'from_network': from_network,
      'to_code': to_code,
      'to_network': to_network,
      'amount': amount,
      'exchange': exchange,
      'ltv_percent': '$ltv_percent'
    });

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);
      if (responseData != null) {
        if (responseData['result']) {
          _loanestimate = responseData['response'];
          senderamount = responseData['response']['amount_from'];
          reciveramount = responseData['response']['amount_to'];
          return notifyListeners();
        } else {
          _loanestimate = {};
          return notifyListeners();
        }
      } else {
        _loanestimate = {};
        return notifyListeners();
      }
    } catch (error) {
      // print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Invalid price');
      return;
    }
  }

///////recive email for verify//
  ///
  bool isemailwidgitconverter = false;

  void setIsEmailWidgetConverter(value) {
    isemailwidgitconverter = value;
    notifyListeners();
  }

  Future<void> getemail(ctx, email) async {
    var url = Uri.https(
      apiurlemailtoken,
      '$getemailverifytoken/send_token',
    );

    try {
      final response = await http.post(url, body: {"email": "$email"});

      print(response.body);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        isemailwidgitconverter = true;

        snackAlert(ctx, SnackTypes.success, responseData['message'].toString());

        return notifyListeners();
      } else {
        snackAlert(ctx, SnackTypes.warning, 'Some thing went wrong!!');
        return notifyListeners();
      }
    } catch (ctx) {
      {
        print('error verify email token');
      }
      return;
    }
  }

  ////

////// email verify otp
  var sucessotp;
  Future<void> sendOtp(ctx, email, token) async {
    var url = Uri.https(
      apiurlemailtoken,
      '$getemailverifytoken/verify_otp_email',
    );

    try {
      final response =
          await http.post(url, body: {"email": "$email", "token": "$token"});

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        sucessotp = response.statusCode;
        snackAlert(ctx, SnackTypes.success, responseData['message'].toString());

        return notifyListeners();
      } else {
        snackAlert(ctx, SnackTypes.warning, responseData['message'].toString());
        return notifyListeners();
      }
    } catch (ctx) {
      {
        print('error verify email token');
      }
      return;
    }
  }

  ///create loan api
  var _createloan;

  get createloan {
    return _createloan;
  }

  // Loan ID
  String _loanid = '';

  String get loanid {
    return _loanid;
  }

  bool result = false;

  Future<void> getCreateLoan() async {
    var url = Uri.https(
      loanApiUrl,
      '$loanApiVersion/create_loan',
    );

    String myJSON =
        '{"deposit":{"currency_code":"$from_code","currency_network":"$from_network","expected_amount":"$amount"},"loan":{"currency_code":"$to_code","currency_network":"$to_network"},"ltv_percent":"$ltv_percent", "referral":"" }';
    var data = jsonEncode(myJSON);

    try {
      final response =
          await http.post(url, body: {'parameters': data}, headers: headers1);

      final responseData = json.decode(response.body);

      if (responseData['result']) {
        result = responseData['result'];

        _loanid = responseData['response']['loan_id'];

        _createloan = responseData['response'];

        return notifyListeners();
      } else {
        _loanestimate = {};
        return notifyListeners();
      }
    } on BuildContext catch (mycontext, ctx) {
      {
        snackAlert(mycontext, ctx, 'Coin is not Avaliable');
      }
      return;
    }
  }

  ////  GET Loan startus api /////////////
  ///

  var _loanstatus;

  get loanstatus {
    return _loanstatus;
  }

  Future<void> getLoanStatus(loanid) async {
    var url = Uri.https(
      loanApiUrl,
      '$loanApiVersion/get_loan_status',
    );

    var data = {'loan_id': loanid};

    var body = jsonEncode(data);

    try {
      final response = await http.post(url, headers: headers, body: body);

      final responseData = json.decode(response.body);
      if (responseData['result']) {
        _loanstatus = responseData['response'];

        //  print(_loanestimate);
        return notifyListeners();
      } else {
        _loanstatus = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  bool _isConfirm = false;

  bool get isConfirm {
    return _isConfirm;
  }

  Future<void> getConfirm(ctx, myloanid, reciveraddress, email) async {
    var url = Uri.https(
      loanApiUrl,
      '$loanApiVersion/confirm_loan',
    );
    print(url);

    var data = {
      'loan_id': '$myloanid',
      "receive_address": '$reciveraddress',
      "email": '$email'
    };

    var body = jsonEncode(data);
    print(data);

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('checkk...');
      print(response.statusCode);
      final responseData = json.decode(response.body);
      print(responseData);

      if (responseData['result']) {
        _isConfirm = responseData['result'];
        return notifyListeners();
      } else {
        _isConfirm = false;
        snackAlert(ctx, SnackTypes.errors, responseData['response']);
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      snackAlert(
        ctx,
        SnackTypes.errors,
        'Failed to process, please try again.',
      );
      _isConfirm = false;
      return notifyListeners();
    }
  }

  // Get customer 2FA
  Map _customer2FA = {};

  Map get cutomer2FA {
    return _customer2FA;
  }

  Future<void> getCustomer2FA(ctx, formData) async {
    var url = Uri.https(
      loanApiUrl,
      '/customers/get_customer_2fa',
    );

    var body = jsonEncode(formData);
    print(body);

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = json.decode(response.body);

      if (responseData['status'] == 200) {
        _customer2FA = responseData;
        return notifyListeners();
      } else {
        _customer2FA = {};
        snackAlert(ctx, SnackTypes.errors, responseData['response']);
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      snackAlert(
        ctx,
        SnackTypes.errors,
        'Failed to process, please try again.',
      );
      return;
    }
  }

  // Verify 2FA
  Future<bool> verify2FACode(ctx, formData) async {
    var url = Uri.https(
      loanApiUrl,
      '/customers/verify_the_code',
    );

    var body = jsonEncode(formData);

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = json.decode(response.body);

      print(responseData);

      if (responseData['status'] == 200) {
        return true;
      } else {
        showAlert(
          ctx,
          Icon(Icons.error),
          'Error',
          [
            Text('${responseData['message']}'),
          ],
          'Ok',
        );
        return false;
      }
    } catch (error) {
      print(error);
      showAlert(
        ctx,
        Icon(Icons.error),
        'Error',
        [
          Text('Failed to process, please try again.'),
        ],
        'Ok',
      );
      return false;
    }
  }

  ////// loan history api //
  ///

  var _myloanhistory;

  get myloanhistory {
    return _myloanhistory;
  }

  Future<void> getLoanHistory(email) async {
    var url = Uri.https(
      loanApiUrl,
      '$loanhistory/Loan_History_Email',
    );

    var data = {"email": '$email'};
    var loanstatus;
    var body = jsonEncode(data);

    try {
      final response = await http.post(url, headers: headers, body: body);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        loanstatus = responseData['status'];

        _myloanhistory = responseData;

        print(loanstatus);

        return notifyListeners();
      } else {
        _myloanhistory = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  // Loan details
  Map _loanDetails = {};

  Map get loanDetails {
    return _loanDetails;
  }

  void setLoanDetails(details) {
    _loanDetails = details;
    notifyListeners();
  }
}
