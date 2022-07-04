import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:provider/provider.dart';

class Hotlinks extends StatefulWidget {
  const Hotlinks({Key? key}) : super(key: key);

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
            onTap: () {},
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



            },
            child: GestureDetector(
              onTap: (() {
                 Navigator.pushNamed(context, '/referal_screen');
              }),
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
          ),
          GestureDetector(
            onTap: () {
              if (auth.isAuthenticated) {
                if (auth.userInfo['realAuthType'] == 0) {
                  snackAlert(context, SnackTypes.warning,
                      'Deposit limited(Please check KYC status)');
                } else {
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
              //if (auth.isAuthenticated) {
                Navigator.pushNamed(context, '/crypto_loan');
             // } else {
             //   Navigator.pushNamed(context, '/authentication');
            //  }
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Image.asset(
                    'assets/img/bot.png',
                    width: 28,
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
            onTap: () {},
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Image.asset(
                    'assets/img/applications.png',
                    width: 28,
                  ),
                ),
                Text(
                  'More',
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
