import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart/entity/index.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';

class LoanProvider with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
  };

  Map<String, String> headers1 = {
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  var issenderenable = false;
  var isreciverenable = false;

  // Currencies
  List _sendercurrences = [];

  List get sendercurrences {
    return _sendercurrences;
  }

  List _recivercurrencies = [];

  List get recivercurrencies {
    return _recivercurrencies;
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

      final responseData = json.decode(response.body);

      if (responseData['result']) {
        _sendercurrences = responseData['response'];

        _recivercurrencies = responseData['response'];

        isreciverenable = responseData['response']['is_loan_deposit_enabled'];
        issenderenable = responseData['response']['is_loan_deposit_enabled'];

        print(responseData['response']['is_loan_receive_enabled']);

        return notifyListeners();
      } else {
        _sendercurrences = [];
        _recivercurrencies = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

////Loan estimates api//
  ///
  var _loanestimate;

  get loanestimate {
    return _loanestimate;
  }

  var from_code = 'BTC';
  var from_network = 'BTC';
  var to_code = 'USDT';
  var to_network = 'ETH';
  var amount = 1;
  var exchange = 'direct';
  var ltv_percent = 0.8;

  Future<void> getloanestimate() async {
    var url = Uri.https(loanApiUrl, loansApiestimate, {
      'from_code': 'BTC',
      'from_network': 'BTC',
      'to_code': 'USDT',
      'to_network': 'ETH',
      'amount': '1',
      'exchange': 'direct',
      'ltv_percent': '$ltv_percent'
    });

    try {
      final response = await http.get(
        url,
        headers: headers,
      );
      final responseData = json.decode(response.body);

      if (responseData['result']) {
        _loanestimate = responseData['response'];

        print(_loanestimate);
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
        '{"deposit":{"currency_code":"BTC","currency_network":"BTC","expected_amount":"1"},"loan":{"currency_code":"USDT","currency_network":"ETH"},"ltv_percent":"0.8", "referral":"" }';
    var data = jsonEncode(myJSON);
    try {
      final response =
          await http.post(url, body: {'parameters': data}, headers: headers1);
      final responseData = json.decode(response.body);
      if (responseData['result']) {
        result = responseData['result'];

        loanid = responseData['response']['loan_id'];
        print(loanid);
        _createloan = responseData['response'];

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

      print(response.statusCode);

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

  /////// loan Confirm api ///

  Future<void> getConfirm(reciveraddress, email) async {
    var url = Uri.https(
      loanApiUrl,
      '$loanApiVersion/confirm_loan',
    );

    var data = {
      'loan_id': '4689901146',
      "receive_address": '$reciveraddress',
      "email": '$email'
    };

    var body = jsonEncode(data);

    try {
      final response = await http.post(url, headers: headers, body: body);

      final responseData = json.decode(response.body);
      if (responseData['result']) {
        //  _loanstatus= responseData['response'];

        //  print(_loanestimate);
        return notifyListeners();
      } else {
        // _loanstatus = [];
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
