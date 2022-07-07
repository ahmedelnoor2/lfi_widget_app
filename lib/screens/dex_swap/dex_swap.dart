import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/dex_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/dex_swap/common/exchange_now.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:provider/provider.dart';

class DexSwap extends StatefulWidget {
  static const routeName = '/dex_swap';
  const DexSwap({Key? key}) : super(key: key);

  @override
  State<DexSwap> createState() => _DexSwapState();
}

class _DexSwapState extends State<DexSwap> {
  @override
  void initState() {
    getAllCurrencies();
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> getAllCurrencies() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var dexProvider = Provider.of<DexProvider>(context, listen: false);

    await dexProvider.getAllCurrencies(context, auth);
    await dexProvider.estimateExchangeValue(
      context,
      auth,
      '1',
      dexProvider.fromActiveCurrency['ticker'],
      dexProvider.toActiveCurrency['ticker'],
    );
  }

  Future<void> clearPaymentProcess() async {
    var dexProvider = Provider.of<DexProvider>(context, listen: false);
    await dexProvider.clearPaymentProcess();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return onAndroidBackPress(context);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                clearPaymentProcess();
              },
              icon: Icon(Icons.chevron_left),
            ),
            bottom: TabBar(
              tabs: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Exchange Now',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Fixed Rate',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              'DEX Swap',
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
          body: TabBarView(
            children: [
              ExchangeNow(),
              Center(
                child: Text('Coming Soon...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
