import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';

class FutureTrade extends StatefulWidget {
  static const routeName = '/future_trade';
  const FutureTrade({Key? key}) : super(key: key);

  @override
  State<FutureTrade> createState() => _FutureTradeState();
}

class _FutureTradeState extends State<FutureTrade> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, null),
      body: const Center(
        child: Text('100x Future Trades'),
      ),
      bottomNavigationBar: bottomNav(context),
    );
  }
}
