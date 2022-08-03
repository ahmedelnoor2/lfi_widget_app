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

class Auth with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'exchange-token': '',
  };

  String _emailVerificationToken = '';
  String _loginVerificationToken = '';
  String authToken = '';
  bool _googleAuth = false;

  Map _userInfo = {};
  bool _isAuthenticated = false;

  String get emailVerificationToken {
    return _emailVerificationToken;
  }

  String get loginVerificationToken {
    return _loginVerificationToken;
  }

  Map get userInfo {
    return _userInfo;
  }

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  bool get googleAuth {
    return _googleAuth;
  }

  // loing creds
  Map _loginCreds = {};

  Map get loginCreds {
    return _loginCreds;
  }

  void setLoginCreds(values) {
    _loginCreds = values;
    notifyListeners();
  }

  // Get Captcha
  Map _captchaData = {};

  Map get captchaData {
    return _captchaData;
  }

  Future<void> getCaptcha() async {
    var url = Uri.https(
      apiUrl,
      '/aliyun/get_aliyun',
    );

    // var postData = json.encode({});

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['msg'] == 'success') {
        _captchaData = responseData['data']['data'];
        notifyListeners();
      } else {
        _captchaData = {};
        notifyListeners();
      }
      // if (responseData['code'] == '0') {
      //   _userInfo = responseData['data'];
      //   _isAuthenticated = true;
      //   notifyListeners();
      // } else {
      //   _userInfo = {};
      //   _isAuthenticated = false;
      //   notifyListeners();
      // }
      return;
    } catch (error) {
      notifyListeners();
      return;
      // throw error;
    }
  }

  Future<void> checkLogin(ctx) async {
    final prefs = await SharedPreferences.getInstance();
    final String? catchedAuthToken = prefs.getString('authToken');
    authToken = catchedAuthToken ?? '';
    _isAuthenticated = catchedAuthToken!.isNotEmpty ? true : false;
    _loginVerificationToken = authToken;
    headers['exchange-token'] = authToken;
    await checkLoginSession(ctx);
    notifyListeners();
  }

  Future<bool> checkLoginSession(ctx) async {
    final prefs = await SharedPreferences.getInstance();
    final String? catchedAuthToken = prefs.getString('authToken');
    authToken = catchedAuthToken ?? '';
    notifyListeners();
    headers['exchange-token'] = authToken;
    authToken = catchedAuthToken ?? '';
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
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else if (responseData['code'] == '10002') {
        _loginVerificationToken = '';
        _userInfo = {};
        _isAuthenticated = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', _loginVerificationToken);
        return false;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  Future<String> getUserInfo(ctx) async {
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
        _isAuthenticated = true;
        notifyListeners();
      } else if (responseData['code'] == '10002') {
        _loginVerificationToken = '';
        _userInfo = {};
        _isAuthenticated = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', _loginVerificationToken);
        snackAlert(ctx, SnackTypes.warning, 'Session has expired');
        Navigator.pushNamed(ctx, '/authentication');
      } else {
        _userInfo = {};
        _isAuthenticated = false;
        notifyListeners();
      }
      return '';
    } catch (error) {
      _userInfo = {};
      _isAuthenticated = false;
      notifyListeners();
      return '';
      // throw error;
    }
  }

  Future<void> checkResponseCode(ctx, code) async {
    if ('$code' == '10002') {
      _loginVerificationToken = '';
      _userInfo = {};
      _isAuthenticated = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', _loginVerificationToken);
      notifyListeners();
      Navigator.pushNamedAndRemoveUntil(
        ctx,
        '/authentication',
        (route) => false,
      );
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
        _loginCreds = {};
        _isAuthenticated = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', _loginVerificationToken);
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      return;
      // throw error;
    }
  }

  Future<String> login(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/user/login_in',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 0) {
        if (responseData['data']['googleAuth'] == '1') {
          _googleAuth = true;
        } else {
          _googleAuth = false;
        }
        _loginVerificationToken = responseData['data']['token'];
        notifyListeners();
        return _loginVerificationToken;
      } else {
        snackAlert(ctx, SnackTypes.errors, getTranslate(responseData['msg']));
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

    var postData = json.encode(formData);

    if (_googleAuth) {
      postData = json.encode({
        'googleCode': formData['emailCode'],
        'token': formData['token'],
      });
    }

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 0) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', _loginVerificationToken);
        snackAlert(ctx, SnackTypes.success, 'Login Success');
      } else {
        snackAlert(ctx, SnackTypes.errors, getTranslate(responseData['msg']));
      }

      return '${responseData['code']}';
    } catch (error) {
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

    var postData = json.encode(formData);

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

  Future<String> checkMobileRegistration(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/user/reg_mobile_chk_info',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == '0') {
        _emailVerificationToken = responseData['data']['token'];
        _loginVerificationToken = _emailVerificationToken;
        return _emailVerificationToken;
      } else {
        snackAlert(ctx, SnackTypes.errors, getTranslate(responseData['msg']));
      }

      return '';
    } catch (error) {
      print(error);
      return '';
      // throw error;
    }
  }

  Future<String> sendStakeMobileValidCode(ctx, formData) async {
    var url = Uri.https(
      serviceApi,
      '$exApi/common/smsValidCode',
    );

    var postData = json.encode(formData);

    print(postData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      print(responseData);

      if (responseData['code'] == '0') {
        showAlert(
          ctx,
          Icon(
            Icons.check,
            color: successColor,
          ),
          'SMS Sent',
          [
            Text('Verification code sent to your mobile.'),
          ],
          'Ok',
        );
      } else {
        showAlert(
          ctx,
          Icon(
            Icons.error,
            color: errorColor,
          ),
          'SMS Error',
          [
            Text(getTranslate(responseData['msg'])),
          ],
          'Ok',
        );
      }

      return '';
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Server Error!');
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
      'email': formData['email'],
      'operationType': formData['operationType'],
    });

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == '0') {
        snackAlert(
            ctx, SnackTypes.success, 'Verification code sent to your email.');
      } else {
        snackAlert(ctx, SnackTypes.errors, getTranslate(responseData['msg']));
      }

      return '';
    } catch (error) {
      print(error);
      snackAlert(ctx, SnackTypes.errors, 'Server Error!');
      return '';
      // throw error;
    }
  }

  Future<String> sendMobileValidCode(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/v4/common/smsValidCode',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        snackAlert(
            ctx, SnackTypes.success, 'Verification code sent to your mobile.');
      } else {
        snackAlert(ctx, SnackTypes.errors, getTranslate(responseData['msg']));
      }

      return '';
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Server Error!');
      return '';
      // throw error;
    }
  }

  Future<String> confirmMobileCode(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/user/mobile_bind_save',
    );

    var postData = json.encode({
      'countryCode': formData['countryCode'],
      'mobileNumber': formData['mobile'],
      'googleCode': formData['googleCode'],
      'smsAuthCode': formData['smsAuthCode'],
    });

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, 'Phone is successfully verified.');
      } else {
        print('Code: ${responseData['code']}');
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

  Future<String> confirmMobileVerification(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/user/reg_mobile_confirm',
    );

    var postData = json.encode({
      'smsCode': formData['smsCode'],
      'token': formData['token'],
    });

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == '0') {
        _loginVerificationToken = responseData['data']['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', _loginVerificationToken);
        snackAlert(ctx, SnackTypes.success, 'Phone is successfully verified.');
      } else {
        print('Code: ${responseData['code']}');
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

  Future<String> confirmEmailCode(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/user/reg_email_confirm',
    );

    var postData = json.encode({
      'emailCode': formData['emailCode'],
      'token': formData['token'],
    });

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _loginVerificationToken = responseData['data']['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', _loginVerificationToken);
        snackAlert(ctx, SnackTypes.success, 'Email is successfully verified.');
      } else {
        snackAlert(ctx, SnackTypes.errors, getTranslate(responseData['msg']));
      }

      return responseData['code'];
    } catch (error) {
      print(error);
      snackAlert(ctx, SnackTypes.errors, 'Server Error!');
      return '0';
      // throw error;
    }
  }

  Future<void> emailUpdate(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/user/email_update',
    );

    var postData = json.encode({
      'email': formData['email'],
      'emailOldValidCode': formData['emailOldValidCode'],
      'emailNewValidCode': formData['emailNewValidCode'],
      'googleCode': formData['googleCode'],
      'smsValidCode': formData['smsValidCode']
    });

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, 'Email is successfully updated.');
        Navigator.pop(ctx);
        return;
      } else {
        print('Code: ${responseData['code']}');
        snackAlert(ctx, SnackTypes.errors, responseData['msg']);
      }

      return responseData['code'];
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Server Error!');
      return;
      // throw error;
    }
  }

  // bind new email
  Future<void> bindNewEmail(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/user/email_bind_save_v4',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, 'Email is successfully added.');
        Navigator.pop(ctx);
        return;
      } else {
        print('Code: ${responseData['code']}');
        snackAlert(ctx, SnackTypes.errors, responseData['msg']);
      }

      return responseData['code'];
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Server Error!');
      return;
      // throw error;
    }
  }

  // Update password
  Future<void> updatePassword(ctx, formData) async {
    var url = Uri.https(
      apiUrl,
      '$exApi/user/password_update',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == '0') {
        snackAlert(
            ctx, SnackTypes.success, 'Password is successfully updated.');
        Navigator.pop(ctx);
        return;
      } else {
        snackAlert(ctx, SnackTypes.errors, responseData['msg']);
      }

      return;
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Server Error!');
      return;
      // throw error;
    }
  }
}
