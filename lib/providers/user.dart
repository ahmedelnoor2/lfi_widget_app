import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';

class User with ChangeNotifier {
  Map _googleAuth = {};
  Map _depositList = {};

  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'exchange-token': '',
  };

  Map get googleAuth {
    return _googleAuth;
  }

  Future<void> toggleFeeCoinOpen(ctx, auth, value) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/user/update_fee_coin_open',
    );

    var postData = json.encode({
      "useFeeCoinOpen": "$value",
    });

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success,
            'Pay with LYO Credit ${value == 1 ? 'enabled' : 'disabled'}.');
        return;
      } else {
        snackAlert(
            ctx, SnackTypes.errors, 'Failed to update, please try again.');
        return;
      }
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  Future<void> getGoogleAuthCode(ctx, auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/user/toopen_google_authenticator',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _googleAuth = responseData['data'];
        notifyListeners();
        return;
      } else {
        _googleAuth = {};
        notifyListeners();
        return;
      }
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Server Error');
      return;
    }
  }

  Future<void> verifyGoogleCode(ctx, auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/user/google_verify',
    );

    var postData = json.encode({
      "googleCode": formData['googleCode'],
      "googleKey": formData['googleKey'],
      "loginPwd": formData['loginPwd'],
    });

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, 'Google authenticator activated');
        auth.getUserInfo(ctx);
        Navigator.pop(ctx);
        return;
      } else {
        snackAlert(ctx, SnackTypes.errors, '${responseData['msg']}');
        return;
      }
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  Future<void> getDepositLists(auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/record/deposit_list',
    );

    var postData = json.encode({
      "coinSymbol": formData['coinSymbol'],
      "page": formData['page'],
      "pageSize": formData['pageSize'],
    });

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _depositList = responseData['data'];
        notifyListeners();
        return;
      } else {
        _depositList = {};
        notifyListeners();
        return;
      }
    } catch (error) {
      print(error);
      return;
    }
  }

  // Invitaion Information
  Map _userInvitaion = {};

  Map get userInvitation {
    return _userInvitaion;
  }

  Future<void> getUserInvitaionInfo(ctx, auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$incrementApi/invitation/pageConfig',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == 0) {
        _userInvitaion = responseData['data'];
        notifyListeners();
        return;
      } else {
        _userInvitaion = {};
        notifyListeners();
        return;
      }
    } catch (error) {
      print(error);
      return;
    }
  }
}
