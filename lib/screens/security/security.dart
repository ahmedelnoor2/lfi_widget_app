import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Security extends StatefulWidget {
  static const routeName = '/security';
  const Security({Key? key}) : super(key: key);

  @override
  State<Security> createState() => _SecurityState();
}

class _SecurityState extends State<Security> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: true);
    var languageprovider = Provider.of<LanguageChange>(context, listen: true);

    return WillPopScope(
      onWillPop: () {
        return onAndroidBackPress(context);
      },
      child: Scaffold(
        key: _key,
        appBar: appBar(context, null),
        body: SingleChildScrollView(
            child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.password),
              title: Text(languageprovider.getlanguage['security_detail']
                      ['option1'] ??
                  'Password'),
              subtitle: const Text('***********'),
              trailing: TextButton(
                onPressed: () {
                  if (auth.userInfo['googleStatus'] == 0) {
                    showAlert(
                      context,
                      Icon(
                        Icons.warning,
                        color: Colors.amber,
                      ),
                      languageprovider.getlanguage['security_detail']
                              ['security-reminder']['title'] ??
                          'Security Reminder',
                      const <Widget>[
                        Text(
                          'For the security of your account, please open at least one verification method',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Connect Google verification',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          trailing: Icon(
                            Icons.check,
                            size: 15,
                          ),
                        ),
                        Divider(),
                      ],
                      'Ok',
                    );
                  } else {
                    Navigator.pushNamed(context, '/password');
                    // snackAlert(context, SnackTypes.warning, 'Coming Soon...');
                  }
                },
                child: const Text('Change'),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(languageprovider.getlanguage['security_detail']
                      ['option2'] ??
                  'Email'),
              subtitle: const Text(
                'Used when logging in, withdrawing and modifying security settings',
                style: TextStyle(fontSize: 12),
              ),
              trailing: TextButton(
                onPressed: () {
                  if (auth.userInfo['email'].isEmpty &&
                      auth.userInfo['googleStatus'] == 1) {
                    Navigator.pushNamed(context, '/email_change');
                  } else {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return processSupportUrl('email');
                          },
                        );
                      },
                    );
                  }

                  // if (auth.userInfo['mobileNumber'].isEmpty &&
                  //     auth.userInfo['googleStatus'] == 0) {
                  //   showAlert(
                  //     context,
                  //     Icon(
                  //       Icons.warning,
                  //       color: Colors.amber,
                  //     ),
                  //     'Security Reminder',
                  //     const <Widget>[
                  //       Text(
                  //         'For the security of your account, please open at least one verification method',
                  //         style: TextStyle(
                  //           fontSize: 12,
                  //         ),
                  //       ),
                  //       ListTile(
                  //         title: Text(
                  //           'Connect Google verification',
                  //           style: TextStyle(
                  //             fontSize: 12,
                  //           ),
                  //         ),
                  //         trailing: Icon(
                  //           Icons.check,
                  //           size: 15,
                  //         ),
                  //       ),
                  //       Divider(),
                  //       ListTile(
                  //         title: Text(
                  //           'Connect mobile phone verification',
                  //           style: TextStyle(
                  //             fontSize: 12,
                  //           ),
                  //         ),
                  //         trailing: Icon(
                  //           Icons.check,
                  //           size: 15,
                  //         ),
                  //       ),
                  //       Divider(),
                  //     ],
                  //     'Ok',
                  //   );
                  // } else {
                  //   Navigator.pushNamed(context, '/email_change');
                  // }
                },
                child: Text(
                  auth.userInfo['email'].isEmpty ? 'Connect' : 'Change',
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_cell),
              title: Text(languageprovider.getlanguage['security_detail']
                      ['option3'] ??
                  'Phone Number'),
              subtitle: const Text(
                'Receive verification SMS that is used to withdraw, change the password or security settings',
                style: TextStyle(fontSize: 12),
              ),
              trailing: TextButton(
                onPressed: () {
                  // print(auth.userInfo);
                  if (auth.userInfo['mobileNumber'].isNotEmpty) {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return processSupportUrl('phone number');
                          },
                        );
                      },
                    );
                  } else {
                    Navigator.pushNamed(context, '/phone_number');
                  }
                },
                child: Text(
                  auth.userInfo['mobileNumber'].isEmpty ? 'Connect' : 'Change',
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security),
              title: Text(languageprovider.getlanguage['security_detail']
                      ['option4'] ??
                  'Google Authenticator'),
              subtitle: const Text(
                'Receive verification SMS that is used to withdraw, change the password or security settings',
                style: TextStyle(fontSize: 12),
              ),
              trailing: TextButton(
                onPressed: () {
                  print('connect');
                  if (auth.userInfo['googleStatus'] == 0) {
                    Navigator.pushNamed(context, '/google_auth');
                  }
                },
                child: Text(
                  auth.userInfo['googleStatus'] == 0 ? 'Connect' : 'Activated',
                  style: auth.userInfo['googleStatus'] == 1
                      ? TextStyle(color: successColor)
                      : const TextStyle(),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, '/disable_account');
              },
              leading: const Icon(Icons.disabled_by_default),
              title: Text(languageprovider.getlanguage['security_detail']
                      ['title'] ??
                  'Disable my account'),
              subtitle: const Text(
                'Raise a ticket to disable the account',
                style: TextStyle(fontSize: 12),
              ),
              trailing: Icon(Icons.chevron_right),
            ),
            const Divider(),
          ],
        )),
      ),
    );
  }

  void _launchUrl(_url) async {
    final Uri url = Uri.parse(_url);
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

  Widget processSupportUrl(value) {
    height = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(10),
      height: height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
              )
            ],
          ),
          Text(
            'To connect or change your $value you can follow either of these two options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: errorColor,
            ),
          ),
          InkWell(
            onTap: () {
              _launchUrl(
                'https://support.lyotrade.com/',
              );
            },
            child: Container(
              padding: EdgeInsets.only(bottom: 20),
              child: Card(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.confirmation_num,
                                size: 30,
                              ),
                            ),
                            Text(
                              'Create support ticket',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Raise a ticket in order to add your $value',
                        style: TextStyle(fontSize: 16, color: warningColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
