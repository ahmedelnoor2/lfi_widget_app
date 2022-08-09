import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';

import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class Kycscreen extends StatefulWidget {
  static const routeName = '/kyc_screen';
  @override
  State<StatefulWidget> createState() => _KycscreenState();
}

class _KycscreenState extends State<Kycscreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    checkUserSession();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> checkUserSession() async {
    var auth = Provider.of<Auth>(context, listen: false);

    var checkAuth = await auth.checkLoginSession(context);
    if (!checkAuth) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);

    var _isVerified =
        (auth.userInfo['realAuthType'] == 0 || auth.userInfo['authLevel'] == 0)
            ? false
            : true;

    return Scaffold(
        appBar: hiddenAppBar(),
        body: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 20),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.chevron_left),
                    ),
                  ),
                  Text(
                    'Kyc',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(),
          Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Card(
                  child: ListTile(
                    leading: Image.asset(
                      'assets/img/personal_verfication.png',
                      height: width * 0.1,
                    ),
                    title: Text('Personal Verification'),
                    subtitle: Text(
                      auth.userInfo['sumsubLevelName'].isEmpty
                          ? 'Complete your KYC'
                          : 'Your verification level: ${auth.userInfo['sumsubLevelName']}',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/personalverification');
                    },
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          _isVerified ? Icons.how_to_reg : Icons.person,
                          color: _isVerified ? successColor : warningColor,
                        ),
                        Text(
                          _isVerified ? 'Verified' : 'Unverified',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isVerified ? successColor : warningColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Image.asset(
                      'assets/img/entitiy_verfication.png',
                      height: width * 0.1,
                    ),
                    title: Text('Entity Verification'),
                    subtitle: Text(
                      'Complete your KYC',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      snackAlert(context, SnackTypes.warning, 'Coming soon...');
                      // Navigator.pushNamed(context, '/entityverification');
                    },
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.assured_workload,
                          color: secondaryTextColor,
                        ),
                        Text(
                          'Unverified',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ]));
  }
}
