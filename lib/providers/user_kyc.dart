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

class UserKyc with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'exchange-token': '',
  };

  // samsub token
  Map _samsubToken = {};

  Map get samsubToken {
    return _samsubToken;
  }

  Future<void> getSamsubToken(ctx, auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/sumsub/get_access_token',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _samsubToken = responseData['data'];
        notifyListeners();
      } else {
        snackAlert(
            ctx, SnackTypes.errors, 'Faild to start, please try again later');
        _samsubToken = {};
        notifyListeners();
      }
      return;
    } catch (error) {
      snackAlert(
          ctx, SnackTypes.errors, 'Server error, please try again later');
      notifyListeners();
      return;
    }
  }

  Future<void> changeSamsubToken(ctx, auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/sumsub/change_level_and_create_info',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.warning, 'Processing verfication');
        notifyListeners();
      } else {
        snackAlert(
            ctx, SnackTypes.errors, 'Faild to start, please try again later');
        _samsubToken = {};
        notifyListeners();
      }
      return;
    } catch (error) {
      snackAlert(
          ctx, SnackTypes.errors, 'Server error, please try again later');
      notifyListeners();
      return;
    }
  }

  Future<void> getAccessSamsubToken(ctx, auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/sumsub/get_access_token',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _samsubToken = responseData['data'];
        notifyListeners();
      } else {
        snackAlert(
            ctx, SnackTypes.errors, 'Faild to start, please try again later');
        _samsubToken = {};
        notifyListeners();
      }
      return;
    } catch (error) {
      snackAlert(
          ctx, SnackTypes.errors, 'Server error, please try again later');
      notifyListeners();
      return;
    }
  }
}
