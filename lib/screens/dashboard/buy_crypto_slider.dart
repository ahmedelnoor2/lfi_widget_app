import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:webviewx/webviewx.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyCrptoySlider extends StatefulWidget {
  const BuyCrptoySlider({
    Key? key,
    required this.channel,
  }) : super(key: key);
  final channel;

  @override
  State<BuyCrptoySlider> createState() => _BuyCrptoySliderState();
}

class _BuyCrptoySliderState extends State<BuyCrptoySlider> {
  late WebViewXController webviewController;
  int _current = 0;
  final CarouselController _controller = CarouselController();
  final List _sliderFrames = [
    {
      "index": 0,
      "img": 'assets/img/buy_crypto.png',
      "name": "Buy Crypto",
      "title": 'SEPA, VISA, MC',
    },
    {
      "index": 1,
      "img": 'assets/img/deposit.png',
      "name": "Deposit",
      "title": 'BTC, ETH, LYO',
    },
    {
      "index": 2,
      "img": 'assets/img/earn.png',
      "name": "To Earn",
      "title": 'APY up to 72%!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

    return Column(
      children: [
        Card(
          child: Container(
            width: width * 0.40,
            height: height * 0.17,
            decoration: BoxDecoration(),
            child: Column(
              children: [
                CarouselSlider(
                  carouselController: _controller,
                  options: CarouselOptions(
                      height: height * 0.15,
                      viewportFraction: 1,
                      enableInfiniteScroll: true,
                      enlargeCenterPage: false,
                      autoPlay: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }),
                  items: _sliderFrames.map(
                    (slider) {
                      // var slider = _sliderFrames[i];
                      return Builder(
                        builder: (BuildContext context) {
                          return InkWell(
                            onTap: () {
                              if (slider['index'] == 0) {
                                if (auth.isAuthenticated) {
                                  if (auth.userInfo['realAuthType'] == 0 ||
                                      auth.userInfo['authLevel'] == 0) {
                                    snackAlert(context, SnackTypes.warning,
                                        'This feature is not active (Please check KYC status)');
                                  } else {
                                    Navigator.pushNamed(
                                        context, '/buy_sell_crypto');
                                  }
                                } else {
                                  Navigator.pushNamed(
                                      context, '/authentication');
                                }
                              } else if (slider['index'] == 1) {
                                if (auth.isAuthenticated) {
                                  if (auth.userInfo['realAuthType'] == 0 ||
                                      auth.userInfo['authLevel'] == 0) {
                                    snackAlert(context, SnackTypes.warning,
                                        'Deposit limited (Please check KYC status)');
                                  } else {
                                    if (widget.channel != null) {
                                      widget.channel.sink.close();
                                    }
                                    Navigator.pushNamed(
                                        context, '/deposit_assets');
                                  }
                                } else {
                                  Navigator.pushNamed(
                                      context, '/authentication');
                                }
                              } else if (slider['index'] == 2) {
                                Navigator.pushNamed(context, '/staking');
                              }
                            },
                            child: SizedBox(
                              width: width * 0.325,
                              child: Card(
                                elevation: 0.0,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Image.asset(
                                          slider['img'],
                                          width: 24,
                                        ),
                                      ),
                                      FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                          slider['name'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                          slider['title'] ?? '',
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
                          );
                        },
                      );
                    },
                  ).toList(),
                ),
                Container(
                  padding: EdgeInsets.only(left: 22),
                  height: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: _sliderFrames.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => _controller.animateToPage(entry.key),
                        child: Container(
                          width: _current == entry.key ? 20.0 : 10.0,
                          height: _current == entry.key ? 10.0 : 10.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: _current == entry.key
                                  ? Color(0xff01FEF5)
                                  : Color(0xff5E6292)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
