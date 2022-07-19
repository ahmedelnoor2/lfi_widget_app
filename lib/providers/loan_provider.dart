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

  Future<void> getCurrencies() async {
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
            _toCurrencies['${resData['code']}(${resData['network']})'] =
                resData;
            _toCurrenciesList.add('${resData['code']}(${resData['network']})');

            if ('${resData['code']}(${resData['network']})' ==
                _selectedToCurrencyCoin) {
              _toSelectedCurrency = resData;
              to_code = _toSelectedCurrency['code'];
              to_network = _toSelectedCurrency['network'];
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
  var _loanestimate;

  get loanestimate {
    return _loanestimate;
  }

  String from_code = 'BTC';
  String from_network = 'BTC';
  String to_code = 'USDT';
  String to_network = 'ETH';
  var amount = 1;
  var exchange = 'direct';
  var ltv_percent = 0.5;

  final TextEditingController _textEditingControllereciver =
      TextEditingController();

  var yourloan = 11095.39;

  Future<void> getloanestimate() async {
    var url = Uri.https(loanApiUrl, loansApiestimate, {
      'from_code': '$from_code',
      'from_network': '$from_network',
      'to_code': '$to_code',
      'to_network': '$to_network',
      'amount': '$amount',
      'exchange': '$exchange',
      'ltv_percent': '$ltv_percent'
    });

    try {
      final response = await http.get(
        url,
        headers: headers,
      );
      print(url);
      final responseData = json.decode(response.body);
      print(responseData);

      if (responseData['result']) {
        _loanestimate = responseData['response'];
        //  amount=responseData['response']['amount_from'];
        yourloan = responseData['response']['down_limit'];

        print(yourloan);

        return notifyListeners();
      } else {
        _loanestimate = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

///////recive email for verify//
  ///
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
        isemailwidgitconverter=
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

  bool isemailwidgitconverter = false;

////// email verify otp
  Future<void> getemailverfiyOtp(ctx, email, token) async {
    var url = Uri.https(
      apiurlemailtoken,
      '$getemailverifytoken/verify_otp_email',
    );

    try {
      final response =
          await http.post(url, body: {"email": "$email", "token": "$token"});

      print(response.body);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        
       isemailwidgitconverter =true;

      
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

  ///create loan api
  var _createloan;

  get createloan {
    return _createloan;
  }

  var loanid;

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

        loanid = responseData['response']['loan_id'];
        print('check loan ...');
        print(loanid);

        _createloan = responseData['response'];

        return notifyListeners();
      } else {
        _loanestimate = [];
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

  var isconfirm;
  Future<void> getConfirm(myloanid, reciveraddress, email) async {
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
      print(response.body);
      final responseData = json.decode(response.body);

      if (responseData['result'] == 200) {
        isconfirm = responseData['result'];
        return notifyListeners();
      } else {
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
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
}
