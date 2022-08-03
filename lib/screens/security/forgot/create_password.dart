import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/screens/security/forgot/forgotemailform.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final _size = MediaQuery.of(context).size;
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
                      Navigator.maybePop(context);
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
                          key:_formLoginKey,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter New password';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    // border: OutlineInputBorder(),
                                    labelText: 'New password',
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Confirm password';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    // border: OutlineInputBorder(),
                                    labelText: 'Confirm password',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: height * 0.03),
                          width: width * 0.93,
                          child: ElevatedButton(
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: selectboxcolour,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 10),
                            ),
                            onPressed: () {
                              if (_formLoginKey.currentState!.validate()) {
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                snackAlert(context, SnackTypes.warning,
                                    'Processing...');
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