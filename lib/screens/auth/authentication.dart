import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/auth/emailverification.dart';
import 'package:lyotrade/screens/auth/login.dart';
import 'package:lyotrade/screens/auth/signup.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Authentication extends StatefulWidget {
  static const routeName = '/authentication';

  const Authentication({Key? key}) : super(key: key);

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
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
  }

  Future<void> checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _versionNumber = packageInfo.version;
    });
  }

  Future<String> processSignup(value) async {
    // print(_captchaVerification);
    var auth = Provider.of<Auth>(context, listen: false);

    if (value['emailSignup']) {
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
          'scene': 'other',
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
        _emailVerification = false;
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
          'scene': 'other',
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
    String loginToken = await auth.login(context, {
      "geetest_challenge": "sys_conf_validate",
      "geetest_seccode": "sys_conf_validate",
      "geetest_validate": "sys_conf_validate",
      // 'csessionid': kIsWeb
      //     ? _captchaVerification['csessionid']
      //     : _captchaVerification['sessionId'],
      'mobileNumber': value['mobileNumber'],
      'loginPword': value['loginPword'],
      'scene': 'other',
      // 'sig': _captchaVerification['sig'],
      // 'token': _captchaVerification['token'],
      'token': true,
      'verificationType': '0',
    });

    return loginToken;
  }

  void toggleEmailVerification() {
    setState(() {
      _verifyEmail = !_verifyEmail;
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // appBar: appBar(context, null),
        body: SingleChildScrollView(
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
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10, right: 30),
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
                          ? Login(onLogin: (value, captchaController) async {
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
                              onRegister: (value, captchaController) async {
                                String result = await processSignup(value);
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
