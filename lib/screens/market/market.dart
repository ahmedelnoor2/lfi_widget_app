import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';

class Market extends StatefulWidget {
  static const routeName = '/market';
  const Market({Key? key}) : super(key: key);

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, null),
      body: const Center(
        child: Text('Check Market'),
      ),
      bottomNavigationBar: bottomNav(context),
    );
  }
}
