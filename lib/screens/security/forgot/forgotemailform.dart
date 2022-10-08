import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:provider/provider.dart';

import '../../../utils/Colors.utils.dart';

class Forgotemailform extends StatefulWidget {
  const Forgotemailform({Key? key}) : super(key: key);

  @override
  _ForgotemailformState createState() => _ForgotemailformState();
}

class _ForgotemailformState extends State<Forgotemailform> {
  final GlobalKey<FormState> _formLoginKey = GlobalKey<FormState>();

  final TextEditingController _gauthController = TextEditingController();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _smscontroller = TextEditingController();

  late Timer _timer;
  int _start = 90;
  bool _startTimer = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _gauthController.dispose();
    _emailcontroller.dispose();
    _smscontroller.dispose();

    super.dispose();
  }

  void startTimer() {
    setState(() {
      _startTimer = true;
    });
    emailValidCode();
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _startTimer = false;
            _timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> forgotPasswordStepOne() async {
    var auth = Provider.of<Auth>(context, listen: false);
    await auth.forgotPasswordStepOne(context, {
      'geetest_challenge': 'sys_conf_validate',
      'geetest_seccode': 'sys_conf_validate',
      'geetest_validate': 'sys_conf_validate',
      'token': true,
      'verificationType': '0',
      'email': _emailcontroller.text,
    });
  }

  Future<void> emailValidCode() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.emailValidCode(context, {
      'operationType': '3',
      'token': auth.forgotStepOne['token'],
    });
  }

  Future<void> forgotPasswordStepTwo() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.resetForgotPasswordStepTwo(context, {
      'certifcateNumber': '',
      'googleCode':
          _gauthController.text.isNotEmpty ? _gauthController.text : '',
      'emailCode': _smscontroller.text,
      'token': auth.forgotStepOne['token'],
    });
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: true);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 10,
          ),
          Form(
            key: _formLoginKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailcontroller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email address';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      // border: OutlineInputBorder(),
                      labelText: 'Email Address',
                    ),
                  ),
                  auth.forgotStepOne.isNotEmpty
                      ? TextFormField(
                          controller: _smscontroller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email verifiacation code';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              // border: OutlineInputBorder(),
                              labelText: 'Email verification code',
                              suffixIcon: GestureDetector(
                                onTap: _startTimer
                                    ? null
                                    : () {
                                        setState(() {
                                          _start = 90;
                                        });
                                        startTimer();
                                      },
                                child: Container(
                                  child: Text(
                                    _startTimer
                                        ? '${_start}s Get it again'
                                        : 'Click to send',
                                    style: TextStyle(
                                      color: _startTimer
                                          ? secondaryTextColor
                                          : linkColor,
                                    ),
                                  ),
                                  margin: const EdgeInsets.all(15.0),
                                  padding: const EdgeInsets.all(3.0),
                                ),
                              )),
                        )
                      : Container(),
                  auth.forgotStepOne['isGoogleAuth'] == '1'
                      ? TextFormField(
                          controller: _gauthController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter google auth';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Google Auth',
                          ))
                      : Container()
                ],
              ),
            ),
          ),
          Container(
            width: width * 0.93,
            child: LyoButton(
              text: 'Next',
              active: true,
              isLoading: auth.isforgotloader,
              activeColor: linkColor,
              activeTextColor: Colors.black,
              onPressed: () {
                if (_formLoginKey.currentState!.validate()) {
                  if (auth.emailValidredponse['code'] == '0') {
                    forgotPasswordStepTwo().whenComplete(() {
                      if (auth.resetResponseStepTwo['msg'] == 'suc') {
                        Navigator.pushNamed(context, '/createpassword');
                      }
                    });
                  } else {
                    forgotPasswordStepOne();
                  }
                } else {
                  snackAlert(context, SnackTypes.warning,
                      'Please enter Email Address');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
