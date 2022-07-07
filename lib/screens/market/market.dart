import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/trade/kline_chart.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';

class Market extends StatefulWidget {
  static const routeName = '/market';
  const Market({Key? key}) : super(key: key);

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return onAndroidBackPress(context);
      },
      child: KlineChart(),
    );
  }
}
