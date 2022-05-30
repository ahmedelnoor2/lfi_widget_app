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
    if (auth.userInfo.isNotEmpty) {
      getAccountBalance();
    }
    setState(() {
      _checkAuthStatus = false;
    });
  }

  Future<void> getAccountBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getTotalBalance(auth);
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
        'balance': asset.totalAccountBalance['balance'] ?? '0'
      },
      {
        'icon': 'p2p.png',
        'name': 'P2P Account',
        'path': '/p2p_assets',
        'balance': asset.totalAccountBalance['c2cBalance'] ?? '0'
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
                    padding: EdgeInsets.all(width * 0.03),
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
                                    'Total Assets in USD',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
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
                                                      '${_hideBalances ? _hideBalanceString : asset.totalAccountBalance['totalbalance']} BTC',
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
                                                            ? '${double.parse(asset.totalAccountBalance['totalbalance'] ?? '0') * public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()][_totalBalanceSymbol]}'
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
                                                    '\$4.20',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          greenlightchartColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    '/0.15%',
                                                    style: TextStyle(
                                                      color:
                                                          greenlightchartColor,
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
                                return GestureDetector(
                                  onTap: () {
                                    if (_accounts[index]['path'] ==
                                        '/staking') {
                                      snackAlert(context, SnackTypes.warning,
                                          'Coming Soon...');
                                    } else {
                                      Navigator.pushNamed(context,
                                          '${_accounts[index]['path']}');
                                    }
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
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${_hideBalances ? _hideBalanceString : double.parse('${_accounts[index]['balance']}').toStringAsFixed(6)} $_totalBalanceSymbol',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '=${_hideBalances ? _hideBalanceString : getNumberFormat(
                                                    context,
                                                    public.rate[public
                                                                    .activeCurrency[
                                                                        'fiat_symbol']
                                                                    .toUpperCase()]
                                                                [
                                                                _totalBalanceSymbol] !=
                                                            null
                                                        ? '${double.parse(_accounts[index]['balance'] ?? '0') * public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()][_totalBalanceSymbol]}'
                                                        : '0',
                                                  )}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: secondaryTextColor,
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
                                    Navigator.pushNamed(
                                      context,
                                      '/deposit_assets',
                                    );
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
                ),
      bottomNavigationBar: bottomNav(context),
    );
  }
}
