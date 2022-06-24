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
  var ltv_percent =0.8;

  Future<void> getloanestimate() async {
    var url = Uri.https(loanApiUrl, loansApiestimate, {
      'from_code': 'BTC',
      'from_network': 'BTC',
      'to_code': 'USDT',
      'to_network': 'ETH',
      'amount': '1',
      'exchange': 'direct',
      'ltv_percent':'$ltv_percent'
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
}
