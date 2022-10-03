import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/future_market.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/screens/trade/common/percentage_indicator.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class FutureMarketTransaction extends StatefulWidget {
  static const routeName = '/future_market_transaction';
  const FutureMarketTransaction({Key? key}) : super(key: key);

  @override
  State<FutureMarketTransaction> createState() =>
      _FutureMarketTransactionState();
}

class _FutureMarketTransactionState extends State<FutureMarketTransaction> {
  @override
  void initState() {
    getFutureHistoryorder();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getFutureHistoryorder() async {
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);
    var trading = Provider.of<Trading>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    await trading.futureOrderHistory(context, auth, {
      'contractId': futureMarket.activeMarket['id'],
    });
  }

  @override
  Widget build(BuildContext context) {
    var trading = Provider.of<Trading>(context, listen: true);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Column(
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
                    'Future Transaction',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.visibility),
              ),
            ],
          ),
          Divider(
            height: 0,
            color: Color(0xff5E6292),
          ),
          Expanded(
            child: trading.isFuturehistoruyloading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                :trading.futureHistoryList.isNotEmpty? ListView.builder(
                    shrinkWrap: true,
                    itemCount: trading.futureHistoryList.length,
                    itemBuilder: (BuildContext context, int index) {
                      var orderHistory = trading.futureHistoryList[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 8, bottom: 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(
                                                  bottom: 5, right: 5),
                                              child: Text(
                                                '${orderHistory['symbol'].toString()}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 4),
                                              child: Text(
                                                'testing..',
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
                                                    padding: EdgeInsets.only(
                                                        right: 20),
                                                    child: Text(
                                                      'Amount',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            secondaryTextColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        right: 20),
                                                    child: Text(
                                                      'Price',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            secondaryTextColor,
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
                                                    padding: EdgeInsets.only(
                                                        right: 20),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          '${orderHistory['volume']} / ',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                        Text(
                                                          orderHistory['volume']
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                secondaryTextColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        right: 20),
                                                    child: Text(
                                                      '${(orderHistory['price'])}',
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
                                  ],
                                ),
                                SizedBox(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          '12-12-2002',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {},
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              left: 12,
                                              right: 12,
                                              top: 6,
                                              bottom: 6),
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
                                            '${orderHistory['status'].toString()}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
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
                        ),
                      );
                    },
                  ):noData("No Transactions"),
          )
        ],
      ),
    );
  }
}
