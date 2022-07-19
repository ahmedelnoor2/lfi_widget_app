import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PixProcessPayment extends StatefulWidget {
  static const routeName = '/pix_process_payment';
  const PixProcessPayment({Key? key}) : super(key: key);

  @override
  State<PixProcessPayment> createState() => _PixProcessPaymentState();
}

class _PixProcessPaymentState extends State<PixProcessPayment>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Timer? _timer;
  Timer? _timerForOrderUpdate;
  Map _currentTransaction = {};

  @override
  void initState() {
    getUserDetails();
    startOrderCheckTimer();
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    if (_timerForOrderUpdate != null) {
      _timerForOrderUpdate!.cancel();
    }
    _controller.dispose();
    super.dispose();
  }

  void startOrderCheckTimer() {
    _timerForOrderUpdate = Timer.periodic(
      const Duration(seconds: 5),
      (Timer timer) {
        getUserDetails();
      },
    );
  }

  Future<void> getUserDetails() async {
    var payments = Provider.of<Payments>(context, listen: false);
    await payments.getAllPixTransactions(
      payments.pixKycClients['client_uuid'],
    );
    if (payments.allPixTransactions.isNotEmpty) {
      for (var transaction in payments.allPixTransactions) {
        if (transaction['uuid_transaction'] ==
            payments.pixNewTransaction['uuid_transaction']) {
          setState(() {
            _currentTransaction = transaction;
          });
          if (_timer == null) {
            payments.decryptPixQR({"qr_code": transaction['qr_code']});
            setState(() {
              _timer = Timer.periodic(
                const Duration(seconds: 1),
                (Timer timer) {
                  final nowDate = DateTime.now().toLocal();
                  var endDate = DateTime.parse(transaction['date_end'])
                      .toLocal()
                      .add(Duration(
                          hours: int.parse(nowDate.timeZoneOffset
                              .toString()
                              .split(":")[0])));
                  final difference = nowDate.difference(endDate).toString();
                  final hour =
                      difference.split(':')[0].replaceAll(RegExp('-'), '');
                  final minute = difference.split(':')[1];
                  final second = difference.split(':')[2].split('.')[0];
                  payments.setAwaitingTime('0$hour:$minute:$second');
                },
              );
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var payments = Provider.of<Payments>(context, listen: true);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                if (_timerForOrderUpdate != null) {
                                  _timerForOrderUpdate!.cancel();
                                  if (_currentTransaction['status'] ==
                                      'PROCESSING') {
                                    showAlert(
                                      context,
                                      Icon(
                                        Icons.warning,
                                        color: warningColor,
                                      ),
                                      'Are you sure?',
                                      [
                                        Text('You have a pending transaction.'),
                                      ],
                                      'Cancel Transaction',
                                    );
                                  } else {
                                    Navigator.pop(context);
                                  }
                                } else {
                                  if (_currentTransaction['status'] ==
                                      'PROCESSING') {
                                    showAlert(
                                      context,
                                      Icon(
                                        Icons.warning,
                                        color: warningColor,
                                      ),
                                      'Are you sure?',
                                      [
                                        Text('You have a pending transaction.'),
                                      ],
                                      'Cancel Transaction',
                                    );
                                  } else {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                              child: Icon(Icons.chevron_left),
                            ),
                          ),
                          Text(
                            'Transfer money to prcess with order',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/img/brl.png',
                                width: 25,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 5),
                              child: Text(
                                'BRL',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Text(
                            //   'Brazilian Real',
                            //   style: TextStyle(
                            //     fontSize: 12,
                            //     fontWeight: FontWeight.normal,
                            //     color: secondaryTextColor,
                            //   ),
                            // ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            'R\$ ${payments.transactionValue}',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        payments.getTxDetails.isNotEmpty
                            ? Container(
                                padding: EdgeInsets.only(top: 5),
                                width: width,
                                child: Card(
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            'Bank Details',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                      Divider(),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Merchant Name',
                                              style: TextStyle(
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(right: 5),
                                                  child: Text(
                                                    '${payments.getTxDetails['merchantName']}',
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Clipboard.setData(
                                                      ClipboardData(
                                                        text:
                                                            '${payments.getTxDetails['merchantName']}',
                                                      ),
                                                    );
                                                    snackAlert(
                                                        context,
                                                        SnackTypes.success,
                                                        'Copied');
                                                  },
                                                  child: Icon(
                                                    Icons.copy,
                                                    size: 16,
                                                    color: secondaryTextColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Merchant City',
                                              style: TextStyle(
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(right: 5),
                                                  child: Text(
                                                    '${payments.getTxDetails['merchantCity']}',
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Clipboard.setData(
                                                      ClipboardData(
                                                        text:
                                                            '${payments.getTxDetails['merchantCity']}',
                                                      ),
                                                    );
                                                    snackAlert(
                                                        context,
                                                        SnackTypes.success,
                                                        'Copied');
                                                  },
                                                  child: Icon(
                                                    Icons.copy,
                                                    size: 16,
                                                    color: secondaryTextColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Country Code',
                                              style: TextStyle(
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(right: 5),
                                                  child: Text(
                                                    '${payments.getTxDetails['countryCode']}',
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Clipboard.setData(
                                                      ClipboardData(
                                                        text:
                                                            '${payments.getTxDetails['countryCode']}',
                                                      ),
                                                    );
                                                    snackAlert(
                                                        context,
                                                        SnackTypes.success,
                                                        'Copied');
                                                  },
                                                  child: Icon(
                                                    Icons.copy,
                                                    size: 16,
                                                    color: secondaryTextColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Transaction ID',
                                              style: TextStyle(
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(right: 5),
                                                  child: Text(
                                                    '${payments.getTxDetails['txid']}',
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Clipboard.setData(
                                                      ClipboardData(
                                                        text:
                                                            '${payments.getTxDetails['txid']}',
                                                      ),
                                                    );
                                                    snackAlert(
                                                        context,
                                                        SnackTypes.success,
                                                        'Copied');
                                                  },
                                                  child: Icon(
                                                    Icons.copy,
                                                    size: 16,
                                                    color: secondaryTextColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          width: width,
                          child: Card(
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0),
                                    border: Border.all(
                                      style: BorderStyle.solid,
                                      width: 1,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  child: SizedBox(
                                    width: width * 0.4,
                                    height: width * 0.4,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: QrImage(
                                        data: utf8.decode(
                                          base64.decode(payments
                                              .pixNewTransaction['qr_code']),
                                        ),
                                        version: QrVersions.auto,
                                        backgroundColor: Colors.white,
                                        size: 150.0,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text:
                                            '${payments.pixNewTransaction['qr_code']}',
                                      ),
                                    );
                                    snackAlert(
                                        context, SnackTypes.success, 'Copied');
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(right: 10),
                                          child: Text('PIX QR Code'),
                                        ),
                                        Icon(
                                          Icons.copy,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          width: width,
                          child: Card(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: 5),
                                  width: 50,
                                  height: 50,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: _currentTransaction['status'] ==
                                            'ACCEPTED'
                                        ? Image.asset(
                                            'assets/img/approved.png',
                                            width: 50,
                                          )
                                        : _currentTransaction['status'] ==
                                                'CHARGEBACK'
                                            ? Image.asset(
                                                'assets/img/rejected.png',
                                                width: 50,
                                              )
                                            : Icon(
                                                Icons.timer,
                                                color: warningColor,
                                                size: 40,
                                              ),
                                  ),
                                ),
                                _currentTransaction['status'] == 'ACCEPTED'
                                    ? Container(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          'Payment Successfull',
                                          style: TextStyle(
                                            color: greenIndicator,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : _currentTransaction['status'] ==
                                            'CHARGEBACK'
                                        ? Container(
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              'Rejected',
                                              style: TextStyle(
                                                color: errorColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              'Waiting for payment',
                                              style: TextStyle(
                                                color: warningColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                _currentTransaction['status'] == 'PROCESSING'
                                    ? Container(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          payments.awaitingTime,
                                          style: TextStyle(
                                            color: linkColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            'Go Back',
                                            style: TextStyle(
                                              color: linkColor,
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
