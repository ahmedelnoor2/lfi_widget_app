import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MarketSearch extends StatefulWidget {
  static const routeName = '/market_search';
  const MarketSearch({
    Key? key,
    this.scaffoldKey,
    this.updateMarket,
  }) : super(key: key);

  final scaffoldKey;
  final updateMarket;

  @override
  State<MarketSearch> createState() => _MarketSearchState();
}

class _MarketSearchState extends State<MarketSearch>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
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

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var public = Provider.of<Public>(context, listen: true);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 5),
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
            padding: EdgeInsets.all(10),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  style: BorderStyle.solid,
                  width: 0.3,
                  color: Color(0xff5E6292),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.search),
                  ),
                  SizedBox(
                    width: width * 0.75,
                    child: TextField(
                      onChanged: (value) async {
                        // await asset.filterSearchResults(value);
                        await public.filterMarketSearchResults(
                          value,
                          public.allMarkets[_currentMarketSort],
                          _currentMarketSort,
                        );
                      },
                      controller: _searchController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "Search",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _tabController != null
              ? SizedBox(
                  height: 40,
                  child: TabBar(
                    onTap: (value) {
                      setState(() {
                        _currentMarketSort = public.publicInfoMarket['market']
                            ['marketSort'][value];
                      });
                    },
                    controller: _tabController,
                    tabs: public.publicInfoMarket['market']['marketSort']
                        .map<Widget>(
                          (mname) => Tab(text: '$mname'),
                        )
                        .toList(),
                  ),
                )
              : Container(),
          Container(
            padding: EdgeInsets.only(top: 10),
            height: height * 0.74,
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider();
              },
              shrinkWrap: true,
              itemCount: public.allSearchMarket[_currentMarketSort].isNotEmpty
                  ? public.allSearchMarket[_currentMarketSort].length
                  : public.allMarkets[_currentMarketSort].length,
              itemBuilder: (context, index) {
                var _market =
                    public.allSearchMarket[_currentMarketSort].isNotEmpty
                        ? public.allSearchMarket[_currentMarketSort][index]
                        : public.allMarkets[_currentMarketSort][index];

                return ListTile(
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
