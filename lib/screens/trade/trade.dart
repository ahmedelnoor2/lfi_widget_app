import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';

class Trade extends StatefulWidget {
  static const routeName = '/trade';
  const Trade({Key? key}) : super(key: key);

  @override
  State<Trade> createState() => _TradeState();
}

class _TradeState extends State<Trade> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, null),
      body: const Center(
        child: Text('Happy Trading'),
      ),
      bottomNavigationBar: bottomNav(context),
    );
  }
}
