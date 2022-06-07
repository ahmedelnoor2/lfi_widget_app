import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/assets/skeleton/assets_skull.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';

class OtcAssets extends StatefulWidget {
  static const routeName = '/p2p_assets';
  const OtcAssets({
    Key? key,
  }) : super(key: key);

  @override
  State<OtcAssets> createState() => _OtcAssetsState();
}

class _OtcAssetsState extends State<OtcAssets> {
  List _p2pAssets = [];
  List _smallBalancesp2plAssets = [];
  String _totalBalanceSymbol = 'BTC';
  bool _hideSmallBalances = false;

  @override
  void initState() {
    getDigitalBalance();
    super.initState();
  }

  Future<void> getDigitalBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    await asset.getP2pBalance(auth);
    setState(() {
      _totalBalanceSymbol = asset.p2pBalance['totalBalanceSymbol'] ?? 'BTC';
      _p2pAssets = asset.p2pBalance['allCoinMap'];
    });
  }

  Future<void> getHideSmallBalances() async {
    if (_hideSmallBalances) {
      var asset = Provider.of<Asset>(context, listen: false);
      List _smallBalancesOtcAssets = [];
      asset.p2pBalance['allCoinMap'].forEach((v) {
        if (double.parse(v['total_balance']) > 0.00) {
          _smallBalancesOtcAssets.add(v);
        }
      });
      setState(() {
        _smallBalancesp2plAssets = _smallBalancesOtcAssets;
      });
    }
  }

  void toggleHideBalances() {
    var asset = Provider.of<Asset>(context, listen: false);
    asset.toggleHideBalances(!asset.hideBalances);
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);

    bool _hideBalances = asset.hideBalances;
    String _hideBalanceString = asset.hideBalanceString;

    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.chevron_left)),
                      ),
                      Text(
                        'P2P Account',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 15),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/p2p_transactions');
                          },
                          child: Icon(Icons.history),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          toggleHideBalances();
                        },
                        child: _hideBalances
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                SizedBox(
                  height: height * 0.18,
                  child: Card(
                    color: Colors.transparent,
                    // elevation: 20,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(0.8, 1),
                          colors: <Color>[
                            Color(0xff3F4374),
                            Color(0xff292C51),
                          ],
                          tileMode: TileMode.mirror,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Valuations',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      '${_hideBalances ? _hideBalanceString : asset.p2pBalance['totalBalance'] ?? '0.000000'} $_totalBalanceSymbol',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    '≈${_hideBalances ? _hideBalanceString : getNumberFormat(
                                        context,
                                        public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()]
                                                    [
                                                    asset.p2pBalance[_totalBalanceSymbol] ??
                                                        'BTC'] !=
                                                null
                                            ? double.parse(
                                                    asset.totalAccountBalance[
                                                            'totalbalance'] ??
                                                        '0') *
                                                public.rate[public
                                                    .activeCurrency['fiat_symbol']
                                                    .toUpperCase()][_totalBalanceSymbol]
                                            : 0,
                                      )}',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Text(
                          //       'Yesterday\'s PNL',
                          //       style: TextStyle(
                          //         fontSize: 10,
                          //       ),
                          //     ),
                          //     Row(
                          //       children: [
                          //         Text(
                          //           '\$4.20',
                          //           style: TextStyle(
                          //             fontWeight: FontWeight.bold,
                          //             color: greenlightchartColor,
                          //           ),
                          //         ),
                          //         Text(
                          //           '/0.15%',
                          //           style: TextStyle(
                          //             color: greenlightchartColor,
                          //           ),
                          //         ),
                          //       ],
                          //     )
                          //   ],
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.177,
                  child: Container(
                    padding: EdgeInsets.only(top: 50, right: 12),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Image.asset(
                        'assets/img/asset_background.png',
                        // height: 200,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            Container(
              padding: EdgeInsets.only(
                left: 5,
                right: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Text('Fund list'),
                      ),
                      Container(
                        width: 20,
                        padding: EdgeInsets.only(right: 10),
                        child: Transform.scale(
                          scale: 0.8,
                          child: Checkbox(
                            value: _hideSmallBalances,
                            splashRadius: 20,
                            onChanged: (val) {
                              setState(() {
                                _hideSmallBalances = !_hideSmallBalances;
                              });
                              getHideSmallBalances();
                            },
                          ),
                        ),
                      ),
                      Text('Hide Small Balance'),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.search,
                      size: 18,
                    ),
                  )
                ],
              ),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.only(
                bottom: 5,
                left: 5,
                right: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.33,
                    child: Text(
                      'Coin',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.27,
                    child: Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.12,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Freeze',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      width: width * 0.19,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Operation',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(
              height: height * 0.48,
              child: _p2pAssets.isEmpty
                  ? assetsSkull(context)
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _hideSmallBalances
                          ? _smallBalancesp2plAssets.length
                          : _p2pAssets.length,
                      itemBuilder: (BuildContext context, int index) {
                        var asset = _hideSmallBalances
                            ? _smallBalancesp2plAssets[index]
                            : _p2pAssets[index];

                        return Container(
                          padding: EdgeInsets.only(
                            bottom: 8,
                            left: 5,
                            right: 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: width * 0.33,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 8),
                                      child: CircleAvatar(
                                        radius: 15,
                                        child: Image.network(
                                          '${public.publicInfoMarket['market']['coinList'][asset['coinSymbol']]['icon']}',
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${asset['coinSymbol']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'LYO Credit',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: width * 0.27,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _hideBalances
                                        ? _hideBalanceString
                                        : '${double.parse('${asset['normal']}').toStringAsFixed(4)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.13,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _hideBalances
                                        ? _hideBalanceString
                                        : double.parse('${asset['lock']}')
                                            .toStringAsFixed(4),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.19,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/transfer_assets');
                                        },
                                        child: Text(
                                          'Transfer',
                                          style: TextStyle(
                                            color: linkColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Divider(),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.28,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Buy'),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.28,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Sell'),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.30,
                    child: ElevatedButton(
                      onPressed: null,
                      child: Text('Transfer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
