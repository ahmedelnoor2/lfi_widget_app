import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class BuyCrypto extends StatefulWidget {
  const BuyCrypto({
    Key? key,
    required this.channel,
  }) : super(key: key);

  final channel;

  @override
  State<BuyCrypto> createState() => _BuyCryptoState();
}

class _BuyCryptoState extends State<BuyCrypto> {
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            if (auth.isAuthenticated) {
              if (auth.userInfo['realAuthType'] == 0 ||
                  auth.userInfo['authLevel'] == 0) {
                snackAlert(context, SnackTypes.warning,
                    'This feature is not active (Please check KYC status)');
              } else {
                Navigator.pushNamed(context, '/buy_sell_crypto');
              }
            } else {
              Navigator.pushNamed(context, '/authentication');
            }
          },
          child: SizedBox(
            width: width * 0.325,
            height:height* 0.15,
            child: Card(
              child: Container(
                 decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.8, 1),
                    colors: <Color>[
                      Color(0xff3F4374),
                      Color(0xff292C51),
                      
                    ],
                    tileMode: TileMode.mirror,
                  ),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Image.asset(
                        'assets/img/buy_crypto.png',
                        width: 24,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.fitWidth, 
                      child: Text(
                        'Buy Crypto',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    FittedBox(
                       fit: BoxFit.fitWidth, 
                      child: Text(
                        'SEPA, VISA, MC',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          child: SizedBox(
            width: width * 0.325,
            height: height * 0.15,
            child: Card(
              child: Container(
                 decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.8, 1),
                    colors: <Color>[
                      Color(0xff3F4374),
                      Color(0xff292C51),
                      
                    ],
                    tileMode: TileMode.mirror,
                  ),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Image.asset(
                        'assets/img/deposit.png',
                        width: 24,
                      ),
                    ),
                    Text(
                      'Deposit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'BTC, ETH, LYO',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/staking');
          },
          child: SizedBox(
            width: width * 0.32,
            height: height * 0.15,
            child: Card(
              child: Container(
                 decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.8, 1),
                    colors: <Color>[
                      Color(0xff3F4374),
                      Color(0xff292C51),
                      
                    ],
                    tileMode: TileMode.mirror,
                  ),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Image.asset(
                        'assets/img/earn.png',
                        width: 24,
                      ),
                    ),
                    Text(
                      'To Earn',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'APY up to 72%!',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
