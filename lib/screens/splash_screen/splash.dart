import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/dashboard.dart';
import 'package:lyotrade/utils/web_url.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class SpashScreen extends StatefulWidget {
  static const routeName = '/splashScreen';
  const SpashScreen({Key? key}) : super(key: key);

  @override
  State<SpashScreen> createState() => _SpashScreenState();
}

class _SpashScreenState extends State<SpashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    
    waitCalls();
    // getLanguage();
  }

  Future<void> getLanguage() async {
    var languageprovider = Provider.of<LanguageChange>(context, listen: false);
    await languageprovider.getlanguageChange(context);
  }

  

  Future<void> waitCalls() async {
    await getPublicInfo();
    await getBanners();
    await getAssetsRate();
    await getLanguage();
    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }


  Future<void> getAssetsRate() async {
    var public = Provider.of<Public>(context, listen: false);
    await public.assetsRate();
    await public.getFiatCoins();
    await public.getPublicInfoMarket();
    if (public.headerSymbols.isEmpty) {
      await setHeaderSymbols();
    }
    return;
  }

  Future<void> setHeaderSymbols() async {
    var public = Provider.of<Public>(context, listen: false);
    List _headerSymbols = [];
    List _headerSybolsToAdd = [];

    for (int i = 0;
        i <
            public
                .publicInfoMarket['market']['home_symbol_show']
                    ['recommend_symbol_list']
                .length;
        i++) {
      _headerSybolsToAdd.add(public.publicInfoMarket['market']
          ['home_symbol_show']['recommend_symbol_list'][i]);
      _headerSymbols.add({
        'coin': public.publicInfoMarket['market']['home_symbol_show']
                ['recommend_symbol_list'][i]
            .split("/")[0],
        'market': public.publicInfoMarket['market']['home_symbol_show']
            ['recommend_symbol_list'][i],
        'price': '0',
        'change': '0',
      });
    }

    for (int i = 0;
        i < public.publicInfoMarket['market']['headerSymbol'].length;
        i++) {
      if (!_headerSybolsToAdd
          .contains(public.publicInfoMarket['market']['headerSymbol'][i])) {
        _headerSybolsToAdd
            .add(public.publicInfoMarket['market']['headerSymbol'][i]);
        _headerSymbols.add({
          'coin': public.publicInfoMarket['market']['headerSymbol'][i]
              .split("/")[0],
          'market': public.publicInfoMarket['market']['headerSymbol'][i],
          'price': '0',
          'change': '0',
        });
      }
    }
    await public.setHeaderSymbols(_headerSymbols);
    return;
  }

  Future<void> getPublicInfo() async {
    var public = Provider.of<Public>(context, listen: false);
    await public.getPublicInfo();
    return;
  }

  Future<void> getBanners() async {
    var public = Provider.of<Public>(context, listen: false);
    await public.getBanners();
    return;
  }
  Future<void> getLanguage() async {
    var public = Provider.of<Public>(context, listen: false);
    var languageprovider = Provider.of<LanguageChange>(context, listen: false);
    await languageprovider.getlanguageChange(context);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (MediaQuery.of(context).size.width >= 550) {
      webPortalURL();
    }

    return MediaQuery.of(context).size.width >= 550
        ? Container()
        : Scaffold(
            body: Container(
              constraints: const BoxConstraints.expand(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: height * 0.20,
                      left: 20,
                      right: 20,
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Image.asset(
                          'assets/img/splash.png',
                          width: 300,
                          height: 280,
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Text(
                            'LYOTRADE',
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.only(bottom: height * 0.2),
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          );
  }
}
