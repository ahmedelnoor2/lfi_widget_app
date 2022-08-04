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

  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _smscontroller = TextEditingController();

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
      'token': auth.forgotStepOne['data']['token'],
    });
  }

  Future<void> forgotPasswordStepTwo() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.resetForgotPasswordStepTwo(context, {
      'certifcateNumber': '',
      'googleCode': '',
      'emailCode': _smscontroller.text,
      'token': auth.forgotStepOne['data']['token'],
    });
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
                  auth.forgotStepOne['code'] == '0'
                      ? TextFormField(
                          controller: _smscontroller,
                          validator: (value) {
                            // if (value == null || value.isEmpty) {
                            //   return 'Please enter Mobilr Number';
                            // }
                            // return null;
                          },
                          decoration: InputDecoration(
                              // border: OutlineInputBorder(),
                              labelText: 'Email verification code',
                              suffixIcon: GestureDetector(
                                onTap: () async {
                                  emailValidCode();
                                },
                                child: Container(
                                  child: Text(
                                    'Click to send',
                                    style: TextStyle(
                                      color: selecteditembordercolour,
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
                          validator: (value) {
                            // if (value == null || value.isEmpty) {
                            //   return 'Please enter Mobilr Number';
                            // }
                            // return null;
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
