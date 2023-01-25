import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/screens/dashboard/buy_crypto_slider.dart';
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
        SizedBox(
            width: width * 0.325,
            child: BuyCrptoySlider(
              channel: widget.channel,
            )),
        InkWell(
          onTap: () {
            if (auth.isAuthenticated) {
              if (auth.userInfo['realAuthType'] == 0 ||
                  auth.userInfo['authLevel'] == 0) {
                snackAlert(
                    context, SnackTypes.warning, 'Please check KYC status');
              } else {
                Navigator.pushNamed(context, '/trade_challenge');
              }
            } else {
              Navigator.pushNamed(context, '/authentication');
            }
          },
          child: SizedBox(
            width: width * 0.64,
            height: height * 0.18,
            child: Card(
              child: Container(
                decoration: BoxDecoration(
                  // color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage("assets/img/tradebg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '10 TRADE',
                        style: TextStyle(
                            color: linkColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                      ),
                      Text('CHALLENGE',
                          style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400)),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text('WIN FREE',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400)),
                              Text('USDT',
                                  style: TextStyle(
                                      color: icongreen,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700))
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15),
                            width: 45,
                            child: Image.asset('assets/img/usdt.png'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
