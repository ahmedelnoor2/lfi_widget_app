import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import '../../../utils/AppConstant.utils.dart';

class GiftCardTransaction extends StatefulWidget {
  static const routeName = '/gift_transaction_detail';
  const GiftCardTransaction({Key? key}) : super(key: key);

  @override
  State<GiftCardTransaction> createState() => _GiftCardTransactionState();
}


class _GiftCardTransactionState extends State<GiftCardTransaction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 10),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.chevron_left),
                      ),
                    ),
                    Text(
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
               
              ],
            ),
            Divider(),
            Expanded(
              
              child: ListView.builder(
                itemCount: 12,
                itemBuilder: (BuildContext context, int index) {
                  // var financialRecord = gifthistoryRecords[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(
                                                  bottom: 8, right: 5),
                                              child: Text(
                                                '23',
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
                                                    padding: EdgeInsets.only(
                                                        bottom: 5),
                                                    child: Text(
                                                      'Type',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: secondaryTextColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        bottom: 5),
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
                                      '',
                                      // '${DateFormat('yyy-mm-dd hh:mm:ss').format(DateTime.parse('${financialRecord['createTime']}'))}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      '3454545',
                                      style: TextStyle(
                                          fontSize: 12, color: redIndicator),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Row(
                                      children: [
                                        Text(
                                          '345345',
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
                                      '34534]}',
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
