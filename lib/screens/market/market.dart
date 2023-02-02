import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lyotrade/screens/market/pages/exchange.dart';
import 'package:lyotrade/screens/market/pages/favourite.dart';
import 'package:lyotrade/screens/trade/kline_chart.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Coins.utils.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

import '../../utils/Number.utils.dart';

class Market extends StatefulWidget {
  static const routeName = '/market';
  const Market({Key? key}) : super(key: key);

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  final TextEditingController _searchController = TextEditingController();
  final _klineView = true;
  String _currentMarketSort = 'USDT';

  @override
  void initState() {
    getrecommendedsymbol();
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    _searchController.dispose();
  }

  void updateMarketSort(value) {
    setState(() {
      _currentMarketSort = value;
    });
  }

  Future<void> getrecommendedsymbol() async {
    var public = Provider.of<Public>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    await public.getrecomendedsybol(auth);
  }

  var tabindex = 0;
  @override
  Widget build(BuildContext context) {
    var _currentRoute = ModalRoute.of(context)!.settings.name;

    var public = Provider.of<Public>(context, listen: true);
    var languageprovider = Provider.of<LanguageChange>(context, listen: true);
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
                      languageprovider.getlanguage['markets']['title']??'Market',
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
                              var rose = '0.00';
                              if (data != null) {
                                rose = '${data['rose'] ?? '0.00'}';
                              }
                              var close = '0.00';
                              if (data != null) {
                                close = '${data['close'] ?? '0.00'}';
                              }
                              var vol = '0.00';
                              if (data != null) {
                                vol = '${data['vol'] ?? '0.00'}';
                              }
                              //  print(data);
                              return InkWell(
                                onTap: () async {
                                  // await public.setActiveMarket(_market);
                                  // Navigator.pushNamed(context, '/kline_chart');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: cardcolor,
                                  ),
                                  width: 178,
                                  margin: EdgeInsets.all(5),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                kIsWeb
                                                    ? Container()
                                                    : Stack(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10),
                                                            child:
                                                                Image.network(
                                                              '${public.publicInfoMarket['market']['coinList']['${public.marketrecoomendsymbol[index].split('/')[1]}']['icon']}',
                                                              width: 16,
                                                            ),
                                                          ),
                                                          Image.network(
                                                            '${public.publicInfoMarket['market']['coinList']['${public.marketrecoomendsymbol[index].split('/')[0]}']['icon']}',
                                                            width: 16,
                                                          ),
                                                        ],
                                                      ),
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(left: 5),
                                                  child: Text(
                                                    '${getMarketName(public.marketrecoomendsymbol[index])}',
                                                    // public.activeMarginMarket[public.marketrecoomendsymbol.replaceAll('/', '')],
                                                    style: TextStyle(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              public.activeMarketAllTicks
                                                      .isNotEmpty
                                                  ? '${double.parse(rose) > 0 ? '+' : ''}${(double.parse(rose) * 100).toStringAsFixed(2)} %'
                                                  : '--%',
                                              style: TextStyle(
                                                color: public
                                                        .activeMarketAllTicks
                                                        .isEmpty
                                                    ? secondaryTextColor
                                                    : double.parse(rose) > 0
                                                        ? greenIndicator
                                                        : redIndicator,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: LineChart(mainData()),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 10, bottom: 5),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  public.activeMarketAllTicks
                                                          .isNotEmpty
                                                      ? '${close.toString()}'
                                                      : '--',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: public
                                                            .activeMarketAllTicks
                                                            .isEmpty
                                                        ? secondaryTextColor
                                                        : double.parse(rose) > 0
                                                            ? greenIndicator
                                                            : redIndicator,
                                                  ),
                                                ),
                                                Text(
                                                  "≈ ${getNumberFormat(context, public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()]['${public.marketrecoomendsymbol[index].split('/')[0]}'])}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10, bottom: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  child: Text(
                                                    '24H Vol: ${public.activeMarketAllTicks.isNotEmpty ? getNumberString(context, double.parse('${vol}')) : '--'}',
                                                    style: TextStyle(
                                                      color: secondaryTextColor,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: 20,
                                                  width: 20,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        secondaryTextColor400,
                                                  ),
                                                  child: Icon(
                                                    Icons.navigate_next,
                                                    color: Colors.black,
                                                    size: 20,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ButtonsTabBar(
                                onTap: ((p0) {
                                  setState(() {
                                    tabindex = p0;
                                  });
                                }),
                                height: height * 0.043,
                                radius: 2,
                                contentPadding:
                                    EdgeInsets.only(left: 10, right: 10),
                                backgroundColor: linkColor,
                                splashColor: linkColor,
                                unselectedBackgroundColor: Colors.transparent,
                                unselectedLabelStyle:
                                    TextStyle(color: secondaryTextColor),
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                tabs: [
                                  Tab(
                                    text:languageprovider.getlanguage['markets']['exchange_btn']?? 'Exchange',
                                  ),
                                  Tab(
                                    icon: Icon(
                                      Icons.star,
                                      size: 12,
                                    ),
                                    text:languageprovider.getlanguage['markets']['fav_btn']['title']??"Favourites",
                                  ),
                                ],
                              ),
                              tabindex == 1
                                  ? Container()
                                  : Container(
                                      margin: EdgeInsets.only(right: 2),
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            style: BorderStyle.solid,
                                            width: 0.3,
                                            color: Color(0xff5E6292),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.only(right: 8),
                                              child: Icon(
                                                Icons.search,
                                                size: 14,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * 0.37,
                                              child: TextField(
                                                onChanged: (value) async {
                                                  // await asset.filterSearchResults(value);
                                                  await public
                                                      .filterMarketSearchResults(
                                                    value,
                                                    public.allMarkets[
                                                        _currentMarketSort],
                                                    _currentMarketSort,
                                                  );
                                                },
                                                controller: _searchController,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  isDense: true,
                                                  border: UnderlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  hintStyle: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  hintText:languageprovider.getlanguage['markets']['search_placeholder']?? "Search",
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: <Widget>[
                                ExchangeScreen(
                                    currentMarketSort: _currentMarketSort,
                                    upateCurrentMarketSort: updateMarketSort),
                                FavoritesScreen(
                                    currentMarketSort: _currentMarketSort,
                                    upateCurrentMarketSort: updateMarketSort),
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

  LineChartData mainData() {
    var public = Provider.of<Public>(context, listen: false);

    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
      ),
      titlesData: FlTitlesData(
        show: false,
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          color: Color.fromARGB(155, 155, 144, 255),
          spots: [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          barWidth: 1,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            gradient: LinearGradient(
              // stops: [0,0.5],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [marketcharcolor1, cardcolor],
            ),
            show: true,
          ),
        ),
      ],
    );
  }
}
