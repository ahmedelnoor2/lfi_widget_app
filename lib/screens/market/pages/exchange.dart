import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Translate.utils.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({
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
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  var _channel;

  @override
  void initState() {
    connectWebSocket();

    super.initState();
    getFavouriteMarket();
  }

  @override
  void dispose() async {
    if (_channel != null) {
      _channel.sink.close();
    }
    super.dispose();
  }

  Future<void> connectWebSocket() async {
    var public = Provider.of<Public>(context, listen: false);

    _tabController = TabController(
      length: public.publicInfoMarket['market']['marketSort'].length,
      vsync: this,
    );

    _channel = WebSocketChannel.connect(
      Uri.parse('${public.publicInfoMarket["market"]["wsUrl"]}'),
    );

    for (int j = 0;
        j < public.publicInfoMarket['market']['marketSort'].length;
        j++) {
      String cMarketSort = public.publicInfoMarket['market']['marketSort'][j];
      for (int i = 0; i < public.allMarkets[cMarketSort].length; i++) {
        _channel.sink.add(jsonEncode({
          "event": "sub",
          "params": {
            "channel":
                "market_${public.allMarkets[cMarketSort][i]['symbol']}_ticker",
            "cb_id": public.allMarkets[cMarketSort][i]['symbol'],
          }
        }));
      }
    }

    _channel.stream.listen((message) {
      extractStreamData(message, public);
    });
  }

  void extractStreamData(streamData, public) async {
    if (streamData != null) {
      // var inflated = zlib.decode(streamData as List<int>);
      var inflated =
          GZipDecoder().decodeBytes(streamData as List<int>, verify: false);
      var data = utf8.decode(inflated);
      if (json.decode(data)['channel'] != null) {
        var marketData = json.decode(data);
        public.setActiveMarketAllTicks(
          marketData['tick'],
          marketData['channel'],
        );
      }
    }
  }

  // Future<void> insertFavouriteMarket() async {
  //   var public = Provider.of<Public>(context, listen: false);
  //   var auth = Provider.of<Auth>(context, listen: false);

  //   await public.insertFavMarketList(context, {
  //     'token': "${auth.loginVerificationToken}",
  //     'userId': "${auth.userInfo['id']}",
  //     "marketName": "USDT5",
  //     "marketDetails": {}
  //   });
  // }

  Future<void> getFavouriteMarket() async {
    var public = Provider.of<Public>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);

    await public.getFavMarketList(context, {
      'token': "${auth.loginVerificationToken}",
      'userId': "${auth.userInfo['id']}",
    });
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
          _tabController != null
              ? Container(
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.label,
                      isScrollable: true,
                      onTap: (value) {
                        widget.upateCurrentMarketSort(public
                            .publicInfoMarket['market']['marketSort'][value]);
                      },
                      controller: _tabController,
                      tabs: public.publicInfoMarket['market']['marketSort']
                          .map<Widget>(
                            (mname) => Tab(text: '$mname'),
                          )
                          .toList(),
                    ),
                  ),
                )
              : Container(),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider();
              },
              shrinkWrap: true,
              itemCount:
                  public.allSearchMarket[widget.currentMarketSort].isNotEmpty
                      ? public.allSearchMarket[widget.currentMarketSort].length
                      : public.allMarkets[widget.currentMarketSort].length,
              itemBuilder: (context, index) {
                var _market = public
                        .allSearchMarket[widget.currentMarketSort].isNotEmpty
                    ? public.allSearchMarket[widget.currentMarketSort][index]
                    : public.allMarkets[widget.currentMarketSort][index];

                return ListTile(
                  leading: InkWell(
                    onTap: (() async {
                      if (auth.isAuthenticated) {
                        if (public.favMarketNameList
                            .contains(_market['symbol'])) {
                          await public.deleteFavMarket(context, {
                            'token': "${auth.loginVerificationToken}",
                            'userId': "${auth.userInfo['id']}",
                            "marketName": "${_market['symbol']}",
                          }).whenComplete(() async {
                            await public.getFavMarketList(context, {
                              'token': "${auth.loginVerificationToken}",
                              'userId': "${auth.userInfo['id']}",
                            });
                          });
                        } else {
                          await public.createFavMarket(context, {
                            'token': "${auth.loginVerificationToken}",
                            'userId': "${auth.userInfo['id']}",
                            "marketName": "${_market['symbol']}",
                            "marketDetails": _market
                          }).whenComplete(() async => {
                                await public.getFavMarketList(context, {
                                  'token': "${auth.loginVerificationToken}",
                                  'userId': "${auth.userInfo['id']}",
                                })
                              });
                        }
                      } else {
                        Navigator.pushNamed(context, '/authentication');
                      }
                    }),
                    child: Icon(
                      Icons.star,
                      size: 20,
                      color: public.favMarketNameList.isNotEmpty
                          ? public.favMarketNameList.contains(_market['symbol'])
                              ? linkColor
                              : secondaryTextColor
                          : secondaryTextColor,
                    ),
                  ),
                  minLeadingWidth: 5,
                  title: Column(
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
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              await public.setActiveMarket(_market);
                              Navigator.pushNamed(context, '/trade');
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                top: 5,
                                bottom: 5,
                                right: 10,
                              ),
                              child: Text(
                                'Trade',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: linkColor,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              await public.setActiveMarket(_market);
                              Navigator.pushNamed(context, '/kline_chart');
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                top: 5,
                                bottom: 5,
                                left: 10,
                                right: 10,
                              ),
                              child: Text(
                                'Info',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: linkColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  trailing: Column(
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
                          color:
                              public.activeMarketAllTicks[_market['symbol']] !=
                                      null
                                  ? double.parse(public.activeMarketAllTicks[
                                                  _market['symbol']]['rose'] ??
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
