import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

Widget orderList(context, width, height, allOrders) {
  return Column(
    children: [
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   children: [
      //     SizedBox(
      //       width: width * 0.4,
      //       child: Text(
      //         'Currency',
      //         style: TextStyle(
      //           color: secondaryTextColor,
      //         ),
      //       ),
      //     ),
      //     Text(
      //       'Amount',
      //       style: TextStyle(
      //         color: secondaryTextColor,
      //       ),
      //     ),
      //     Text(
      //       'Status',
      //       style: TextStyle(
      //         color: secondaryTextColor,
      //       ),
      //     ),
      //   ],
      // ),
      // Divider(
      //   height: 0,
      // ),
      SizedBox(
        height: height * 0.60,
        width: width,
        child: ListView.builder(
          itemCount: allOrders.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.only(bottom: 8, right: 5),
                                      child: Text(
                                        'LYO',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
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
                                              'Type',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                          ),
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
                                              'Status',
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
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              'Sell',
                              style:
                                  TextStyle(fontSize: 12, color: redIndicator),
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
      ),
    ],
  );
}
