import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/screens/trade/common/percentage_indicator.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class MarginTradeHistory extends StatefulWidget {
  static const routeName = '/margin_trade_history';
  const MarginTradeHistory({Key? key}) : super(key: key);

  @override
  State<MarginTradeHistory> createState() => _MarginTradeHistoryState();
}

class _MarginTradeHistoryState extends State<MarginTradeHistory>
    with SingleTickerProviderStateMixin {
  late final TabController _tabTradeHistoryController =
      TabController(length: 3, vsync: this);

  @override
  void initState() {
    getOpenOrders();
    getOrderHistory();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getOrderType(orderType) {
    return '$orderType' == '1' ? 'Limit' : 'Market';
  }

  Future<void> getOpenOrders() async {
    var trading = Provider.of<Trading>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);

    if (auth.isAuthenticated) {
      await trading.getOpenOrders(context, auth, {
        "entrust": 1,
        "isShowCanceled": 0,
        "orderType": 2,
        "page": 1,
        "pageSize": 10,
        "symbol": "",
      });
    }
  }

  Future<void> getOrderHistory() async {
    var trading = Provider.of<Trading>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);

    if (auth.isAuthenticated) {
      await trading.getOrderHistory(context, auth, {
        "entrust": 2,
        "isShowCanceled": 1,
        "orderType": 2,
        "page": 1,
        "pageSize": 10,
        "symbol": "",
        "status": null,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var trading = Provider.of<Trading>(context, listen: false);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.chevron_left)),
                    Text(
                      'Margin',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Icon(Icons.remove_red_eye)
              ],
            ),
            TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              isScrollable: true,
              onTap: (value) => setState(() {
                // _tabIndicatorColor = value == 0 ? Colors.green : Colors.red;
              }),
              tabs: <Tab>[
                Tab(text: 'Open Orders'),
                Tab(text: 'Order History'),
                Tab(text: 'Transaction History'),
              ],
              controller: _tabTradeHistoryController,
            ),
            Divider(
              height: 0,
              color: Color(0xff5E6292),
            ),
            SizedBox(
              height: height * 0.8,
              child: TabBarView(
                controller: _tabTradeHistoryController,
                children: [
                  trading.openOrders.isEmpty
                      ? noData()
                      : openOrders(trading.openOrders),
                  trading.orderHistory.isEmpty
                      ? noData()
                      : orderHistory(trading.orderHistory),
                  trading.transactionHistory.isEmpty
                      ? noData()
                      : tradeHistory(trading.transactionHistory),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget openOrders(openOrders) {
    return Container(
      padding: EdgeInsets.all(9),
      child: ListView.builder(
        itemCount: openOrders.length,
        itemBuilder: (BuildContext context, int index) {
          var openOrder = openOrders[index];
          double filledVolume = double.parse(openOrder['volume']) -
              double.parse(openOrder['remain_volume']);
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
                                '${getOrderType(openOrder['type'])}/${openOrder['side']}',
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
                                                '${double.parse(openOrder['remain_volume']).toStringAsPrecision(6)} / ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                              Text(
                                                '${double.parse(openOrder['volume']).toStringAsPrecision(6)}',
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
                                            '${double.parse(openOrder['price']).toStringAsPrecision(6)}',
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
                            '${DateFormat('yyy-mm-dd hh:mm:ss').format(DateTime.parse(openOrder['created_at']))}',
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // cancelAllOrders();
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
                            child: Text(
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

  Widget orderHistory(orderHistories) {
    return Container(
      padding: EdgeInsets.all(9),
      child: ListView.builder(
        itemCount: orderHistories.length,
        itemBuilder: (BuildContext context, int index) {
          var orderHistory = orderHistories[index];
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.65,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.only(bottom: 5, right: 5),
                                    child: Text(
                                      '${orderHistory['symbol']}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '${getOrderType(orderHistory['type'])}/${orderHistory['side']}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: greenIndicator,
                                      ),
                                    ),
                                  )
                                ],
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
                                                '${double.parse(orderHistory['remain_volume']).toStringAsPrecision(4)} / ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                              Text(
                                                double.parse(
                                                        orderHistory['volume'])
                                                    .toStringAsPrecision(4),
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
                                            '${double.parse(orderHistory['price'])}',
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
                            '${DateFormat('yyy-mm-dd hh:mm:ss').format(DateTime.parse(orderHistory['created_at']))}',
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // cancelAllOrders();
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 12, right: 12, top: 6, bottom: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xff292C51),
                              ),
                              color: orderHistory['status_text'] == 'Filled'
                                  ? greenPercentageIndicator
                                  : Color(0xff292C51),
                              borderRadius: BorderRadius.all(
                                Radius.circular(2),
                              ),
                            ),
                            child: Text(
                              '${orderHistory['status_text']}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: orderHistory['status_text'] == 'Filled'
                                    ? greenIndicator
                                    : Colors.white,
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

  Widget tradeHistory(transactionHistories) {
    return Container(
      padding: EdgeInsets.all(9),
      child: ListView.builder(
        itemCount: transactionHistories.length,
        itemBuilder: (BuildContext context, int index) {
          var tradeHistory = transactionHistories[index];
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.65,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.only(bottom: 5, right: 5),
                                    child: Text(
                                      '${tradeHistory['symbol']}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '${getOrderType(tradeHistory['orderType'])}/${tradeHistory['side']}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: greenIndicator,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          child: Text(
                                            'Amount',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          child: Text(
                                            'Price',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: secondaryTextColor,
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
                            '${DateFormat('yyy-mm-dd hh:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(tradeHistory['ctime']))}',
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Row(
                            children: [
                              Text(
                                '${tradeHistory['tradeVolume']}',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          // padding: EdgeInsets.only(right: 20),
                          child: Text(
                            '${tradeHistory['tradePrice']}',
                            style: TextStyle(
                              fontSize: 12,
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
