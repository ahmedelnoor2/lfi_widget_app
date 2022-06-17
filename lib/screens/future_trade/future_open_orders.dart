import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/future_market.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/screens/trade/common/percentage_indicator.dart';
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
      TabController(length: 3, vsync: this);

  bool _isCancelling = false;
  late Timer _timer;

  @override
  void initState() {
    startTimer();
    getCurrentOrders();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 4);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        getOpenPositions();
      },
    );
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

  Future<void> getCurrentOrders() async {
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);

    if (auth.isAuthenticated) {
      await futureMarket.getCurrentOrders(
          context, auth, futureMarket.activeMarket['id']);
    }
  }

  Future<void> cancelOrder(formData) async {
    setState(() {
      _isCancelling = true;
    });
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);

    await futureMarket.cancelLimitOrder(
      context,
      auth,
      formData,
    );
    setState(() {
      _isCancelling = false;
    });
    getCurrentOrders();
  }

  // Future<void> cancelAllOrders() async {
  //   var futureMarket = Provider.of<FutureMarket>(context, listen: false);

  //   var auth = Provider.of<Auth>(context, listen: false);

  //   await futureMarket.cancellAllOrders(context, auth, {
  //     "orderType": "1",
  //     "symbol": "",
  //   });
  //   getCurrentOrders();
  // }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var auth = Provider.of<Auth>(context, listen: true);
    var futureMarket = Provider.of<FutureMarket>(context, listen: true);

    // print(futureMarket.userConfiguration);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              // height: 100,
              width: width * 0.85,
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
                    text:
                        'Position(${futureMarket.openPositions.isNotEmpty ? futureMarket.openPositions['positionList'].length : 0})',
                  ),
                  Tab(
                    text:
                        'Limit Orders(${futureMarket.currentOrders.isNotEmpty ? futureMarket.currentOrders.length : 0})',
                  ),
                  Tab(
                    text:
                        'Stop Orders(${futureMarket.openPositions.isNotEmpty ? futureMarket.openPositions['positionList'].length : 0})',
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
        Divider(
          height: 0,
          color: Color(0xff5E6292),
        ),
        SizedBox(
          height: height * 0.8,
          child: TabBarView(
            controller: _tabOpenOrderController,
            children: [
              futureMarket.openPositions.isEmpty
                  ? noData('No Open Positions')
                  : openPositions(
                      futureMarket.openPositions['positionList'], futureMarket),
              futureMarket.currentOrders.isEmpty
                  ? noData('No limit orders')
                  : limitOrders(futureMarket.currentOrders),
              Text('Stop Order'),
            ],
          ),
        ),
      ],
    );
  }

  Widget openPositions(openPositions, futureMarket) {
    return Container(
      padding: EdgeInsets.all(9),
      child: ListView.builder(
        itemCount: openPositions.length,
        itemBuilder: (BuildContext context, int index) {
          var position = openPositions[index];
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 5),
                    child: Text(
                      '${position['orderSide']}',
                      style: TextStyle(
                          fontSize: 12,
                          color: position['orderSide'] == 'SELL'
                              ? redIndicator
                              : greenIndicator),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 8),
                    child: Text(
                      '${position['contractOtherName']}',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    'Cross ${futureMarket.userConfiguration['nowLevel']}x',
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unrealized PNL (USDT)',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                        Text(
                          '${position['profitRealizedAmount']}',
                          style: TextStyle(
                            fontSize: 15,
                            color: double.parse(
                                        '${position['profitRealizedAmount']}') >
                                    0
                                ? greenIndicator
                                : redIndicator,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'ROI',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                        Text(
                          '${(double.parse('${position['returnRate']}')).toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 15,
                            color: double.parse('${position['returnRate']}') > 0
                                ? greenIndicator
                                : redIndicator,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Size (${position['symbol'].split('-')[0]})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                              Text(
                                '${position['positionVolume']}',
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Entry Price',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                            Text(
                              double.parse('${position['openAvgPrice']}')
                                  .toStringAsFixed(4),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Margin (${position['symbol'].split('-')[1]})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                              Text(
                                double.parse('${position['holdAmount']}')
                                    .toStringAsFixed(4),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mark Price',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                            Text(
                              double.parse('${position['indexPrice']}')
                                  .toStringAsFixed(4),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Position Balance',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                              Text(
                                double.parse('${position['positionBalance']}')
                                    .toStringAsFixed(4),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Liq. Price',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                            Text(
                              double.parse('${position['reducePrice']}')
                                  .toStringAsFixed(4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Adjust Leverage',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Adjust Leverage',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Adjust Leverage',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }

  Widget limitOrders(openOrders) {
    return Container(
      padding: EdgeInsets.all(9),
      child: ListView.builder(
        itemCount: openOrders.length,
        itemBuilder: (BuildContext context, int index) {
          var openOrder = openOrders[index];
          double filledVolume = double.parse('${openOrder['dealVolume']}') /
              double.parse('${openOrder['volume']}');
          var orderFilled = filledVolume * 100;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.65,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text(
                                'Limit/${openOrder['side']}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: openOrder['side'] == 'BUY'
                                      ? greenIndicator
                                      : redIndicator,
                                ),
                              ),
                            ),
                            Stack(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: secondaryTextColor400,
                                      width: 4,
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                    // shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$orderFilled%',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 20, top: 20),
                                  child: SemiCircleWidget(
                                    diameter: 0,
                                    sweepAngle: (100.0).clamp(0.0, orderFilled),
                                    color: openOrder['side'] == 'BUY'
                                        ? greenIndicator
                                        : redIndicator,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  '${openOrder['symbol']}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(right: 20),
                                          child: Text(
                                            'Amount',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(right: 20),
                                          child: Text(
                                            'Price',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(right: 20),
                                          child: Row(
                                            children: [
                                              Text(
                                                '${double.parse('${openOrder['dealVolume']}').toStringAsFixed(4)} / ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                              Text(
                                                '${double.parse('${openOrder['volume']}').toStringAsFixed(4)}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(right: 20),
                                          child: Text(
                                            '${double.parse('${openOrder['price']}').toStringAsPrecision(6)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            '${DateFormat('yyy-mm-dd hh:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(openOrder['ctime']))}',
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _isCancelling
                              ? null
                              : () {
                                  cancelOrder({
                                    "orderId": openOrder['id'],
                                    "contractId": openOrder['contractId'],
                                    "isConditionOrder": false,
                                  });
                                },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 12, right: 12, top: 6, bottom: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xff292C51),
                              ),
                              color: Color(0xff292C51),
                              borderRadius: BorderRadius.all(
                                Radius.circular(2),
                              ),
                            ),
                            child: _isCancelling
                                ? CircularProgressIndicator.adaptive()
                                : Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}
