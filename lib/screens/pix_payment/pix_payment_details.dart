import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PixPaymentDetails extends StatefulWidget {
  static const routeName = '/pix_payment_details';
  const PixPaymentDetails({Key? key}) : super(key: key);

  @override
  State<PixPaymentDetails> createState() => _PixPaymentDetailsState();
}

class _PixPaymentDetailsState extends State<PixPaymentDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Timer? _timer;
  Timer? _timerForOrderUpdate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    getUserDetails();
    startOrderCheckTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
    if (_timerForOrderUpdate != null) {
      _timerForOrderUpdate!.cancel();
    }
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
            payments.selectedTransaction['uuid_transaction']) {
          await payments.setSelectedTransaction(transaction);
          if (_timer == null) {
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
    var getPortugeseTrans = payments.getPortugeseTrans;

    return Scaffold(
      appBar: hiddenAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
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
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.chevron_left),
                        ),
                      ),
                      Text(
                        getPortugeseTrans('Transaction Details'),
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
                        'R\$ ${payments.selectedTransaction['value']}',
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
                                          getPortugeseTrans('Merchant Name'),
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                        Wrap(
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
                                                    getPortugeseTrans(
                                                        'Copied'));
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
                                          getPortugeseTrans('Merchant City'),
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
                                                    getPortugeseTrans(
                                                        'Copied'));
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
                                          getPortugeseTrans('Country Code'),
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
                                                    getPortugeseTrans(
                                                        'Copied'));
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
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            getPortugeseTrans('Transaction ID'),
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
                                                      getPortugeseTrans(
                                                          'Copied'));
                                                },
                                                child: Icon(
                                                  Icons.copy,
                                                  size: 16,
                                                  color: secondaryTextColor,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet<void>(
                                        useRootNavigator: true,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(25.0),
                                          ),
                                        ),
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(
                                            builder: (BuildContext context,
                                                StateSetter setState) {
                                              return Container(
                                                padding: EdgeInsets.only(
                                                    right: 10, left: 10),
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      bottom: 30),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Network Fee',
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                              if (_timer !=
                                                                  null) {
                                                                _timer!
                                                                    .cancel();
                                                              }
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            icon: Icon(
                                                              Icons.close,
                                                              size: 20,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10),
                                                        child: Text(
                                                          'During transfering USDT to your wallet there will be a network fee charged between 1.2 USDT to 20.2 USDT, which depends directly on blockchain network',
                                                          style: TextStyle(
                                                              color:
                                                                  warningColor),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            getPortugeseTrans('Network Fee:'),
                                            style: TextStyle(
                                              color: warningColor,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    EdgeInsets.only(right: 5),
                                                child: Text(
                                                  '1.2 USDT - 20.2 USDT',
                                                  style: TextStyle(
                                                    color: warningColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
                                              .selectedTransaction.isNotEmpty
                                          ? payments
                                              .selectedTransaction['qr_code']
                                          : payments
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
                                    text: utf8.decode(
                                      base64.decode(payments
                                              .selectedTransaction.isNotEmpty
                                          ? payments
                                              .selectedTransaction['qr_code']
                                          : payments
                                              .pixNewTransaction['qr_code']),
                                    ),
                                  ),
                                );
                                snackAlert(context, SnackTypes.success,
                                    getPortugeseTrans('Copied'));
                              },
                              child: Container(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                child: payments.selectedTransaction['status'] ==
                                        'ACCEPTED'
                                    ? Image.asset(
                                        'assets/img/approved.png',
                                        width: 50,
                                      )
                                    : payments.selectedTransaction['status'] ==
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
                            payments.selectedTransaction['status'] == 'ACCEPTED'
                                ? Container(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      getPortugeseTrans('Payment Successfull'),
                                      style: TextStyle(
                                        color: greenIndicator,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : payments.selectedTransaction['status'] ==
                                        'CHARGEBACK'
                                    ? Container(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          getPortugeseTrans('Rejected'),
                                          style: TextStyle(
                                            color: errorColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          getPortugeseTrans(
                                              'Waiting for payment'),
                                          style: TextStyle(
                                            color: warningColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                            payments.selectedTransaction['status'] ==
                                    'PROCESSING'
                                ? payments.selectedTransaction['value'] == 5
                                    ? Container()
                                    : Container(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          payments.awaitingTime,
                                          style: TextStyle(
                                            color: linkColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
