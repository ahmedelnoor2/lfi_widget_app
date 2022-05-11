import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'exchange-token': '',
  };

  String _emailVerificationToken = '';
  String _loginVerificationToken = '';
  String authToken = '';

  Map _userInfo = {};

  String get emailVerificationToken {
    return _emailVerificationToken;
  }

  String get loginVerificationToken {
    return _loginVerificationToken;
  }

  Map get userInfo {
    return _userInfo;
  }

  Future<void> checkLogin(ctx) async {
    final prefs = await SharedPreferences.getInstance();
    final String? catchedAuthToken = prefs.getString('authToken');
    authToken = catchedAuthToken ?? '';
    _loginVerificationToken = authToken;
    headers['exchange-token'] = authToken;
    await getUserInfo();
    notifyListeners();
  }

  Future<String> getUserInfo() async {
    var url = Uri.https(
      apiUrl,
      '$exApi/common/user_info',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == '0') {
        _userInfo = responseData['data'];
      } else {
        _userInfo = {};
      }
      return '';
    } catch (error) {
      return '';
      // throw error;
    }
  }

  Future<void> logout(ctx) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/user/login_out',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == "0") {
        _loginVerificationToken = '';
        _userInfo = {};
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', _loginVerificationToken);
        notifyListeners();
        Navigator.pushNamedAndRemoveUntil(ctx, '/', (route) => false);
      }
    } catch (error) {
      // throw error;
    }
  }

  Future<String> login(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/user/login_in',
    );

    var postData = json.encode({
      'csessionid': formData['csessionid'],
      'mobileNumber': formData['mobileNumber'],
      'loginPword': formData['loginPword'],
      'scene': formData['scene'],
      'sig': formData['sig'],
      'token': formData['token'],
      'verificationType': formData['verificationType'],
    });

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == 0) {
        _loginVerificationToken = responseData['data']['token'];
        notifyListeners();
        return _loginVerificationToken;
      } else {
        snackAlert(ctx, SnackTypes.errors, responseData['msg']);
      }

      return '';
    } catch (error) {
      return '';
      // throw error;
    }
  }

  Future<String> confirmLoginCode(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/user/confirm_login',
    );

    var postData = json.encode({
      'emailCode': formData['emailCode'],
      'token': formData['token'],
    });

    print(postData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['code'] == 0) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', _loginVerificationToken);
        snackAlert(ctx, SnackTypes.success, 'Email is successfully verified.');
      } else {
        snackAlert(ctx, SnackTypes.errors, responseData['msg']);
      }

      return '${responseData['code']}';
    } catch (error) {
      print(error);
      snackAlert(ctx, SnackTypes.errors, 'Server Error!');
      return '0';
      // throw error;
    }
  }

  Future<String> checkEmailRegistration(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/user/reg_email_chk_info/',
    );

    var postData = json.encode({
      'csessionid': formData['csessionid'],
      'email': formData['email'],
      'invitedCode': formData['invitedCode'],
      'loginPword': formData['loginPword'],
      'newPassword': formData['newPassword'],
      'scene': formData['scene'],
      'sig': formData['sig'],
      'token': formData['token'],
      'verificationType': formData['verificationType'],
    });

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == '0') {
        _emailVerificationToken = responseData['data']['token'];
        _loginVerificationToken = _emailVerificationToken;
        return _emailVerificationToken;
      } else {
        snackAlert(ctx, SnackTypes.errors, responseData['msg']);
      }

      return '';
    } catch (error) {
      print(error);
      return '';
      // throw error;
    }
  }

  Future<String> sendEmailValidCode(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/v4/common/emailValidCode',
    );

    var postData = json.encode({
      'token': formData['token'],
      'operationType': formData['operationType'],
    });

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['code'] == '0') {
        snackAlert(
            ctx, SnackTypes.success, 'Verification code sent to your email.');
      } else {
        snackAlert(ctx, SnackTypes.errors, responseData['msg']);
      }

      return '';
    } catch (error) {
      print(error);
      snackAlert(ctx, SnackTypes.errors, 'Server Error!');
      return '';
      // throw error;
    }
  }

  Future<String> confirmEmailCode(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/user/reg_email_confirm',
    );

    var postData = json.encode({
      'emailCode': formData['emailCode'],
      'token': formData['token'],
    });

    print(postData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['code'] == '0') {
        _loginVerificationToken = responseData['data']['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', _loginVerificationToken);
        snackAlert(ctx, SnackTypes.success, 'Email is successfully verified.');
      } else {
        snackAlert(ctx, SnackTypes.errors, responseData['msg']);
      }

      return responseData['code'];
    } catch (error) {
      print(error);
      snackAlert(ctx, SnackTypes.errors, 'Server Error!');
      return '0';
      // throw error;
    }
  }
}
