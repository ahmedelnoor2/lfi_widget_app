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
              : NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    if (innerBoxIsScrolled) {
                      Future.delayed(const Duration(seconds: 0), () async {
                        setState(() {
                          _bottomBoxSize = 0.78;
                        });
                      });
                    } else {
                      Future.delayed(const Duration(seconds: 0), () async {
                        setState(() {
                          _bottomBoxSize = 0.58;
                        });
                      });
                    }
                    return <Widget>[
                      assetsBar(
                        context,
                        auth,
                        width,
                        innerBoxIsScrolled,
                        _tabController,
                        asset.accountBalance,
                        public,
                        asset.totalAccountBalance,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      DigitalAssets(
                        assets: _digitalAssets,
                        bottomBoxSize: _bottomBoxSize,
                        totalBalance: asset.accountBalance['totalBalance'],
                        totalBalanceSymbol:
                            asset.accountBalance['totalBalanceSymbol'],
                      ),
                      OtcAssets(
                        assets: _p2pAssets,
                        bottomBoxSize: _bottomBoxSize,
                        totalBalance: asset.p2pBalance['totalBalance'],
                        totalBalanceSymbol:
                            asset.p2pBalance['totalBalanceSymbol'],
                      ),
                      MarginAssets(
                        assets: _marginAssets,
                        bottomBoxSize: _bottomBoxSize,
                        totalBalance: asset.p2pBalance['totalBalance'],
                        totalBalanceSymbol:
                            asset.p2pBalance['totalBalanceSymbol'],
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: bottomNav(context),
    );
  }
}
