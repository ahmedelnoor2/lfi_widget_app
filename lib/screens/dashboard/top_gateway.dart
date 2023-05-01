import 'package:flutter/material.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class TopGateway extends StatefulWidget {
  const TopGateway({Key? key}) : super(key: key);

  @override
  State<TopGateway> createState() => _TopGatewayState();
}

class _TopGatewayState extends State<TopGateway>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  Future<void> getAllGiftProvider() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    await giftcardprovider.getAllGiftProvider();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: true);
    var payments = Provider.of<Payments>(context, listen: true);
    var languageprovider = Provider.of<LanguageChange>(context, listen: true);
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);

    // print(auth.userInfo);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: () {
              if (auth.isAuthenticated) {
                if (auth.userInfo['realAuthType'] == 0 ||
                    auth.userInfo['authLevel'] == 0) {
                  snackAlert(context, SnackTypes.warning,
                      'Deposit limited (Please check KYC status)');
                } else {
                  payments.clearKycTransactions();
                  Navigator.pushNamed(context, '/pix_payment');
                }
              } else {
                Navigator.pushNamed(context, '/authentication');
              }
            },
            child: Container(
              padding: EdgeInsets.all(5),
              child: Container(
                // width: width * 0.52,
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
                padding: EdgeInsets.only(right: 4, left: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languageprovider.getlanguage['home']
                                        ['deposit_title'] ??
                                    'Deposit BRL',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                width: 100,
                                child: Text(
                                  languageprovider.getlanguage['home']
                                          ['deposit_text'] ??
                                      'Bank Transfer',
                                  softWrap: false,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      // width: width * 0.20,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 5),
                            width: 60,
                            height: 60,
                            child: Stack(
                              children: [
                                const Align(
                                  alignment: Alignment.topCenter,
                                  child: Icon(
                                    Icons.redo,
                                    size: 18,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/img/usdt.png',
                                      width: 30,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/img/brl.png',
                                      width: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: () async {
              if (auth.isAuthenticated) {
                await getAllGiftProvider();
                print(giftcardprovider.allgiftprovider.length);
                if (auth.userInfo['realAuthType'] == 0 ||
                    auth.userInfo['authLevel'] == 0) {
                  snackAlert(context, SnackTypes.warning,
                      ' (Please check KYC status)');
                } else {
                  if (giftcardprovider.allgiftprovider.length > 1) {
                    Navigator.pushNamed(context, '/gift_card_service_provider');
                  } else {
                    String reloadlyid = '2';
                    giftcardprovider.setproviderid(reloadlyid);
                    Navigator.pushNamed(context, '/gift_card');
                  }
                }
              } else {
                Navigator.pushNamed(context, '/authentication');
              }
            },
            child: Container(
              padding: EdgeInsets.all(5),
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
                padding: EdgeInsets.only(left: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gift Card',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 5),
                            width: 55,
                            height: 60,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/img/gifCard.png',
                                      width: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
    ////test//
  }
}
