import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/header.dart';

class DepositAssets extends StatefulWidget {
  static const routeName = '/deposit_assets';
  const DepositAssets({Key? key}) : super(key: key);

  @override
  State<DepositAssets> createState() => _DepositAssetsState();
}

class _DepositAssetsState extends State<DepositAssets> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, null),
      body: Center(
        child: Text('Deposit'),
      ),
    );
  }
}
