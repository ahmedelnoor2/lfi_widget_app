import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/screens/market/market.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    Key? key,
    this.scaffoldKey,
    this.updateMarket,
    this.currentMarketSort,
    this.upateCurrentMarketSort,
  }) : super(key: key);
  final scaffoldKey;
  final updateMarket;
  final currentMarketSort;
  final upateCurrentMarketSort;
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var public = Provider.of<Public>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: public.favMarketList.isEmpty
                ? Center(child: noData("No Favourite"))
                : ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    shrinkWrap: true,
                    itemCount: public.favMarketList.length,
                    itemBuilder: (context, index) {
                      var _market =
                          public.favMarketList[index]['marketDetails'];

                      return ListTile(
                        leading: InkWell(
                          onTap: (() async {
                            showDialog(
                              context: context,
                              builder: (c) {
                                return AlertDialog(
                                  backgroundColor: Colors.transparent,
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            if (public.favMarketNameList
                                .contains(_market['symbol'])) {
                              await public.deleteFavMarket(context, {
                                'token': "${auth.loginVerificationToken}",
                                'userId': "${auth.userInfo['id']}",
                                "marketName": _market['symbol'],
                              }).whenComplete(() async {
                                await public.getFavMarketList(context, {
                                  'token': "${auth.loginVerificationToken}",
                                  'userId': "${auth.userInfo['id']}",
                                });
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    settings:
                                        RouteSettings(name: Market.routeName),
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            Market(),
                                    transitionDuration: Duration(seconds: 0),
                                  ),
                                );
                              });
                            }
                          }),
                          child: Icon(
                            Icons.star,
                            size: 20,
                            color: public.favMarketNameList.isNotEmpty
                                ? public.favMarketNameList
                                        .contains(_market['symbol'])
                                    ? linkColor
                                    : secondaryTextColor
                                : secondaryTextColor,
                          ),
                        ),
                        minLeadingWidth: 5,
                        title: InkWell(
                          onTap: () async {
                            await public.setActiveMarket(_market);
                            Navigator.pushNamed(context, '/kline_chart');
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${_market['showName'].split('/')[0]}',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    ' /${_market['showName'].split('/')[1]}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 30,
                                width: 100,
                                padding: const EdgeInsets.only(
                                  top: 5,
                                  bottom: 5,
                                  right: 10,
                                ),
                                child: Text(
                                  'Vol: ${getNumberString(context, double.parse('${public.activeMarketAllTicks[_market['symbol']]['vol']}'))}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: InkWell(
                          onTap: () async {
                            await public.setActiveMarket(_market);
                            Navigator.pushNamed(context, '/kline_chart');
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${public.activeMarketAllTicks[_market['symbol']] != null ? public.activeMarketAllTicks[_market['symbol']]['close'] : '--'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: public.activeMarketAllTicks[
                                              _market['symbol']] !=
                                          null
                                      ? (((double.parse('${public.activeMarketAllTicks[_market['symbol']]['open']}') -
                                                      double.parse(
                                                          '${public.activeMarketAllTicks[_market['symbol']]['close']}')) /
                                                  double.parse(
                                                      '${public.activeMarketAllTicks[_market['symbol']]['open']}')) >
                                              0)
                                          ? greenlightchartColor
                                          : errorColor
                                      : Colors.white,
                                ),
                              ),
                              Text(
                                '${public.activeMarketAllTicks[_market['symbol']] != null ? (double.parse(public.activeMarketAllTicks[_market['symbol']]['rose']) * 100).toStringAsFixed(2) : '--'}%',
                                style: TextStyle(
                                  color: public.activeMarketAllTicks[
                                              _market['symbol']] !=
                                          null
                                      ? double.parse(
                                                  public.activeMarketAllTicks[
                                                              _market['symbol']]
                                                          ['rose'] ??
                                                      '0') >
                                              0
                                          ? greenlightchartColor
                                          : errorColor
                                      : secondaryTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
    ;
  }
}
