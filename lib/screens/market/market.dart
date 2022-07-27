import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/market/marketpage.dart';
import 'package:lyotrade/screens/trade/kline_chart.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

class Market extends StatefulWidget {
  static const routeName = '/market';
  const Market({Key? key}) : super(key: key);

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return onAndroidBackPress(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 20),
                        ),
                        Text(
                          'Market',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      'assets/img/marketgraph.png',
                    ),
                    Image.asset('assets/img/marketgraph.png'),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ButtonsTabBar(
                          backgroundColor: selecteditembordercolour,
                          unselectedBackgroundColor: Colors.grey[300],
                          unselectedLabelStyle: TextStyle(color: Colors.black),
                          labelStyle: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          tabs: [
                            Tab(
                              height: 30,
                              text: "Favorites",
                            ),
                            Tab(
                              height: 30,
                              text: "Exchange",
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: <Widget>[
                              MarketPage(),
                              Center(
                                child: Icon(Icons.directions_transit),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
