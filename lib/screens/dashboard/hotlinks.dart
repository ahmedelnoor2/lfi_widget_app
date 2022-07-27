import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
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

    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              snackAlert(context, SnackTypes.warning, 'Coming Soon...');
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Image.asset(
                    'assets/img/new_listing.png',
                    width: 28,
                  ),
                ),
                Text(
                  'New Listing',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              snackAlert(context, SnackTypes.warning, 'Coming Soon...');
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
                  'Referral',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
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
              if (auth.isAuthenticated) {
                snackAlert(context, SnackTypes.warning, 'Coming Soon...');
                // Navigator.pushNamed(context, '/crypto_loan');
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
                    'assets/img/bot.png',
                    width: 27,
                  ),
                ),
                Text(
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
                  'Swap',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
