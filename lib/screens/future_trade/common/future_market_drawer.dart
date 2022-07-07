import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/future_market.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FutureMarketDrawer extends StatefulWidget {
  const FutureMarketDrawer({
    Key? key,
    this.scaffoldKey,
    this.updateMarket,
  }) : super(key: key);

  final scaffoldKey;
  final updateMarket;

  @override
  State<FutureMarketDrawer> createState() => _FutureMarketDrawerState();
}

class _FutureMarketDrawerState extends State<FutureMarketDrawer>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  var _channel;
  String _currentMarketSort = 'USDT';

  @override
  void initState() {
    connectWebSocket();
    super.initState();
  }

  @override
  void dispose() async {
    if (_channel != null) {
      _channel.sink.close();
    }
    super.dispose();
  }

  Future<void> connectWebSocket() async {
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);

    _tabController = TabController(
      length: futureMarket.publicInfoMarket['marginCoinList'].length,
      vsync: this,
    );

    _channel = WebSocketChannel.connect(
      Uri.parse('${futureMarket.publicInfoMarket["wsUrl"]}'),
    );

    for (int j = 0;
        j < futureMarket.publicInfoMarket['marginCoinList'].length;
        j++) {
      String cMarketSort = futureMarket.publicInfoMarket['marginCoinList'][j];
      if (futureMarket.allMarkets[cMarketSort].isNotEmpty) {
        for (int i = 0; i < futureMarket.allMarkets[cMarketSort].length; i++) {
          var market = futureMarket.allMarkets[cMarketSort][i];
          _channel.sink.add(jsonEncode({
            "event": "sub",
            "params": {
              "channel": ""
                  "market_e_${market['contractOtherName'].toLowerCase()}_ticker",
              "cb_id": "e_${market['contractOtherName'].toLowerCase()}",
            }
          }));
        }
      }
    }

    _channel.stream.listen((message) {
      extractStreamData(message, futureMarket);
    });
  }

  void extractStreamData(streamData, futureMarket) async {
    if (streamData != null) {
      // var inflated = zlib.decode(streamData as List<int>);
      var inflated =
          GZipDecoder().decodeBytes(streamData as List<int>, verify: false);
      var data = utf8.decode(inflated);
      if (json.decode(data)['channel'] != null) {
        var marketData = json.decode(data);
        // print(marketData);
        futureMarket.setActiveMarketAllTicks(
          marketData['tick'],
          marketData['channel'],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var futureMarket = Provider.of<FutureMarket>(context, listen: true);

    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: const Text(
                    'Markets',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: SizedBox(
              height: width * 0.13,
              child: TextField(
                onChanged: (value) async {
                  await futureMarket.filterMarketSearchResults(
                    value,
                    futureMarket.allMarkets,
                    _currentMarketSort,
                  );
                },
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: TabBar(
              onTap: (value) {
                setState(() {
                  _currentMarketSort =
                      futureMarket.publicInfoMarket['marginCoinList'][value];
                });
              },
              controller: _tabController,
              tabs: futureMarket.publicInfoMarket['marginCoinList']
                  .map<Widget>(
                    (mname) => Tab(text: '$mname'),
                  )
                  .toList(),
            ),
          ),
          SizedBox(
            height: height * 0.794,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount:
                  futureMarket.allSearchMarket[_currentMarketSort].isNotEmpty
                      ? futureMarket.allSearchMarket[_currentMarketSort].length
                      : futureMarket.allMarkets[_currentMarketSort].length,
              itemBuilder: (context, index) {
                var _market =
                    futureMarket.allSearchMarket[_currentMarketSort][index];

                return ListTile(
                  onTap: () async {
                    await futureMarket.setActiveMarket(_market);
                    futureMarket.getMarketInfo(context, _market['id']);
                    widget.updateMarket();
                    Navigator.pop(context);
                  },
                  title: Row(
                    children: [
                      Text(
                        '${_market['multiplierCoin']}',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        ' /${_market['marginCoin']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${futureMarket.activeMarketAllTicks[_market['contractOtherName'].toLowerCase()] != null ? futureMarket.activeMarketAllTicks[_market['contractOtherName'].toLowerCase()]['close'] : '--'}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: futureMarket.activeMarketAllTicks[
                                      _market['contractOtherName']
                                          .toLowerCase()] !=
                                  null
                              ? (((double.parse('${futureMarket.activeMarketAllTicks[_market['contractOtherName'].toLowerCase()]['open']}') -
                                              double.parse(
                                                  '${futureMarket.activeMarketAllTicks[_market['contractOtherName'].toLowerCase()]['close']}')) /
                                          double.parse(
                                              '${futureMarket.activeMarketAllTicks[_market['contractOtherName'].toLowerCase()]['open']}')) >
                                      0)
                                  ? greenlightchartColor
                                  : errorColor
                              : Colors.white,
                        ),
                      ),
                      Text(
                        '${futureMarket.activeMarketAllTicks[_market['contractOtherName'].toLowerCase()] != null ? (double.parse(futureMarket.activeMarketAllTicks[_market['contractOtherName'].toLowerCase()]['rose']) * 100).toStringAsFixed(2) : '--'}%',
                        style: TextStyle(
                          color: futureMarket.activeMarketAllTicks[
                                      _market['contractOtherName']
                                          .toLowerCase()] !=
                                  null
                              ? double.parse(futureMarket.activeMarketAllTicks[
                                              _market['contractOtherName']
                                                  .toLowerCase()]['rose'] ??
                                          '0') >
                                      0
                                  ? greenlightchartColor
                                  : errorColor
                              : secondaryTextColor,
                          fontSize: 12,
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
  }
}
