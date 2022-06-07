import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:provider/provider.dart';

class FutureTrade extends StatefulWidget {
  static const routeName = '/future_trade';
  const FutureTrade({Key? key}) : super(key: key);

  @override
  State<FutureTrade> createState() => _FutureTradeState();
}

class _FutureTradeState extends State<FutureTrade> {
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: true);
    return Scaffold(
      appBar: appBar(context, null),
      body: const Center(
        child: Text('100x Future Trades coming soon...'),
      ),
      bottomNavigationBar: bottomNav(context, auth),
    );
  }
}
