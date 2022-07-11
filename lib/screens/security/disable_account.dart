import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:url_launcher/url_launcher.dart';

class DisableAccount extends StatefulWidget {
  static const routeName = '/disable_account';
  const DisableAccount({Key? key}) : super(key: key);

  @override
  State<DisableAccount> createState() => _DisableAccountState();
}

class _DisableAccountState extends State<DisableAccount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _launchUrl(_url) async {
    final Uri url = Uri.parse(_url);
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hiddenAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 20),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.chevron_left),
                          ),
                        ),
                        // Text(
                        //   'Disable Account',
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'Disable Account',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    'Our Security and compliance team will review your request and disable your account.',
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          '1. All Trading capacities and login for your account will be disabled',
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          '2. All API keys for your account will be deleted',
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          '3. All devices for your account will be deleted',
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          '4. All pending withdrawals will be canceled',
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          '5. All open orders will be canceled',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: LyoButton(
              text: 'Disable Account',
              active: true,
              isLoading: false,
              activeColor: linkColor,
              activeTextColor: Colors.black,
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return processDisableAcocunt();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget processDisableAcocunt() {
    height = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(10),
      // height: height * 0.5,
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
            'To disable your account you can follow either of these two options',
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
                        'Raise a ticket attaching a valid Passport or National ID Card along with a real-time selfie picture holding the ID document',
                        style: TextStyle(fontSize: 16, color: warningColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              if (kIsWeb) {
                Clipboard.setData(
                  ClipboardData(
                    text: 'support@lyotrade.com',
                  ),
                );
                Navigator.pop(context);
                snackAlert(context, SnackTypes.success,
                    'Support email address copied');
              } else {
                _launchUrl(
                  'mailto:support@lyotrade.com?subject=Disable My Account Request',
                );
              }
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
                                Icons.email,
                                size: 30,
                              ),
                            ),
                            Text(
                              'Send an email',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Send an email to support@lyotrade.com attaching a valid Passport or National ID Card along with a real-time selfie picture holding the ID document.',
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
