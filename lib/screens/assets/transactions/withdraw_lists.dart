import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

Widget withdrawList(context, width, height, allWithdrawals) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.4,
            child: Text(
              'Currency',
              style: TextStyle(
                color: secondaryTextColor,
              ),
            ),
          ),
          Text(
            'Amount',
            style: TextStyle(
              color: secondaryTextColor,
            ),
          ),
          Text(
            'Status',
            style: TextStyle(
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
      Divider(
        height: 0,
      ),
      SizedBox(
        height: height * 0.63,
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: allWithdrawals.length,
          itemBuilder: (BuildContext context, int index) {
            var withdrawal = allWithdrawals[index];
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/transaction_details');
              },
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: CircleAvatar(
                            radius: 15,
                            child: Icon(Icons.person),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${withdrawal['symbol']}'),
                              Text(
                                '${DateFormat('yyyy-mm-dd hh:mm:ss').format(DateTime.parse('${withdrawal['createdAt']}'))}',
                                style: TextStyle(
                                    color: secondaryTextColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: Text(
                        '${withdrawal['amount']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      child: SizedBox(
                        height: height * 0.035,
                        width: width * 0.18,
                        child: Card(
                          shadowColor: Colors.transparent,
                          color: greenPercentageIndicator,
                          child: Center(
                            child: Text(
                              '${withdrawal['status_text']}',
                              style: TextStyle(
                                color: greenIndicator,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}