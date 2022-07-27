import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Coins.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class TransactionDetails extends StatefulWidget {
  static const routeName = '/transaction_details';
  const TransactionDetails({Key? key}) : super(key: key);

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  @override
  Widget build(BuildContext context) {
    var asset = Provider.of<Asset>(context, listen: true);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Container(
        padding: EdgeInsets.only(
          bottom: 15,
          left: 15,
          right: 15,
        ),
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
                      icon: Icon(Icons.chevron_left),
                    ),
                    Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Divider(),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Amount',
                      style: TextStyle(
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          '${asset.transactionDetails['amount']}',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                          '${getCoinName(asset.transactionDetails['symbol'])}'),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      '${asset.transactionDetails['status_text']}',
                      style: TextStyle(
                        color: asset.transactionDetails['status_text'] ==
                                'Completed'
                            ? greenIndicator
                            : warningColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Divider(),
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Confirmation times',
                        style: TextStyle(color: secondaryTextColor),
                      ),
                      Text(
                        '${asset.transactionDetails['confirmDesc']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Address',
                        style: TextStyle(color: secondaryTextColor),
                      ),
                      InkWell(
                        onTap: () async {
                          Clipboard.setData(
                            ClipboardData(
                              text: '${asset.transactionDetails['addressTo']}',
                            ),
                          );
                          snackAlert(context, SnackTypes.success, 'Copied');
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: width * 0.5,
                              child: Text(
                                '${asset.transactionDetails['addressTo']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Icon(
                              Icons.copy,
                              size: 15,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Blockchain ID',
                        style: TextStyle(color: secondaryTextColor),
                      ),
                      InkWell(
                        onTap: () async {
                          Clipboard.setData(
                            ClipboardData(
                              text:
                                  '${asset.transactionDetails['txid'].isNotEmpty ? asset.transactionDetails['txid'] : asset.transactionDetails['id']}',
                            ),
                          );
                          snackAlert(context, SnackTypes.success, 'Copied');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 5),
                              width: width * 0.5,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${asset.transactionDetails['txid'].isNotEmpty ? asset.transactionDetails['txid'] : asset.transactionDetails['id']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.copy,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Wallet processing time',
                        style: TextStyle(color: secondaryTextColor),
                      ),
                      SizedBox(
                        width: width * 0.5,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${DateFormat('dd-MM-y H:mm').format(DateTime.fromMillisecondsSinceEpoch(asset.transactionDetails['updateAtTime']))}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time',
                        style: TextStyle(color: secondaryTextColor),
                      ),
                      SizedBox(
                        width: width * 0.5,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${DateFormat('dd-MM-y H:mm').format(DateTime.fromMillisecondsSinceEpoch(asset.transactionDetails['createdAtTime']))}',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
