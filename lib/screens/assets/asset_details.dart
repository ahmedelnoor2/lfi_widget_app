import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';

class AssetDetails extends StatefulWidget {
  static const routeName = '/asset_details';
  const AssetDetails({Key? key}) : super(key: key);

  @override
  State<AssetDetails> createState() => _AssetDetailsState();
}

class _AssetDetailsState extends State<AssetDetails> {
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);
    var public = Provider.of<Public>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);
    int _currentIndex = 0;

    List cardList = [
      Item1(),
      Item1(),
      Item1(),
    ];

    List<T> map<T>(List list, Function handler) {
      List<T> result = [];
      for (var i = 0; i < list.length; i++) {
        result.add(handler(i, list[i]));
      }
      return result;
    }

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Container(
        padding: EdgeInsets.only(
          right: 15,
          left: 15,
          bottom: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                bottom: 10,
              ),
              child: Row(
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
                        '${public.publicInfoMarket['market']['coinList'][asset.selectedAsset['coin']]['longName']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: Container(
                width: width,
                padding: EdgeInsets.only(
                  bottom: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            'Balance',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Total',
                            style: TextStyle(
                                fontSize: 16, color: secondaryTextColor),
                          ),
                        ),
                        Text(
                          double.parse(
                                  '${asset.selectedAsset['values']['total_balance']}')
                              .toStringAsFixed(5),
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            '≈ ${getNumberFormat(
                              context,
                              public.rate[public.activeCurrency['fiat_symbol']
                                          .toUpperCase()][asset.accountBalance[
                                              asset.selectedAsset['coin']] ??
                                          'BTC'] !=
                                      null
                                  ? double.parse(asset.selectedAsset['values']['total_balance'] ?? '0') *
                                      public.rate[public
                                              .activeCurrency['fiat_symbol']
                                              .toUpperCase()]
                                          [asset.selectedAsset['coin']]
                                  : 0,
                            )}',
                            style: TextStyle(
                                fontSize: 16, color: secondaryTextColor),
                          ),
                        ),
                        Divider(),
                        Container(
                          padding: EdgeInsets.only(top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Available',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    double.parse(
                                            '${asset.selectedAsset['values']['normal_balance']}')
                                        .toStringAsFixed(5),
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Unavailalbe',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    double.parse(
                                            '${asset.selectedAsset['values']['lock_balance']}')
                                        .toStringAsFixed(5),
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Spot Trade'),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 140.0,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            pauseAutoPlayOnTouch: true,
                            aspectRatio: 2.0,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                          ),
                          items: cardList.map((card) {
                            return Builder(builder: (BuildContext context) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.20,
                                width: MediaQuery.of(context).size.width,
                                child: Card(
                                  color: Colors.blueAccent,
                                  child: card,
                                ),
                              );
                            });
                          }).toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: map<Widget>(cardList, (index, url) {
                            return Container(
                              width: 10.0,
                              height: 10.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentIndex == index
                                    ? Colors.blueAccent
                                    : Colors.grey,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(right: 5),
                              child: LyoButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/withdraw_assets',
                                  );
                                },
                                text: 'Withdraw',
                                active: true,
                                isLoading: false,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 5),
                              child: LyoButton(
                                onPressed: () {
                                  if (auth.userInfo['realAuthType'] == 0 ||
                                      auth.userInfo['authLevel'] == 0) {
                                    snackAlert(context, SnackTypes.warning,
                                        'Deposit limited (Please check KYC status)');
                                  } else {
                                    Navigator.pushNamed(
                                        context, '/deposit_assets');
                                  }
                                },
                                text: 'Deposit',
                                active: true,
                                activeColor: linkColor,
                                activeTextColor: Colors.black,
                                isLoading: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Item1 extends StatelessWidget {
  const Item1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [
              0.3,
              1
            ],
            colors: [
              Color(0xffff4000),
              Color(0xffffcc66),
            ]),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Data",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold)),
          Text("Data",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
