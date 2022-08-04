import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:provider/provider.dart';

import '../../../utils/Colors.utils.dart';

class Forgotphoneform extends StatefulWidget {
  const Forgotphoneform({Key? key}) : super(key: key);

  @override
  _ForgotphoneformState createState() => _ForgotphoneformState();
}

class _ForgotphoneformState extends State<Forgotphoneform> {
  final GlobalKey<FormState> _formLoginKey = GlobalKey<FormState>();
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _smscontroller = TextEditingController();
  @override
  @override
  void initState() {
    super.initState();
  }

  Future<void> forgotPasswordStepOne() async {
    var auth = Provider.of<Auth>(context, listen: false);
    await auth.forgotPasswordStepOne(context, {
      'geetest_challenge': 'sys_conf_validate',
      'geetest_seccode': 'sys_conf_validate',
      'geetest_validate': 'sys_conf_validate',
      'token': true,
      'verificationType': '0',
      'mobileNumber': _phonecontroller.text,
    });
  }

  Future<void> smsValidCode() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.smsValidCode(context, {
      'operationType': '24',
      'smsType': '0',
      'token': auth.forgotStepOne['data']['token'],
    });
  }

  Future<void> forgotPasswordStepTwo() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.resetForgotPasswordStepTwo(context, {
      'certifcateNumber': '12345',
      'googleCode': '',
      'smsCode': _smscontroller.text,
      'token': auth.forgotStepOne['data']['token'],
    });
  }

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
                    controller: _phonecontroller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Mobile Phone';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      // border: OutlineInputBorder(),
                      labelText: 'Mobile Number',
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
                              labelText: 'Mobile verification code',
                              suffixIcon: GestureDetector(
                                onTap: () async {
                                  smsValidCode();
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
              onPressed: () async {
                if (_formLoginKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  if (auth.smsValidredponse['code'] == '0') {
                    forgotPasswordStepTwo().whenComplete(() {
                      if (auth.resetResponseStepTwo['msg'] == 'suc') {
                        Navigator.pushNamed(context, '/createpassword');
                      }
                    });
                  } else {
                    forgotPasswordStepOne();
                  }
                  //snackAlert(context, SnackTypes.warning, 'Processing...');
                  /// Navigator.pushNamed(context, '/createpassword');
                } else {
                  snackAlert(context, SnackTypes.warning,
                      'Please enter Mobile number');
                }
              },
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
