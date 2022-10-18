import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

import '../../../utils/AppConstant.utils.dart';

class dexBottimSheet extends StatefulWidget {
  dexBottimSheet(
    this.fromAmount,
    this.paymentAddress,
    this.symbol,
     {
    Key? key,
  }) : super(key: key);
  final fromAmount;
  final paymentAddress;
  final symbol;
  @override
  State<dexBottimSheet> createState() => _dexBottimSheetState();
}

class _dexBottimSheetState extends State<dexBottimSheet> {
  final _formEmailVeriKey = GlobalKey<FormState>();

  final TextEditingController _emailVeirficationCode = TextEditingController();
  final TextEditingController _smsVeirficationCode = TextEditingController();
  final TextEditingController _googleVeirficationCode = TextEditingController();
  late Timer _timer;
  bool _startTimer = false;
  int _start = 90;

  late Timer _timerSms;
  int _startSms = 90;
  bool _startTimerSms = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailVeirficationCode.dispose();
    _smsVeirficationCode.dispose();
    _googleVeirficationCode.dispose();
  }

  void startTimer() {
    setState(() {
      _startTimer = true;
    });
    sendVerificationCode();
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _startTimer = false;
            _timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void startMobileTimer() {
    setState(() {
      _startTimerSms = true;
    });

    sendSmsVerificationCode();
    const oneSec = Duration(seconds: 1);
    _timerSms = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _startTimerSms = false;
            _timerSms.cancel();
          });
        } else {
          setState(() {
            _startSms--;
          });
        }
      },
    );
  }

  Future<void> sendSmsVerificationCode() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.sendMobileValidCode(context, {
      'token': '',
      'operationType': '10',
      'smsType': '0',
    });
  }

  Future<void> sendVerificationCode() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.sendEmailValidCode(context, {
      'token': '',
      'email': '',
      'operationType': '17',
    });
  }

  Future<void> processWithdrawAmount() async {
    // setState(() {
    //   _validateEmailProcess = false;
    //   _verifyAddress = true;
    // });
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    var _postData = {
      "address": widget.paymentAddress,
      "addressId": "",
      "amount": widget.fromAmount,
      "emailValidCode": _emailVeirficationCode.text,
      "fee": '20.3',
      "googleCode": _googleVeirficationCode.text,
      "symbol": widget.symbol,
      "trustType": 0,
    };
    print(_postData);
    if (auth.userInfo['mobileNumber'].isNotEmpty) {
      _postData['smsValidCode'] = _smsVeirficationCode.text;
    }

  await   asset.processWithdrawal(context, auth, _postData);
    // getDigitalBalance();
    // setState(() {
    //   _addressController.clear();
    //   _amountController.clear();
    //   _verifyAddress = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    return Form(
      key: _formEmailVeriKey,
      child: Wrap(
        children: [
          Container(
            height: height,
            padding: EdgeInsets.only(
              top: 10,
              right: 10,
              left: 10,
              bottom: 30,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        size: 20,
                      ),
                    )
                  ],
                ),
                auth.userInfo['email'].isEmpty
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.only(top: 10, bottom: 15, left: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            style: BorderStyle.solid,
                            width: 0.3,
                            color: Color(0xff5E6292),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: width * 0.49,
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Email verification code';
                                  }
                                  return null;
                                },
                                controller: _emailVeirficationCode,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                  ),
                                  hintText: 'Email verification code',
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: TextButton(
                                onPressed: _startTimer
                                    ? null
                                    : () {
                                        setState(() {
                                          _start = 90;
                                        });
                                        startTimer();
                                      },
                                child: Text(_startTimer
                                    ? '${_start}s Get it again'
                                    : 'Click to send'),
                              ),
                            ),
                          ],
                        ),
                      ),
                auth.userInfo['mobileNumber'].isEmpty
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.only(top: 10, bottom: 15, left: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            style: BorderStyle.solid,
                            width: 0.3,
                            color: Color(0xff5E6292),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: width * 0.49,
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter SMS verification code';
                                  }
                                  return null;
                                },
                                controller: _smsVeirficationCode,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                  ),
                                  hintText: 'SMS verification code',
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: TextButton(
                                onPressed: _startTimerSms
                                    ? null
                                    : () {
                                        setState(() {
                                          _startSms = 90;
                                        });
                                        startMobileTimer();
                                      },
                                child: Text(_startTimerSms
                                    ? '${_startSms}s Get it again'
                                    : 'Click to send'),
                              ),
                            ),
                          ],
                        ),
                      ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.only(top: 10, bottom: 15, left: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      style: BorderStyle.solid,
                      width: 0.3,
                      color: Color(0xff5E6292),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: width * 0.49,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter google verification code';
                            }
                            return null;
                          },
                          controller: _googleVeirficationCode,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: TextStyle(
                              fontSize: 14,
                            ),
                            hintText: 'Google verification code',
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () async {
                            ClipboardData? data = await Clipboard.getData(
                              Clipboard.kTextPlain,
                            );
                            _googleVeirficationCode.text = '${data!.text}';
                          },
                          child: Text(
                            'Paste',
                            style: TextStyle(
                              fontSize: 14,
                              color: linkColor,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: LyoButton(
                    text: 'Send',
                    active: true,
                    isLoading: false,
                    activeColor: linkColor,
                    activeTextColor: Colors.black,
                    onPressed: () async {
                      if (_formEmailVeriKey.currentState!.validate()) {
                        // if (!auth.googleAuth) {
                        //   _timer.cancel();
                        // }
                       Navigator.pop(context);
                        processWithdrawAmount();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
