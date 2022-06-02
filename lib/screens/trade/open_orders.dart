import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/screens/trade/common/percentage_indicator.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class OpenOrders extends StatefulWidget {
  const OpenOrders({Key? key}) : super(key: key);

  @override
  State<OpenOrders> createState() => _OpenOrdersState();
}

class _OpenOrdersState extends State<OpenOrders>
    with SingleTickerProviderStateMixin {
  late final TabController _tabOpenOrderController =
      TabController(length: 2, vsync: this);

  bool _hideOtherPairs = false;

  @override
  void initState() {
    // getOpenOrders();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Future<void> getOpenOrders() async {
  //   var trading = Provider.of<Trading>(context, listen: false);
  //   var auth = Provider.of<Auth>(context, listen: false);

  //   if (auth.userInfo.isNotEmpty) {
  //     await trading.getOrders(context, auth, {
  //       "entrust": 1,
  //       "isShowCanceled": 0,
  //       "orderType": 1,
  //       "page": 1,
  //       "pageSize": 10,
  //       "symbol": "",
  //     });
  //   }
  // }

  void cancelAllOrders() {
    var trading = Provider.of<Trading>(context, listen: false);

    var auth = Provider.of<Auth>(context, listen: false);

    trading.cancellAllOrders(context, auth, {
      "orderType": "1",
      "symbol": "",
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var auth = Provider.of<Auth>(context, listen: true);
    var trading = Provider.of<Trading>(context, listen: true);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              // height: 100,
              width: width * 0.5,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                isScrollable: true,
                onTap: (value) => setState(() {
                  // _tabIndicatorColor = value == 0 ? Colors.green : Colors.red;
                }),
                tabs: <Tab>[
                  Tab(text: 'Open Orders(${trading.openOrders.length})'),
                  Tab(text: 'Funds'),
                ],
                controller: _tabOpenOrderController,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/trade_history');
              },
              icon: Icon(
                Icons.insert_drive_file,
                color: secondaryTextColor400,
              ),
            )
          ],
        ),
        Divider(height: 0),
        Flexible(
          child: TabBarView(
            controller: _tabOpenOrderController,
            children: [
              Container(
                child: auth.userInfo.isEmpty
                    ? noAuth(context)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 10),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _hideOtherPairs = !_hideOtherPairs;
                                          });
                                        },
                                        child: Icon(
                                          Icons.check_circle,
                                          color: _hideOtherPairs
                                              ? greenIndicator
                                              : secondaryTextColor400,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    Text('Hide Other Pairs'),
                                  ],
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
                                      'Cancel All',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 0),
                          (trading.openOrders.length <= 0)
                              ? noData()
                              : openOrderList(context, trading.openOrders),
                        ],
                      ),
              ),
              auth.userInfo.isEmpty ? noAuth(context) : noData(),
            ],
          ),
        ),
      ],
    );
  }

  Widget noData() {
    return Container(
      padding: EdgeInsets.only(top: 50),
      child: Column(
        children: [
          Icon(
            Icons.folder_off,
            size: 50,
            color: secondaryTextColor,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Text(
              'No Data',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget openOrderList(context, openOrders) {
    return Container(
      padding: EdgeInsets.all(15),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: openOrders.length,
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
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text(
                                'Limit/Buy',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: greenIndicator,
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
                                    color: greenIndicator,
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

  Widget noAuth(context) {
    return Container(
      padding: EdgeInsets.only(top: 50),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/authentication');
            },
            child: Text(
              'Sign In',
              style: TextStyle(
                color: linkColor,
              ),
            ),
          ),
          Text(' or '),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/authentication');
            },
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: linkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
