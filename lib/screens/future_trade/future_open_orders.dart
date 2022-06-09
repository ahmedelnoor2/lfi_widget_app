import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/future_market.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class FutureOpenOrders extends StatefulWidget {
  const FutureOpenOrders({Key? key}) : super(key: key);

  @override
  State<FutureOpenOrders> createState() => _FutureOpenOrdersState();
}

class _FutureOpenOrdersState extends State<FutureOpenOrders>
    with SingleTickerProviderStateMixin {
  late final TabController _tabOpenOrderController =
      TabController(length: 2, vsync: this);

  @override
  void initState() {
    getOpenPositions();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getOrderType(orderType) {
    return '$orderType' == '1' ? 'Limit' : 'Market';
  }

  Future<void> getOpenPositions() async {
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);

    if (auth.isAuthenticated) {
      await futureMarket.getOpenPositions(context, auth);
    }
  }

  // Future<void> cancelOrder(formData) async {
  //   var futureMarket = Provider.of<FutureMarket>(context, listen: false);
  //   var auth = Provider.of<Auth>(context, listen: false);

  //   await futureMarket.cancelOrder(
  //     context,
  //     auth,
  //     formData,
  //   );
  //   getOpenOrders();
  // }

  // Future<void> cancelAllOrders() async {
  //   var futureMarket = Provider.of<FutureMarket>(context, listen: false);

  //   var auth = Provider.of<Auth>(context, listen: false);

  //   await futureMarket.cancellAllOrders(context, auth, {
  //     "orderType": "1",
  //     "symbol": "",
  //   });
  //   getOpenOrders();
  // }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var auth = Provider.of<Auth>(context, listen: true);
    var futureMarket = Provider.of<FutureMarket>(context, listen: true);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              // height: 100,
              width: width * 0.6,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                isScrollable: true,
                onTap: (value) {
                  setState(() {
                    // _tabIndicatorColor = value == 0 ? Colors.green : Colors.red;
                  });
                },
                tabs: <Tab>[
                  Tab(
                    text: 'Position(${futureMarket.openPositions.length})',
                  ),
                  Tab(
                    text: 'Open Orders(${futureMarket.openPositions.length})',
                  ),
                ],
                controller: _tabOpenOrderController,
              ),
            ),
            IconButton(
              onPressed: () {
                auth.isAuthenticated
                    ? Navigator.pushNamed(context, '/trade_history')
                    : Navigator.pushNamed(context, '/authentication');
              },
              icon: Icon(
                Icons.insert_drive_file,
                color: secondaryTextColor400,
              ),
            )
          ],
        ),
        Divider(height: 0),
      ],
    );
  }
}
