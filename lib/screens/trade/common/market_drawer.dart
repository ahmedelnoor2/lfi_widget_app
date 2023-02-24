import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/screens/trade/trade_form.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MarketDrawer extends StatefulWidget {
 
   MarketDrawer({
    Key? key,
    this.scaffoldKey,
    this.updateMarket,
  }) : super(key: key);

  final scaffoldKey;
  final updateMarket;

  @override
  State<MarketDrawer> createState() => _MarketDrawerState();
}

class _MarketDrawerState extends State<MarketDrawer>
    with SingleTickerProviderStateMixin {
       TradeForm myclass=TradeForm();
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();

  var _channel;
  String _currentMarketSort = 'ETF';
  bool _loadMarketChange = false;

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
    var auth = Provider.of<Auth>(context, listen: true);

    var trading = Provider.of<Trading>(context, listen: true);

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
              height: width * 0.11,
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
          _loadMarketChange
              ? Center(
                  child: LinearProgressIndicator(),
                )
              : Container(),
          SizedBox(
            height: height * 0.76,
            child: ListView.builder(
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
                  onTap: _loadMarketChange
                      ? () {}
                      : () async {
                          setState(() {
                            _loadMarketChange = true;
                          });
                          public.clearpriceFieldText();   ///price controller clear textSS
                          await public.setActiveMarket(_market);
                          trading.setPrecessionValue(public
                                                  .publicInfoMarket['market']
                                              ['market']
                                          [public.activeMarket['showName'].split('/')[1]]
                                      [public.activeMarket['showName']] !=
                                  null
                              ? public.publicInfoMarket['market']['market']
                                          [public.activeMarket['showName'].split('/')[1]]
                                          [public.activeMarket['showName']]
                                          ['depth']
                                      .split(',')[0] ??
                                  '0.1'
                              : '0.1');
                          trading.setMarketDepth(public.publicInfoMarket['market']
                                              ['market'][
                                          public.activeMarket['showName']
                                              .split('/')[1]]
                                      [public.activeMarket['showName']] !=
                                  null
                              ? public.publicInfoMarket['market']['market']
                                          [public.activeMarket['showName'].split('/')[1]]
                                          [public.activeMarket['showName']]['depth']
                                      .split(',') ??
                                  ['0.1', '0.01', '0.001']
                              : ['0.1', '0.01', '0.001']);
                          widget.updateMarket();
                          await trading.getFunds(context, auth, {
                            "coinSymbols": public.activeMarket['name']
                                .replaceAll(
                                    new RegExp(r"\p{P}", unicode: true), ","),
                          });
                          Navigator.pop(context);
                        },
                  title: Row(
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
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${public.activeMarketAllTicks[_market['symbol']] != null ? public.activeMarketAllTicks[_market['symbol']]['close'] : '--'}',
                        style: TextStyle(
                          fontSize: 15,
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
    ;
  }
}
