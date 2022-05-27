import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/assets/digital_assets.dart';
import 'package:lyotrade/screens/assets/margin_assets.dart';
import 'package:lyotrade/screens/assets/otc_assets.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';

class Assets extends StatefulWidget {
  static const routeName = '/assets';
  const Assets({Key? key}) : super(key: key);

  @override
  State<Assets> createState() => _AssetsState();
}

class _AssetsState extends State<Assets> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool _checkAuthStatus = true;
  List _digitalAssets = [];
  List _marginAssets = [];
  List _p2pAssets = [];
  double _bottomBoxSize = 0.58;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
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
    await asset.getAccountBalance(auth, "");
    await asset.getP2pBalance(auth);
    await asset.getMarginBalance(auth);
    List _digAssets = [];
    asset.accountBalance['allCoinMap'].forEach((k, v) {
      _digAssets.add({
        'coin': k,
        'values': v,
      });
    });
    setState(() {
      _digitalAssets = _digAssets;
      _p2pAssets = asset.p2pBalance['allCoinMap'];
    });
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
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);
    var public = Provider.of<Public>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);

    List _accounts = [
      {'icon': 'digital.png', 'name': 'Digital Account'},
      {'icon': 'p2p.png', 'name': 'P2P Account'},
      {'icon': 'margin.png', 'name': 'Margin Account'},
      {'icon': 'stake.png', 'name': 'Staking'},
    ];
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
                  // headerSliverBuilder:
                  //     (BuildContext context, bool innerBoxIsScrolled) {
                  //   if (innerBoxIsScrolled) {
                  //     Future.delayed(const Duration(seconds: 0), () async {
                  //       setState(() {
                  //         _bottomBoxSize = 0.78;
                  //       });
                  //     });
                  //   } else {
                  //     Future.delayed(const Duration(seconds: 0), () async {
                  //       setState(() {
                  //         _bottomBoxSize = 0.58;
                  //       });
                  //     });
                  //   }
                  //   return <Widget>[
                  //     assetsBar(
                  //       context,
                  //       auth,
                  //       width,
                  //       innerBoxIsScrolled,
                  //       _tabController,
                  //       asset.accountBalance,
                  //       public,
                  //       asset.totalAccountBalance,
                  //     ),
                  //   ];
                  // },
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
                                  Icon(Icons.remove_red_eye),
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
                                                      '0.09244421 BTC',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Text(
                                                    '≈\$2,567.56 USD',
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
                                  height: height * 0.21,
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(top: 50, right: 12),
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
                            ListView.separated(
                              separatorBuilder: (context, index) => SizedBox(
                                height: 4,
                              ),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _accounts.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
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
                                          children: [
                                            Text(
                                              '277.73 USD',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '= 0.0967474 BTC',
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
                                  onPressed: () {},
                                  child: Text('Deposit'),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.28,
                                child: ElevatedButton(
                                  onPressed: () {},
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
                  //  TabBarView(
                  //   controller: _tabController,
                  //   children: [
                  //     DigitalAssets(
                  //       assets: _digitalAssets,
                  //       bottomBoxSize: _bottomBoxSize,
                  //       totalBalance: asset.accountBalance['totalBalance'],
                  //       totalBalanceSymbol:
                  //           asset.accountBalance['totalBalanceSymbol'],
                  //     ),
                  //     OtcAssets(
                  //       assets: _p2pAssets,
                  //       bottomBoxSize: _bottomBoxSize,
                  //       totalBalance: asset.p2pBalance['totalBalance'],
                  //       totalBalanceSymbol:
                  //           asset.p2pBalance['totalBalanceSymbol'],
                  //     ),
                  //     MarginAssets(
                  //       assets: _marginAssets,
                  //       bottomBoxSize: _bottomBoxSize,
                  //       totalBalance: asset.p2pBalance['totalBalance'],
                  //       totalBalanceSymbol:
                  //           asset.p2pBalance['totalBalanceSymbol'],
                  //     ),
                  //   ],
                  // ),
                ),
      bottomNavigationBar: bottomNav(context),
    );
  }
}
