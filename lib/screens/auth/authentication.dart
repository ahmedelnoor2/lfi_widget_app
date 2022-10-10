import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/auth/emailverification.dart';
import 'package:lyotrade/screens/auth/login.dart';
import 'package:lyotrade/screens/auth/signup.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Authentication extends StatefulWidget {
  static const routeName = '/authentication';

  const Authentication({Key? key}) : super(key: key);

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  bool _checkingSession = true;
  bool _authLogin = true;
  String _token = '';
  bool _verifyEmail = false;
  bool _emailVerification = true;
  String _countryCode = '';
  Map _captchaVerification = {};
  bool _isMobile = true;
  String _verificationType = '0';

  String _versionNumber = '0.0';

  @override
  void initState() {
    checkVerificationMethod();
    checkVersion();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkVerificationMethod() {
    var public = Provider.of<Public>(context, listen: false);

    if (public.publicInfo.isNotEmpty) {
      setState(() {
        _verificationType = public.publicInfo['switch']['verificationType'];
      });
    }

    checkCachedLogin();
  }

  Future<void> checkCachedLogin() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var isAuth = await auth.checkLoginSession(context);
    if (!isAuth) {
      if (auth.loginCreds.isNotEmpty) {
        String result = await processLogin(auth.loginCreds);
        if (result.isNotEmpty) {
          setState(() {
            _token = result;
            _verifyEmail = true;
          });
        }
      }
    }
    setState(() {
      _checkingSession = false;
    });
  }

  Future<void> checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _versionNumber = packageInfo.version;
    });
  }

  Future<String> processSignup(value) async {
    var auth = Provider.of<Auth>(context, listen: false);

    if (value['emailSignup']) {
      setState(() {
        _isMobile = false;
        _emailVerification = true;
      });
      Map _formParams = {};
      if (_verificationType == '1') {
        _formParams = {
          'csessionid': kIsWeb
              ? _captchaVerification['csessionid']
              : _captchaVerification['sessionId'],
          'email': value['email'],
          'invitedCode': value['invitedCode'],
          'loginPword': value['loginPword'],
          'newPassword': value['newPassword'],
          'scene': 'other',
          'sig': _captchaVerification['sig'],
          'token': _captchaVerification['token'],
          'verificationType': '1',
        };
      } else {
        _formParams = {
          'geetest_challenge': "sys_conf_validate",
          'geetest_seccode': "sys_conf_validate",
          'geetest_validate': "sys_conf_validate",
          'email': value['email'],
          'invitedCode': value['invitedCode'],
          'loginPword': value['loginPword'],
          'newPassword': value['newPassword'],
          'token': true,
          'verificationType': '0',
        };
      }

      String emailToken =
          await auth.checkEmailRegistration(context, _formParams);
      return emailToken;
    } else {
      setState(() {
        _isMobile = false;
        _emailVerification = false;
        _countryCode = value['countryCode'];
      });

      Map _formParams = {};

      if (_verificationType == '1') {
        _formParams = {
          'csessionid': kIsWeb
              ? _captchaVerification['csessionid']
              : _captchaVerification['sessionId'],
          'countryCode': value['countryCode'],
          'mobileNumber': value['mobileNumber'],
          'invitedCode': value['invitedCode'],
          'loginPword': value['loginPword'],
          'newPassword': value['newPassword'],
          'scene': 'other',
          'sig': _captchaVerification['sig'],
          'token': _captchaVerification['token'],
          'verificationType': '1',
        };
      } else {
        _formParams = {
          'geetest_challenge': "sys_conf_validate",
          'geetest_seccode': "sys_conf_validate",
          'geetest_validate': "sys_conf_validate",
          'countryCode': value['countryCode'],
          'mobileNumber': value['mobileNumber'],
          'invitedCode': value['invitedCode'],
          'loginPword': value['loginPword'],
          'newPassword': value['newPassword'],
          'token': true,
          'verificationType': '0',
        };
      }
      String emailToken =
          await auth.checkMobileRegistration(context, _formParams);
      return emailToken;
    }
  }

  Future<String> processLogin(value) async {
    bool isEmail = value['mobileNumber'].contains(
      RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
          caseSensitive: false),
    );

    setState(() {
      _isMobile = !isEmail;
      _emailVerification = isEmail ? true : false;
    });

    var auth = Provider.of<Auth>(context, listen: false);
    auth.setLoginCreds(value);
    Map _formParams = {};
    if (_verificationType == '1') {
      _formParams = {
        // "geetest_challenge": "sys_conf_validate",
        // "geetest_seccode": "sys_conf_validate",
        // "geetest_validate": "sys_conf_validate",
        'csessionid': kIsWeb
            ? _captchaVerification['csessionid']
            : _captchaVerification['sessionId'],
        'mobileNumber': value['mobileNumber'],
        'loginPword': value['loginPword'],
        "nc": null,
        'scene': 'other',
        'sig': _captchaVerification['sig'],
        'token': _captchaVerification['token'],
        // 'token': true,
        'verificationType': _verificationType,
      };
    } else {
      _formParams = {
        "geetest_challenge": "sys_conf_validate",
        "geetest_seccode": "sys_conf_validate",
        "geetest_validate": "sys_conf_validate",
        // 'csessionid': kIsWeb
        //     ? _captchaVerification['csessionid']
        //     : _captchaVerification['sessionId'],
        'mobileNumber': value['mobileNumber'],
        'loginPword': value['loginPword'],
        "nc": null,
        // 'scene': 'other',
        // 'sig': _captchaVerification['sig'],
        // 'token': _captchaVerification['token'],
        'token': true,
        'verificationType': '0',
      };
    }
    String loginToken = await auth.login(context, _formParams);

    return loginToken;
  }

  void toggleEmailVerification() {
    setState(() {
      _verifyEmail = !_verifyEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);

    return WillPopScope(
      onWillPop: () {
        return onAndroidBackPress(context);
      },
      child: Scaffold(
        // appBar: appBar(context, null),
        body: _checkingSession
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.only(top: width * 0.08),
                child: Container(
                  padding: EdgeInsets.only(top: width * 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        height: height * 0.20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () {
                                auth.setGoogleAuth(false);
                                auth.setLoginCreds({});
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/dashboard',
                                  (route) => false,
                                );
                              },
                              icon: const Icon(Icons.close),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 10, right: 30),
                              child: Column(
                                children: [
                                  const Image(
                                    image: AssetImage('assets/img/logo_s.png'),
                                    width: 100,
                                  ),
                                  Text('v$_versionNumber'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(width * 0.08),
                        child: _verifyEmail
                            ? EmailVerification(
                                token: _token,
                                operationType: _authLogin
                                    ? '4'
                                    : _isMobile
                                        ? '25'
                                        : '1',
                                toggleEmailVerification: () {
                                  toggleEmailVerification();
                                },
                                emailVerification: _emailVerification,
                                currentCoutnry: _countryCode,
                                isMobile: _isMobile,
                              )
                            : _authLogin
                                ? Login(
                                    onLogin: (value, captchaController) async {
                                    // print('--------------------');
                                    // print(captchaController);

                                    String result = await processLogin(value);
                                    if (result.isNotEmpty) {
                                      setState(() {
                                        _token = result;
                                        _verifyEmail = true;
                                      });
                                    } else {
                                      captchaController.reset();
                                    }
                                  }, onCaptchaVerification: (value) {
                                    setState(() {
                                      _captchaVerification = value;
                                    });
                                  })
                                : Signup(
                                    onRegister:
                                        (value, captchaController) async {
                                      String result =
                                          await processSignup(value);
                                      if (result.isNotEmpty) {
                                        setState(() {
                                          _token = result;
                                          _verifyEmail = true;
                                        });
                                      } else {
                                        captchaController.reset();
                                      }
                                    },
                                    onCaptchaVerification: (value) {
                                      setState(() {
                                        _captchaVerification = value;
                                      });
                                    },
                                  ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: _verifyEmail
                              ? Container()
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _authLogin = !_authLogin;
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _authLogin
                                            ? 'Don\'t have an account?'
                                            : 'Already have an account?',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          _authLogin ? 'Sign Up' : 'Sign In',
                                          style: TextStyle(
                                            color: linkColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
