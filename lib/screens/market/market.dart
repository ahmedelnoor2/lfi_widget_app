import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';

import 'package:lyotrade/screens/market/pages/favourite_page.dart';
import 'package:lyotrade/screens/trade/kline_chart.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Coins.utils.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class Market extends StatefulWidget {
  static const routeName = '/market';
  const Market({Key? key}) : super(key: key);

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  final _klineView = true;

  @override
  void initState() {
    getrecommendedsymbol();

    super.initState();
  }

  Future<void> getrecommendedsymbol() async {
    var public = Provider.of<Public>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    await public.getrecomendedsybol(auth);
  }

  @override
  Widget build(BuildContext context) {
    var _currentRoute = ModalRoute.of(context)!.settings.name;

    var public = Provider.of<Public>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

    ///print(public.getrecomendedsybol());
    return WillPopScope(
      onWillPop: () {
        return onAndroidBackPress(context);
      },
      child: Scaffold(
        appBar: hiddenAppBar(),
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
                public.isrecommended
                    ? CircularProgressIndicator()
                    : SizedBox(
                        height: height * 0.2,
                        child: ListView.builder(
                            itemCount: public.marketrecoomendsymbol.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              var marketSymbol = public
                                  .marketrecoomendsymbol[index]
                                  .replaceAll('/', '')
                                  .toLowerCase();
                              var data =
                                  public.activeMarketAllTicks[marketSymbol];
                              //  print(data);
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: cardcolor,
                                ),
                                height: height * 0.2,
                                width: width * 0.60,
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Image.network(
                                            '${public.publicInfoMarket['market']['coinList']['${public.marketrecoomendsymbol[index].split('/')[0]}']['icon']}',
                                            width: 25,
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Text(
                                              '${getMarketName(public.marketrecoomendsymbol[index])}',
                                              // public.activeMarginMarket[public.marketrecoomendsymbol.replaceAll('/', '')],
                                              style: TextStyle(),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: width * 0.15),
                                            child: Text(
                                              '${(double.parse(data['rose']) * 100).toStringAsFixed(4)} %',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.only(top: height * 0.020),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Text(
                                              '${data['close'].toString()}',
                                              style: TextStyle(),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: width * 0.03),
                                            child: Text(
                                              "\$1.8",
                                              style: TextStyle(
                                                  color: darkgreyColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.only(top: height * 0.030),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(left: 6),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                ' ${double.parse('${data['vol']}').toStringAsFixed(4)}',
                                                style: TextStyle(),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: width * 0.01),
                                            child: Text(
                                              "\$1.8",
                                              style: TextStyle(
                                                  color: darkgreyColor),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: width * 0.20),
                                            alignment: Alignment.center,
                                            height: 22,
                                            width: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: darkgreyColor,
                                            ),
                                            child: Icon(Icons.navigate_next,
                                                color: Colors.white, size: 22),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ButtonsTabBar(
                            height: 40,

                            //  backgroundColor: buttoncolour,
                            unselectedBackgroundColor: greyDarkHeaderTextColor,
                            unselectedLabelStyle:
                                TextStyle(color: Colors.black),

                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            tabs: [
                              Tab(
                                icon: Icon(
                                  Icons.star,
                                  size: 15,
                                ),
                                height: 30,
                                text: "Favorites ",
                              ),
                              Tab(
                                height: 30,
                                text: " Exchange ",
                              ),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: <Widget>[
                                Favoritespage(),
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
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
            _currentRoute == '/market' ? bottomNav(context, auth) : null,
      ),
    );
  }
}
