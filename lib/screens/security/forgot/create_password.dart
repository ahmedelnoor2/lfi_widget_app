import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/screens/security/forgot/forgotemailform.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'forgotlphoneform.dart';

class Createpassword extends StatefulWidget {
  static const routeName = '/createpassword';
  const Createpassword({Key? key}) : super(key: key);

  @override
  State<Createpassword> createState() => _CreatepasswordState();
}

class _CreatepasswordState extends State<Createpassword>
    with SingleTickerProviderStateMixin {
  String _versionNumber = '0.0';

  final _formLoginKey = GlobalKey<FormState>();

  final TextEditingController _loginpasswordcontroller =
      TextEditingController();

  bool _newPassSecure = true;
  bool _confirmPassSecure = true;

  @override
  void initState() {
    super.initState();
    checkVersion();
  }

  Future<void> checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _versionNumber = packageInfo.version;
    });
  }

  Future<void> resetPasswordStepThree() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.resetForgotPasswordStepThree(context, {
      'loginPword': _loginpasswordcontroller.text,
      'token': auth.forgotStepOne['data']['token'],
    });
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: true);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: width * 0.2),
        child: Column(
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
                      auth.setForgotStepOne({});
                      auth.setEmailValidResponse({});
                      auth.setSmsValidResponse({});
                      auth.setResetResponseStepTwo({});
                      Navigator.pop(context);
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
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: width * 0.03),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding:
                                EdgeInsets.only(bottom: 0, left: width * 0.05),
                            child: const Text(
                              'Reset password',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding:
                                EdgeInsets.only(bottom: 0, left: width * 0.05),
                            child: Text(
                              'It is forbidden to withdraw coins within 48\nhours after resetting the login password',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: Column(
                      children: [
                        Form(
                          key: _formLoginKey,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _loginpasswordcontroller,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter New password';
                                    }
                                    return null;
                                  },
                                  obscureText: _newPassSecure,
                                  decoration: InputDecoration(
                                    // border: OutlineInputBorder(),
                                    labelText: 'New password',
                                    suffix: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _newPassSecure = !_newPassSecure;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          right: 10,
                                          left: 10,
                                        ),
                                        child: _newPassSecure
                                            ? Icon(Icons.visibility)
                                            : Icon(Icons.visibility_off),
                                      ),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Confirm password';
                                    }
                                    return null;
                                  },
                                  obscureText: _confirmPassSecure,
                                  decoration: InputDecoration(
                                    // border: OutlineInputBorder(),
                                    labelText: 'Confirm password',
                                    suffix: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _confirmPassSecure =
                                              !_confirmPassSecure;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          right: 10,
                                          left: 10,
                                        ),
                                        child: _confirmPassSecure
                                            ? Icon(Icons.visibility)
                                            : Icon(Icons.visibility_off),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: height * 0.03),
                          width: width * 0.93,
                          child: LyoButton(
                            text: 'Next',
                            active: true,
                            isLoading: auth.isforgotloader,
                            activeColor: linkColor,
                            activeTextColor: Colors.black,
                            onPressed: () {
                              if (_formLoginKey.currentState!.validate()) {
                                resetPasswordStepThree();
                              } else {
                                snackAlert(context, SnackTypes.warning,
                                    'Please enter password');
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
