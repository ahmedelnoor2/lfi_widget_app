import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/trade/common/percentage_indicator.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

class TradeHistory extends StatefulWidget {
  static const routeName = '/trade_history';
  const TradeHistory({Key? key}) : super(key: key);

  @override
  State<TradeHistory> createState() => _TradeHistoryState();
}

class _TradeHistoryState extends State<TradeHistory>
    with SingleTickerProviderStateMixin {
  late final TabController _tabTradeHistoryController =
      TabController(length: 3, vsync: this);

  @override
  Widget build(BuildContext context) {
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
                      'Spot',
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
                  openOrders(),
                  orderHistory(),
                  tradeHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget openOrders() {
    return Container(
      padding: EdgeInsets.all(9),
      child: ListView.builder(
        itemCount: [greenIndicator, redIndicator].length,
        itemBuilder: (BuildContext context, int index) {
          var item = [greenIndicator, redIndicator][index];
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
                                'Limit/${item == greenIndicator ? 'Buy' : 'Sell'}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: item,
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
                                      '50%',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 20, top: 20),
                                  child: SemiCircleWidget(
                                    diameter: 0,
                                    sweepAngle: (100.0).clamp(0.0, 80.0),
                                    color: item,
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
                                  'LYO/USDT',
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
                                                '0.00 / ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                              Text(
                                                '7589494',
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
                                            '45,687.67',
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
                            '${DateFormat('yyy-mm-dd hh:mm:ss').format(DateTime.now())}',
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

  Widget orderHistory() {
    return Container(
      padding: EdgeInsets.all(9),
      child: ListView.builder(
        itemCount: [1, 2].length,
        itemBuilder: (BuildContext context, int index) {
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
                                      'LYO/USDT',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      'Limit/Buy',
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
                                                '0.00 / ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                              Text(
                                                '7589494',
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
                                            '45,687.67',
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
                            '${DateFormat('yyy-mm-dd hh:mm:ss').format(DateTime.now())}',
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

  Widget tradeHistory() {
    return Container(
      padding: EdgeInsets.all(9),
      child: ListView.builder(
        itemCount: [1, 2].length,
        itemBuilder: (BuildContext context, int index) {
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
                                      'LYO/USDT',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      'Limit/Buy',
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
                            '${DateFormat('yyy-mm-dd hh:mm:ss').format(DateTime.now())}',
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
                                '0.00 / ',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '7589494',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          // padding: EdgeInsets.only(right: 20),
                          child: Text(
                            '45,687.67',
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
