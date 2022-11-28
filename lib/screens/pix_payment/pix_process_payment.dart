import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:http/http.dart';
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
    getdetailinfo();
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
        getdetailinfo();
      },
    );
  }

  Future<void> getdetailinfo() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var payments = Provider.of<Payments>(context, listen: false);

    await payments.getPixDetailInfo(auth, payments.pixCreateOrder['id']);

    if (payments.pixdetail.isNotEmpty) {
      //   for (var transaction in payments.allPixTransactions) {
      //     if (transaction['uuid_transaction'] ==
      //         payments.pixNewTransaction['uuid_transaction']) {
      //       setState(() {
      //         _currentTransaction = transaction;
      //       });
      //       if (_timer == null) {
      //         payments.decryptPixQR({"qr_code": transaction['qr_code']});
      //         setState(() {
      //           _timer = Timer.periodic(
      //             const Duration(seconds: 1),
      //             (Timer timer) {
      //               final nowDate = DateTime.now().toLocal();
      //               var endDate = DateTime.parse(transaction['date_end'])
      //                   .toLocal()
      //                   .add(Duration(
      //                       hours: int.parse(nowDate.timeZoneOffset
      //                           .toString()
      //                           .split(":")[0])));
      //               final difference = nowDate.difference(endDate).toString();
      //               final hour =
      //                   difference.split(':')[0].replaceAll(RegExp('-'), '');
      //               final minute = difference.split(':')[1];
      //               final second = difference.split(':')[2].split('.')[0];
      //               payments.setAwaitingTime('0$hour:$minute:$second');
      //             },
      //           );
      //         });
      //       }
      //     }
      //   }
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    var payments = Provider.of<Payments>(context, listen: true);
    var getPortugeseTrans = payments.getPortugeseTrans;
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
                                  if (payments.pixdetail['status'] == '0') {
                                    showAlert(
                                      context,
                                      Icon(
                                        Icons.warning,
                                        color: warningColor,
                                      ),
                                      'Are you sure?',
                                      [
                                        Text(getPortugeseTrans(
                                            'You have a pending transaction')),
                                      ],
                                      'Cancel Transaction',
                                    );
                                  } else {
                                    Navigator.pop(context);
                                  }
                                } else {
                                  if (payments.pixdetail['status'] == '0') {
                                    showAlert(
                                      context,
                                      Icon(
                                        Icons.warning,
                                        color: warningColor,
                                      ),
                                      'Are you sure?',
                                      [
                                        Text(getPortugeseTrans(
                                            "You have a pending transaction")),
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
                            getPortugeseTrans(
                                'Transfer money to process with order'),
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
                            Text(
                              'Brazilian Real',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            'R\$ ${payments.pixdetail['brlAmount'] ?? ''}',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        payments.pixdetail.isEmpty
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
                                            getPortugeseTrans('Bank Details'),
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
                                              getPortugeseTrans('amount'),
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
                                                    '${payments.pixdetail['amount'] ?? payments.pixdetail['settledAmount']}',
                                                  ),
                                                ),
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
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                getPortugeseTrans(
                                                    'Transaction ID'),
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Wrap(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        right: 5),
                                                    child: Text(
                                                      '${payments.pixdetail['uuidTransaction'] ?? ''}',
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                              getPortugeseTrans('Brl Rate'),
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
                                                      '${payments.pixdetail['brlRate'] ?? ''} BRL'),
                                                ),
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
                                          base64.decode(
                                              payments.pixdetail['qrCode'] ??
                                                  ''),
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
                                        text: utf8.decode(
                                          base64.decode(
                                              payments.pixdetail['qrCode']),
                                        ),
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
                                          child: Text(
                                              getPortugeseTrans('PIX QR Code')),
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
                                      child: payments.pixdetail['status'] == '1'
                                          ? Image.asset(
                                              'assets/img/approved.png',
                                              width: 50,
                                            )
                                          : payments.pixdetail['status'] == '0'
                                              ? Icon(
                                                  Icons.timer,
                                                  color: warningColor,
                                                  size: 40,
                                                )
                                              : Icon(
                                                  Icons.timer,
                                                  color: warningColor,
                                                  size: 40,
                                                )),
                                ),
                                payments.pixdetail['status'] == '1'
                                    ? Container(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          getPortugeseTrans(
                                              'Payment Successfull'),
                                          style: TextStyle(
                                            color: greenIndicator,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : _currentTransaction['status'] == '0'
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
                                        : Container(
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              getPortugeseTrans(
                                                  'Waiting for payment'),
                                              style: TextStyle(
                                                color: warningColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
