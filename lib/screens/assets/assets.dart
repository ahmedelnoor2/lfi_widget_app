import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';

class Assets extends StatefulWidget {
  static const routeName = '/assets';
  const Assets({Key? key}) : super(key: key);

  @override
  State<Assets> createState() => _AssetsState();
}

class _AssetsState extends State<Assets> {
  bool _checkAuthStatus = true;
  String _totalBalanceSymbol = 'BTC';

  @override
  void initState() {
    checkLoginStatus();
    super.initState();
  }

  Future<void> checkLoginStatus() async {
    setState(() {
      _checkAuthStatus = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    await auth.checkLogin(context);
    if (auth.isAuthenticated) {
      getAccountBalance();
    } else {
      Navigator.pushNamed(context, '/authentication');
    }
    setState(() {
      _checkAuthStatus = false;
    });
  }

  Future<void> getAccountBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getTotalBalance(auth);
    if (asset.accountBalance.isNotEmpty) {
      setState(() {
        _totalBalanceSymbol = asset.accountBalance['totalBalanceSymbol'];
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

    List _accounts = [
      {
        'icon': 'digital.png',
        'name': 'Digital Account',
        'path': '/digital_assets',
        'balance': asset.totalAccountBalance['balance'] ?? '0',
      },
      {
        'icon': 'p2p.png',
        'name': 'P2P Account',
        'path': '/p2p_assets',
        'balance': asset.totalAccountBalance['c2cBalance'] ?? '0',
      },
      {
        'icon': 'margin.png',
        'name': 'Margin Account',
        'path': '/margin_assets',
        'balance': asset.totalAccountBalance['leverBalance'] ?? '0'
      },
      {
        'icon': 'stake.png',
        'name': 'Staking',
        'path': '/staking',
        'balance': '0',
      },
    ];

    bool _hideBalances = asset.hideBalances;
    String _hideBalanceString = asset.hideBalanceString;

    return Scaffold(
      body: _checkAuthStatus
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : auth.userInfo.isEmpty
              ? Scaffold(
                  appBar: appBar(context, null),
                  body: Center(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.account_balance_wallet,
                              size: width * 0.2,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Please login to manage your assets',
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: secondaryTextColor,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              textStyle: TextStyle(fontSize: width * 0.05),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/authentication',
                              );
                            },
                            child: const Text('Login'),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Scaffold(
                  appBar: AppBar(
                    shadowColor: Colors.transparent,
                    toolbarHeight: 0,
                  ),
                  body: Container(
                    padding: EdgeInsets.all(width * 0.025),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  right: 5, left: 5, bottom: 24),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Assets in $_totalBalanceSymbol',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
                            ),
                            Stack(
                              children: [
                                SizedBox(
                                  width: width,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: Text(
                                                      '${_hideBalances ? _hideBalanceString : asset.totalAccountBalance['totalbalance']} $_totalBalanceSymbol',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Text(
                                                    '≈${_hideBalances ? _hideBalanceString : getNumberFormat(
                                                        context,
                                                        public.rate[public
                                                                        .activeCurrency[
                                                                            'fiat_symbol']
                                                                        .toUpperCase()]
                                                                    [
                                                                    _totalBalanceSymbol] !=
                                                                null
                                                            ? double.parse(
                                                                    asset.totalAccountBalance['totalbalance'] ??
                                                                        '0') *
                                                                public.rate[public
                                                                    .activeCurrency[
                                                                        'fiat_symbol']
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                            public.rate[public
                                                                    .activeCurrency[
                                                                        'fiat_symbol']
                                                                    .toUpperCase()]
                                                                [
                                                                _totalBalanceSymbol])),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: asset
                                                              .accountBalance
                                                              .isNotEmpty
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
                                                      color: asset
                                                              .accountBalance
                                                              .isNotEmpty
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
                                    padding:
                                        EdgeInsets.only(top: 50, right: 12),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Image.asset(
                                        'assets/img/asset_background.png',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            ListView.separated(
                              separatorBuilder: (context, index) => SizedBox(
                                height: 4,
                              ),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _accounts.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '${_accounts[index]['path']}');
                                  },
                                  child: Card(
                                    child: ListTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    EdgeInsets.only(right: 16),
                                                child: Image.asset(
                                                  'assets/img/${_accounts[index]['icon']}',
                                                  width: 25,
                                                ),
                                              ),
                                              Text(
                                                '${_accounts[index]['name']}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          _accounts[index]['path'] == '/staking'
                                              ? Container()
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '${_hideBalances ? _hideBalanceString : double.parse('${_accounts[index]['balance']}').toStringAsFixed(6)} $_totalBalanceSymbol',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      '=${_hideBalances ? _hideBalanceString : getNumberFormat(
                                                          context,
                                                          public.rate[public.activeCurrency['fiat_symbol']
                                                                          .toUpperCase()][
                                                                      _totalBalanceSymbol] !=
                                                                  null
                                                              ? double.parse(
                                                                      _accounts[index][
                                                                              'balance'] ??
                                                                          '0') *
                                                                  public.rate[public
                                                                      .activeCurrency[
                                                                          'fiat_symbol']
                                                                      .toUpperCase()][_totalBalanceSymbol]
                                                              : 0,
                                                        )}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            secondaryTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                        ],
                                      ),
                                      trailing: Icon(Icons.chevron_right),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: width * 0.28,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (auth.userInfo['realAuthType'] == 0) {
                                      snackAlert(context, SnackTypes.warning,
                                          'Deposit limited(Please check KYC status)');
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/deposit_assets',
                                      );
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
                                    Navigator.pushNamed(
                                      context,
                                      '/transfer_assets',
                                    );
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
                ),
      bottomNavigationBar: bottomNav(context, auth),
    );
  }
}
