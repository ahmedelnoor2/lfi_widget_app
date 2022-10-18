import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/assets/skeleton/assets_skull.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Coins.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import 'package:lyotrade/providers/public.dart';
import 'package:provider/provider.dart';
import 'package:lyotrade/utils/Number.utils.dart';

class DigitalAssets extends StatefulWidget {
  static const routeName = '/digital_assets';
  const DigitalAssets({
    Key? key,
    // this.assets,
    // this.bottomBoxSize,
    // this.totalBalance,
    // this.totalBalanceSymbol,
  }) : super(key: key);

  // final assets;
  // final bottomBoxSize;
  // final totalBalance;
  // final totalBalanceSymbol;

  @override
  State<DigitalAssets> createState() => _DigitalAssetsState();
}

class _DigitalAssetsState extends State<DigitalAssets> {
  List _smallBalancesDigitalAssets = [];
  String _totalBalanceSymbol = 'BTC';
  bool _hideSmallBalances = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    getDigitalBalance();
    super.initState();
  }

  Future<void> getDigitalBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getAccountBalance(context, auth, "");
    List _digAssets = [];
    asset.accountBalance['allCoinMap'].forEach((k, v) {
      _digAssets.add({
        'coin': k,
        'values': v,
      });
    });
    setState(() {
      asset.setDigtalList(_digAssets);
      _totalBalanceSymbol = asset.accountBalance['totalBalanceSymbol'] ?? 'BTC';
    });
  }

  Future<void> getHideSmallBalances() async {
    if (_hideSmallBalances) {
      var asset = Provider.of<Asset>(context, listen: false);
      List _smallBalancesDigAssets = [];

      asset.accountBalance['allCoinMap'].forEach((k, v) {
        if (double.parse(v['total_balance']) > 0.00) {
          _smallBalancesDigAssets.add({
            'coin': k,
            'values': v,
          });
        }
      });
      setState(() {
        _smallBalancesDigitalAssets = _smallBalancesDigAssets;
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

    var auth = Provider.of<Auth>(context, listen: true);
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
                        'Digital Account',
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
                            Navigator.pushNamed(context, '/transactions');
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
                                      '${_hideBalances ? _hideBalanceString : asset.accountBalance['totalBalance'] ?? '0.000000'} $_totalBalanceSymbol',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    '≈${_hideBalances ? _hideBalanceString : getNumberFormat(
                                        context,
                                        public.rate[public.activeCurrency['fiat_symbol']
                                                    .toUpperCase()][asset
                                                            .accountBalance[
                                                        _totalBalanceSymbol] ??
                                                    'BTC'] !=
                                                null
                                            ? double.parse(asset.totalAccountBalance['totalbalance'] ?? '0') *
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
                                    getNumberFormat(
                                        context,
                                        ((double.parse(
                                                '${(asset.accountBalance['yesterdayProfit'] == '--' || asset.accountBalance['yesterdayProfit'] == null) ? 0.00 : asset.accountBalance['yesterdayProfit']}')) *
                                            public.rate[public.activeCurrency[
                                                        'fiat_symbol']
                                                    .toUpperCase()]
                                                [_totalBalanceSymbol])),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: asset.accountBalance.isNotEmpty
                                          ? asset.accountBalance[
                                                      'yesterdayProfitRate'] ==
                                                  '--'
                                              ? secondaryTextColor
                                              : double.parse(asset
                                                              .accountBalance[
                                                          'yesterdayProfitRate']) >
                                                      0
                                                  ? greenIndicator
                                                  : redIndicator
                                          : secondaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    '/${asset.accountBalance.isNotEmpty ? getNumberString(context, double.parse(asset.accountBalance['yesterdayProfitRate'] == '--' ? '0' : asset.accountBalance['yesterdayProfitRate'])) : '0'}%',
                                    style: TextStyle(
                                      color: asset.accountBalance.isNotEmpty
                                          ? asset.accountBalance[
                                                      'yesterdayProfitRate'] ==
                                                  '--'
                                              ? secondaryTextColor
                                              : double.parse(asset
                                                              .accountBalance[
                                                          'yesterdayProfitRate']) >
                                                      0
                                                  ? greenIndicator
                                                  : redIndicator
                                          : secondaryTextColor,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
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
                  Container(
                    margin: EdgeInsets.only(right: 2),
                    child: Container(
                      padding: EdgeInsets.all(5),
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
                            child: Icon(
                              Icons.search,
                              size: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                          SizedBox(
                            width: width * 0.30,
                            child: TextField(
                              onChanged: (value) async {
                                await asset.filterCoin(
                                  value,
                                  asset.digitalAssets,
                                  _totalBalanceSymbol,
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
                        'In Order',
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
                          'Total',
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
              height: height * 0.46,
              child: asset.digitalAssets.isEmpty
                  ? assetsSkull(context)
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _hideSmallBalances
                          ? _smallBalancesDigitalAssets.length
                          : asset.searchallcoin.isNotEmpty
                              ? asset.searchallcoin.length
                              : asset.digitalAssets.length,
                      itemBuilder: (BuildContext context, int index) {
                        var assets = _hideSmallBalances
                            ? _smallBalancesDigitalAssets[index]
                            : asset.searchallcoin.isNotEmpty
                                ? asset.searchallcoin[index]
                                : asset.digitalAssets[index];

                        return InkWell(
                          onTap: () {
                            asset.setSelectedAsset(assets);
                            Navigator.pushNamed(context, '/asset_details');
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  bottom: 8,
                                  left: 5,
                                  right: 5,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: width * 0.33,
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(right: 8),
                                            child: CircleAvatar(
                                              radius: 15,
                                              child: public.publicInfoMarket[
                                                                  'market']
                                                              ['coinList']
                                                          [assets['coin']] !=
                                                      null
                                                  ? Image.network(
                                                      '${public.publicInfoMarket['market']['coinList'][assets['coin']]['icon']}')
                                                  : Icon(
                                                      Icons.hourglass_empty,
                                                      color: Colors.white,
                                                    ),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                getCoinName(
                                                    '${public.publicInfoMarket['market']['coinList'][assets['coin']]['showName']}'),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              Container(
                                                width: 80,
                                                child: Text(
                                                  '${public.publicInfoMarket['market']['coinList'][assets['coin']]['longName'].isNotEmpty ? public.publicInfoMarket['market']['coinList'][assets['coin']]['longName'] : public.publicInfoMarket['market']['coinList'][assets['coin']]['name']}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: secondaryTextColor,
                                                  ),
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
                                          '${_hideBalances ? _hideBalanceString : double.parse(assets['values']['normal_balance']).toStringAsFixed(4)}',
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
                                              : double.parse(assets['values']
                                                      ['lock_balance'])
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  _hideBalances
                                                      ? _hideBalanceString
                                                      : double.parse(assets[
                                                                  'values']
                                                              ['total_balance'])
                                                          .toStringAsFixed(4),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  _hideBalances
                                                      ? _hideBalanceString
                                                      : getNumberFormat(
                                                          context,
                                                          public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()]
                                                                      [assets[
                                                                          'coin']] !=
                                                                  null
                                                              ? (double.parse(
                                                                      assets['values']
                                                                          [
                                                                          'total_balance'])) *
                                                                  public.rate[public
                                                                      .activeCurrency[
                                                                          'fiat_symbol']
                                                                      .toUpperCase()][assets['coin']]
                                                              : 0,
                                                        ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: secondaryTextColor,
                                                  ),
                                                )
                                              ],
                                            ))),
                                  ],
                                ),
                              ),
                              Divider(),
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
                      onPressed: () {
                        if (auth.userInfo['realAuthType'] == 0 ||
                            auth.userInfo['authLevel'] == 0) {
                          snackAlert(context, SnackTypes.warning,
                              'Deposit limited (Please check KYC status)');
                        } else {
                          Navigator.pushNamed(context, '/deposit_assets');
                        }
                      },
                      child: Text('Deposit'),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.28,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/withdraw_assets',
                        );
                      },
                      child: Text('Withdraw'),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.30,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/transfer_assets');
                      },
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
