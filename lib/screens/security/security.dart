import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

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

    return Scaffold(
      key: _key,
      appBar: appBar(context, null),
      body: SingleChildScrollView(
          child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Password'),
            subtitle: const Text('***********'),
            trailing: TextButton(
              onPressed: () {
                if (auth.userInfo['mobileNumber'].isEmpty &&
                    auth.userInfo['googleStatus'] == 0) {
                  showAlert(
                    context,
                    Icon(
                      Icons.warning,
                      color: Colors.amber,
                    ),
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
                      ListTile(
                        title: Text(
                          'Connect mobile phone verification',
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
                  // Navigator.pushNamed(context, '/password');
                  snackAlert(context, SnackTypes.warning, 'Coming Soon...');
                }
              },
              child: const Text('Change'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: const Text(
              'Used when logging in, withdrawing and modifying security settings',
              style: TextStyle(fontSize: 12),
            ),
            trailing: TextButton(
              onPressed: () {
                if (auth.userInfo['mobileNumber'].isEmpty &&
                    auth.userInfo['googleStatus'] == 0) {
                  showAlert(
                    context,
                    Icon(
                      Icons.warning,
                      color: Colors.amber,
                    ),
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
                      ListTile(
                        title: Text(
                          'Connect mobile phone verification',
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
                  Navigator.pushNamed(context, '/email_change');
                }
              },
              child: const Text('Change'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_cell),
            title: const Text('Phone Number'),
            subtitle: const Text(
              'Receive verification SMS that is used to withdraw, change the password or security settings',
              style: TextStyle(fontSize: 12),
            ),
            trailing: TextButton(
              onPressed: () {
                if (auth.userInfo['mobileNumber'].isEmpty) {
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
            title: const Text('Google Authenticator'),
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
        ],
      )),
    );
  }
}
