import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:provider/provider.dart';

class Hotlinks extends StatefulWidget {
  const Hotlinks({
    Key? key,
    required this.channel,
  }) : super(key: key);

  final channel;

  @override
  State<Hotlinks> createState() => _HotlinksState();
}

class _HotlinksState extends State<Hotlinks> {
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: true);
    var languageprovider = Provider.of<LanguageChange>(context, listen: true);

    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (auth.isAuthenticated) {
                if (auth.userInfo['realAuthType'] == 0 ||
                    auth.userInfo['authLevel'] == 0) {
                  snackAlert(context, SnackTypes.warning,
                      'Deposit limited (Please check KYC status)');
                } else {
                  if (widget.channel != null) {
                    widget.channel.sink.close();
                  }
                  Navigator.pushNamed(context, '/deposit_assets');
                }
              } else {
                Navigator.pushNamed(context, '/authentication');
              }
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Image.asset(
                    'assets/img/deposit_pig.png',
                    width: 28,
                  ),
                ),
                Text(
                  languageprovider.getlanguage['home']['menu_item3'] ??
                      'Deposit',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/crypto_loan');
              // if (auth.isAuthenticated) {
              //   //  snackAlert(context, SnackTypes.warning, 'Coming Soon...');
              //   Navigator.pushNamed(context, '/crypto_loan');
              // } else {
              //   Navigator.pushNamed(context, '/authentication');
              // }
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Image.asset(
                    'assets/img/bot.png',
                    width: 27,
                  ),
                ),
                Text(
                  languageprovider.getlanguage['home']['menu_item4'] ??
                      'Crypto Loan',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (auth.isAuthenticated) {
                if (auth.userInfo['realAuthType'] == 0 ||
                    auth.userInfo['authLevel'] == 0) {
                  snackAlert(context, SnackTypes.warning,
                      'Deposit limited (Please check KYC status)');
                } else {
                  if (widget.channel != null) {
                    widget.channel.sink.close();
                  }
                  Navigator.pushNamed(context, '/dex_swap');
                }
              } else {
                Navigator.pushNamed(context, '/authentication');
              }
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Image.asset(
                    'assets/img/swap.png',
                    width: 27,
                  ),
                ),
                Text(
                  languageprovider.getlanguage['home']['menu_item5'] ?? 'Swap',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              snackAlert(context, SnackTypes.warning, 'Coming Soon ....');
              // if (auth.isAuthenticated) {
              //   Navigator.pushNamed(context, '/topup');
              // } else {
              //   Navigator.pushNamed(context, '/authentication');
              // }
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Image.asset(
                    'assets/img/top-up.png',
                    width: 28,
                  ),
                ),
                Text(
                  //  languageprovider.getlanguage['home']['menu_item1']?? 'New Listing',
                  'Mobile Topup',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (auth.isAuthenticated) {
                Navigator.pushNamed(context, '/referal_screen');
              } else {
                Navigator.pushNamed(context, '/authentication');
              }
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Image.asset(
                    'assets/img/refer.png',
                    width: 28,
                  ),
                ),
                Text(
                  languageprovider.getlanguage['home']['menu_item2'] ??
                      'Referral',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
