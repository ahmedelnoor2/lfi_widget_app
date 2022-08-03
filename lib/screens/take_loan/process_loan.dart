import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:lyotrade/providers/loan_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ProcessLoan extends StatefulWidget {
  static const routeName = '/process_loan';
  const ProcessLoan({Key? key}) : super(key: key);

  @override
  State<ProcessLoan> createState() => _ProcessLoanState();
}

class _ProcessLoanState extends State<ProcessLoan>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _loadingLoanDetails = true;
  var _channel;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    getLoanInformation();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    if (_channel != null) {
      _channel.sink.close();
    }
  }

  Future<void> getLoanInformation() async {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);
    print(loanProvider.loanid);
    _channel = WebSocketChannel.connect(
      Uri.parse(
          'wss://api.dash.lyotrade.com:5001/?loanid=${loanProvider.loanid}'),
    );

    _channel.stream.listen((message) {
      extractStreamData(message, loanProvider);
    });
  }

  void extractStreamData(streamData, loanProvider) async {
    if (streamData != null) {
      var data = jsonDecode(streamData);
      if (data != null) {
        if (data['data'] != null) {
          if (data['data']['result']) {
            loanProvider.setLoanDetails(data['data']['response']['response']);
            setState(() {
              _loadingLoanDetails = false;
            });
          }
        }
      }
      // if (data['data']['result']) {
      // }
    }
  }

  double getPercentage(value) {
    double _width = 0.0;
    switch (value) {
      case 'confirmed':
        _width = 0.25;
        break;
      case 'new':
        _width = 0.25;
        break;
      case 'deposit_received':
        _width = 0.50;
        break;
      case 'transaction_sent':
        _width = 0.75;
        break;
      case 'order_created':
        _width = 1;
        break;
      default:
        _width = 0;
        break;
    }
    return _width;
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var loanProvider = Provider.of<LoanProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: hiddenAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.chevron_left),
                        ),
                      ),
                      Text(
                        'Get your loan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            _loadingLoanDetails
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Text(
                            'Please use your wallet to send us deposit for your loan',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                style: BorderStyle.solid,
                                width: 0.3,
                                color: Colors.white,
                              ),
                            ),
                            child: QrImage(
                              data: '',
                              version: QrVersions.auto,
                              backgroundColor: Colors.white,
                              size: 125,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Send Deposit',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                      '${loanProvider.loanDetails['deposit']['expected_amount']} ${loanProvider.loanDetails['deposit']['currency_code']}'),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Collateral remaining to be send',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                      '${loanProvider.loanDetails['deposit']['expected_amount']} ${loanProvider.loanDetails['deposit']['currency_code']}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: width,
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  'To this ${loanProvider.loanDetails['deposit']['currency_code']} address ${loanProvider.loanDetails['deposit']['currency_network']} network',
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text:
                                          '${loanProvider.loanDetails['deposit']['send_address']}',
                                    ),
                                  );
                                  snackAlert(
                                    context,
                                    SnackTypes.success,
                                    'Copied',
                                  );
                                },
                                child: SizedBox(
                                  width: width,
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Color(0xff292B4B),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        style: BorderStyle.solid,
                                        width: 0.3,
                                        color: Color(0xff292B4B),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            '${loanProvider.loanDetails['deposit']['send_address']}'),
                                        Icon(
                                          Icons.copy,
                                          size: 18,
                                          color: linkColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Awaiting Collateral',
                                    style: TextStyle(
                                      color: (loanProvider
                                                      .loanDetails['status'] ==
                                                  "confirmed" ||
                                              loanProvider
                                                      .loanDetails['status'] ==
                                                  "new")
                                          ? linkColor
                                          : secondaryTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Processing',
                                    style: TextStyle(
                                      color:
                                          (loanProvider.loanDetails['status'] ==
                                                  "deposit_received")
                                              ? linkColor
                                              : secondaryTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Sending Loan',
                                    style: TextStyle(
                                      color:
                                          (loanProvider.loanDetails['status'] ==
                                                  "transaction_sent")
                                              ? linkColor
                                              : secondaryTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Success',
                                    style: TextStyle(
                                      color: (loanProvider
                                                      .loanDetails['status'] ==
                                                  "order_created" &&
                                              loanProvider
                                                      .loanDetails['status'] ==
                                                  "confirmed")
                                          ? linkColor
                                          : secondaryTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 10, bottom: 20),
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Color(0xff282A57),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            style: BorderStyle.solid,
                                            width: 0.1,
                                            color: Color(0xff282A57),
                                          ),
                                        ),
                                        child: Container(),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Container(
                                        width: width *
                                            getPercentage(
                                              loanProvider
                                                  .loanDetails['status'],
                                            ),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: linkColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            style: BorderStyle.solid,
                                            width: 0.1,
                                            color: linkColor,
                                          ),
                                        ),
                                        child: Container(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        (loanProvider.loanDetails['status'] == 'liquidated' ||
                                loanProvider.loanDetails['status'] == 'closed')
                            ? Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/img/rejected.png',
                                      width: 50,
                                    ),
                                    Container(
                                      child: Text(
                                        'Loan ${loanProvider.loanDetails['status']}',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        Container(
                          padding: EdgeInsets.all(10),
                          width: width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You get:',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${loanProvider.loanDetails['loan']['expected_amount']} ${loanProvider.loanDetails['loan']['currency_code']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          width: width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To your ${loanProvider.loanDetails['loan']['currency_code']} - ${loanProvider.loanDetails['loan']['currency_network']} wallet:',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${loanProvider.loanDetails['loan']['expected_amount']} ${loanProvider.loanDetails['loan']['currency_code']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xff373965),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                style: BorderStyle.solid,
                                width: 0.3,
                                color: Color(0xff373965),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: CircleAvatar(
                                    backgroundColor: Color(0xff282A57),
                                    child: Image.asset(
                                      'assets/img/loan_message.png',
                                      width: 20,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                      'We will notify to your email when the loan will be sent to you',
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
      ),
    );
  }
}
