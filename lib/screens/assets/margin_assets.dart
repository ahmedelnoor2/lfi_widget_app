import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/assets/skeleton/assets_skull.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';

class MarginAssets extends StatefulWidget {
  static const routeName = '/margin_assets';
  const MarginAssets({
    Key? key,
  }) : super(key: key);

  @override
  State<MarginAssets> createState() => _MarginAssetsState();
}

class _MarginAssetsState extends State<MarginAssets> {
  List _marginAssets = [];
  List _smallBalancesMarginAssets = [];
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

    await asset.getMarginBalance(auth);
    List _margAssets = [];
    asset.marginBalance['leverMap'].forEach((k, v) {
      _margAssets.add({
        'coin': k.split('/')[0],
        'market': k,
        'values': v,
      });
    });
    setState(() {
      _marginAssets = _margAssets;
      _totalBalanceSymbol = asset.marginBalance['totalBalanceSymbol'];
    });
  }

  Future<void> getHideSmallBalances() async {
    if (_hideSmallBalances) {
      var asset = Provider.of<Asset>(context, listen: false);
      List _smallBalancesMarAssets = [];

      asset.marginBalance['leverMap'].forEach((k, v) {
        if (double.parse('${v['symbolNetAssetBalance']}') > 0.00) {
          _smallBalancesMarAssets.add({
            'coin': k.split('/')[0],
            'market': k,
            'values': v,
          });
        }
      });
      setState(() {
        _smallBalancesMarginAssets = _smallBalancesMarAssets;
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
                        'Margin Account',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      toggleHideBalances();
                    },
                    child: _hideBalances
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off),
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
                                      '${_hideBalances ? _hideBalanceString : asset.marginBalance['totalBalance'] ?? '0.000000'} $_totalBalanceSymbol',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    '≈${_hideBalances ? _hideBalanceString : getNumberFormat(
                                        context,
                                        public.rate[public.activeCurrency[
                                                        'fiat_symbol']
                                                    .toUpperCase()][asset
                                                            .accountBalance[
                                                        _totalBalanceSymbol] ??
                                                    'BTC'] !=
                                                null
                                            ? '${double.parse(asset.marginBalance['totalbalance'] ?? '0') * public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()][_totalBalanceSymbol]}'
                                            : '0',
                                      )}',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Yesterday\'s PNL',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '\$4.20',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: greenlightchartColor,
                                    ),
                                  ),
                                  Text(
                                    '/0.15%',
                                    style: TextStyle(
                                      color: greenlightchartColor,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
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
                      'Account',
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
                          'Lent',
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
              child: _marginAssets.isEmpty
                  ? assetsSkull(context)
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _hideSmallBalances
                          ? _smallBalancesMarginAssets.length
                          : _marginAssets.length,
                      itemBuilder: (BuildContext context, int index) {
                        var asset = _hideSmallBalances
                            ? _smallBalancesMarginAssets[index]
                            : _marginAssets[index];
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
                                        radius: 12,
                                        child: Image.network(
                                          '${public.publicInfoMarket['market']['coinList'][asset['values']['baseCoin']]['icon']}',
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${asset['values']['name']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'LYO Credit',
                                          style: TextStyle(
                                            fontSize: 11,
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${_hideBalances ? _hideBalanceString : asset['values']['baseExNormalBalance'].toStringAsFixed(4)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${_hideBalances ? _hideBalanceString : asset['values']['quoteEXNormalBalance'].toStringAsFixed(4)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.12,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _hideBalances
                                            ? _hideBalanceString
                                            : double.parse(
                                                    '${asset['values']['baseLockBalance']}')
                                                .toStringAsFixed(4),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _hideBalances
                                            ? _hideBalanceString
                                            : '${double.parse('${asset['values']['quoteLockBalance']}').toStringAsFixed(4)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
                                      Text(
                                        _hideBalances
                                            ? _hideBalanceString
                                            : double.parse(
                                                    '${asset['values']['baseTotalBalance']}')
                                                .toStringAsFixed(4),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _hideBalances
                                            ? _hideBalanceString
                                            : double.parse(
                                                    '${asset['values']['quoteTotalBalance']}')
                                                .toStringAsFixed(4),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
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
                      child: Text('Transfer'),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.28,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Loans'),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.28,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Trade'),
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
