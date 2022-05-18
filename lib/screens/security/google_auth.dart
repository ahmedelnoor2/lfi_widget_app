import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/user.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleAuth extends StatefulWidget {
  static const routeName = '/google_auth';
  const GoogleAuth({Key? key}) : super(key: key);

  @override
  State<GoogleAuth> createState() => _GoogleAuthState();
}

class _GoogleAuthState extends State<GoogleAuth> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _googleCode = TextEditingController();
  int _step = 1;

  @override
  void initState() {
    getGoogleAuth();
    super.initState();
  }

  Future<void> getGoogleAuth() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var user = Provider.of<User>(context, listen: false);
    await user.getGoogleAuthCode(context, auth);
  }

  void _launchUrl(_url) async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }

  Future<void> confirmGoogleVeriCode() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var user = Provider.of<User>(context, listen: false);

    await user.verifyGoogleCode(
      context,
      auth,
      {
        "googleCode": _googleCode.text,
        "googleKey": user.googleAuth['googleKey'],
        "loginPwd": _password.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var user = Provider.of<User>(context, listen: true);

    return Scaffold(
      appBar: appBar(context, null),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: _step == 1
            ? _stepOne()
            : _step == 2
                ? _stepTwo(user)
                : _step == 3
                    ? _stepThree(user)
                    : Container(),
      ),
    );
  }

  Widget _stepOne() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: width * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 5),
                    child: CircleAvatar(
                      backgroundColor: secondaryTextColor,
                      radius: 10,
                      child: const Text('1'),
                    ),
                  ),
                  const Text(
                    'APP Download Google Authenticator APP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'iOSApp Store“Authenticator”iOS users Login to the App Store to search for "Authenticator" downloads.”To Login, the Android users need use the app store or a mobile phone browser to search for "Google Authenticator" downloads',
              style: TextStyle(
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        Column(
          children: [
            ListTile(
              onTap: () {
                _launchUrl(Uri(
                  scheme: 'https',
                  host: 'apps.apple.com',
                  path: '/us/app/google-authenticator/id388497605',
                ));
              },
              leading: const CircleAvatar(
                child: Icon(
                  Icons.apple,
                ),
              ),
              title: const Text('App Store'),
              subtitle: const Text('iOS App Store'),
              trailing: const Icon(Icons.chevron_right),
            ),
            ListTile(
              onTap: () {
                _launchUrl(Uri(
                  scheme: 'https',
                  host: 'play.google.com',
                  path:
                      '/store/apps/details?id=com.google.android.apps.authenticator2',
                ));
              },
              leading: const CircleAvatar(
                child: Icon(
                  Icons.android,
                ),
              ),
              title: const Text('Google Play'),
              subtitle: const Text('Android play store'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.only(bottom: width * 0.1),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _step = 2;
              });
            },
            child: const Text('NEXT'),
          ),
        ),
      ],
    );
  }

  Widget _stepTwo(user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: width * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: width * 0.1,
                    padding: const EdgeInsets.only(right: 5),
                    child: CircleAvatar(
                      backgroundColor: secondaryTextColor,
                      radius: 10,
                      child: const Text('2'),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.75,
                    child: const Text(
                      'Scan a QR code with Google Authenticator or enter the key manually',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Open Google Authenticator, scan the QR code below or enter the following key manually to add a verification token',
              style: TextStyle(
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        Column(
          children: [
            user.googleAuth.isNotEmpty
                ? Image.memory(
                    base64Decode(
                      user.googleAuth['googleImg']
                          .split(',')[1]
                          .replaceAll("\n", ""),
                    ),
                  )
                : Container(),
            Container(
              padding: const EdgeInsets.only(top: 15),
              child: ListTile(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: user.googleAuth['googleKey'],
                    ),
                  );
                  snackAlert(context, SnackTypes.success, 'Copied');
                },
                title: Text('${user.googleAuth['googleKey']}'),
                trailing: const Icon(
                  Icons.copy,
                  size: 20,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                getGoogleAuth();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.refresh),
                  Text('Refresh'),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.only(bottom: width * 0.1),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _step = 3;
              });
            },
            child: const Text('NEXT'),
          ),
        ),
      ],
    );
  }

  Widget _stepThree(user) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: width * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: width * 0.1,
                      padding: const EdgeInsets.only(right: 5),
                      child: CircleAvatar(
                        backgroundColor: secondaryTextColor,
                        radius: 10,
                        child: const Text('3'),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.75,
                      child: const Text(
                        'Complete linking',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'The key is used to retrieve the Google Authenticator when the phone is replaced or lost. Be sure to save the above key backup before binding.',
                style: TextStyle(
                  color: orangeBGColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your login password';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      controller: _password,
                      obscureText: true,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter google auth code';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Google authentication code',
                      ),
                      controller: _googleCode,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(bottom: width * 0.1),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  confirmGoogleVeriCode();
                }
              },
              child: const Text('Connect'),
            ),
          ),
        ],
      ),
    );
  }
}
