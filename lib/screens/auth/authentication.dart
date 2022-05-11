import 'package:flutter/material.dart';
import 'package:lyotrade/screens/auth/emailverification.dart';
import 'package:lyotrade/screens/auth/login.dart';
import 'package:lyotrade/screens/auth/signup.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:provider/provider.dart';

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
  Map _captchaVerification = {};

  Future<String> processSignup(value) async {
    print(_captchaVerification);
    var auth = Provider.of<Auth>(context, listen: false);
    String emailToken = await auth.checkEmailRegistration(context, {
      'csessionid': _captchaVerification['sessionId'],
      'email': value['email'],
      'invitedCode': value['invitedCode'],
      'loginPword': value['loginPword'],
      'newPassword': value['newPassword'],
      'scene': 'other',
      'sig': _captchaVerification['sig'],
      'token': _captchaVerification['token'],
      'verificationType': '1',
    });
    return emailToken;
  }

  Future<String> processLogin(value) async {
    print(_captchaVerification);
    var auth = Provider.of<Auth>(context, listen: false);
    String loginToken = await auth.login(context, {
      'csessionid': _captchaVerification['sessionId'],
      'mobileNumber': value['mobileNumber'],
      'loginPword': value['loginPword'],
      'scene': 'other',
      'sig': _captchaVerification['sig'],
      'token': _captchaVerification['token'],
      'verificationType': '1',
    });

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

    return Scaffold(
      appBar: appBar(context, null),
      body: Container(
        child: Column(
          children: [
            _verifyEmail
                ? EmailVerification(
                    token: _token,
                    operationType: _authLogin ? '4' : '1',
                    toggleEmailVerification: () {
                      toggleEmailVerification();
                    },
                  )
                : _authLogin
                    ? Login(onLogin: (value) async {
                        print(value);
                        String result = await processLogin(value);
                        print('Login token: $result');
                        if (result.isNotEmpty) {
                          setState(() {
                            _token = result;
                            _verifyEmail = true;
                          });
                          // showModalBottomSheet<void>(
                          //   context: context,
                          //   builder: (BuildContext context) {
                          //     return EmailVerification(
                          //       token: result,
                          //       operationType: '4',
                          //     );
                          //   },
                          // );
                        }
                      }, onCaptchaVerification: (value) {
                        setState(() {
                          _captchaVerification = value;
                        });
                      })
                    : Signup(
                        onRegister: (value) async {
                          print(value);
                          String result = await processSignup(value);
                          print('Email token: $result');
                          if (result.isNotEmpty) {
                            setState(() {
                              _token = result;
                              _verifyEmail = true;
                            });
                            // showModalBottomSheet<void>(
                            //   context: context,
                            //   builder: (BuildContext context) {
                            //     return EmailVerification(
                            //       token: result,
                            //       operationType: '1',
                            //     );
                            //   },
                            // );
                          }
                        },
                        onCaptchaVerification: (value) {
                          setState(() {
                            _captchaVerification = value;
                          });
                        },
                      ),
            _verifyEmail
                ? Container()
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        _authLogin = !_authLogin;
                      });
                    },
                    child: Text(
                      _authLogin
                          ? 'Don\'t have an account? Singup'
                          : 'Already have an account? Login',
                      style: TextStyle(color: Colors.blue[200]),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
