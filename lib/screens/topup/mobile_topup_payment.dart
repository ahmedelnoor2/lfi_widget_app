import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/dex_provider.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/providers/topup.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/dex_swap/common/exchange_now.dart';
import 'package:lyotrade/utils/Coins.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:provider/provider.dart';

class MobileTopup extends StatefulWidget {
  static const routeName = '/mobile_topup';
  MobileTopup(
      {Key? key,
      this.number,
      this.amount,
      this.defaultcoin,
      this.countrycode,
      this.operatorid,
      this.topupamount})
      : super(key: key);

  String? number;
  var amount;
  final defaultcoin;
  final countrycode;
  final operatorid;
  final topupamount;

  @override
  State<MobileTopup> createState() => _MobileTopupState();
}

class _MobileTopupState extends State<MobileTopup> {
  final _formKey = GlobalKey<FormState>();
  final _optcontroller = TextEditingController();
  final _googlecodecontroller = TextEditingController();
  bool _startTimer = false;
  late Timer _timer;
  int _start = 90;
  bool withdrwalResponse = false;
  @override
  void initState() {
    super.initState();

    changeverifystatus();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  void startTimer(coin) {
    setState(() {
      _startTimer = true;
    });
    optVerify(coin);
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

  Future changeverifystatus() async {
    var topupProvider = Provider.of<TopupProvider>(context, listen: false);
    topupProvider.setverify(false);
    topupProvider.setgoolgeCode(false);
    topupProvider.paymentstatus = 'Waiting for payment';
  }

  Future<void> optVerify(coin) async {
    var topupProvider = Provider.of<TopupProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    var userid = await auth.userInfo['id'];

    await topupProvider.getDoVerify(context, auth, userid, {
      "address": asset.changeAddress['addressStr'],
      "symbol": '$coin',
      "verificationType": auth.userInfo['email'].isNotEmpty ? '17' : '4'
    });
  }

  Future<void> withDrawal(coin, amount, verifitypre) async {
    var topupProvider = Provider.of<TopupProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    var userid = await auth.userInfo['id'];

    withdrwalResponse =
        await topupProvider.getDoWithDrawal(context, auth, userid, {
      "symbol": '$coin',
      "fee": '${asset.getCost['defaultFee']}',
      "amount": amount.toStringAsPrecision(5),
      "verificationType": "$verifitypre",
      "emailValidCode":
          verifitypre == 'emailValidCode' ? _optcontroller.text : "",
      "smsValidCode": verifitypre == 'smsValidCode' ? _optcontroller.text : "",
      "googleCode": _googlecodecontroller.text
    });
  }

  Future<void> dotransaction(
      amount, operatorid, countrycode, number, topupamount) async {
    var topupProvider = Provider.of<TopupProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    if (withdrwalResponse == true) {
      await topupProvider.getDoTransaction(context, auth, userid, {
        "amount": "$topupamount",
        "operatorId": "$operatorid",
        "recipientPhone": {
          "countryCode": "$countrycode",
          "number": topupProvider.toActiveCountry['callingCodes'][0] + number
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    var topupProvider = Provider.of<TopupProvider>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);
    final args = ModalRoute.of(context)!.settings.arguments as MobileTopup;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.chevron_left),
          ),
          title: Text(
            'Mobile Topup',
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 10,
                ),
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  topupProvider.paymentstatus == 'Waiting for payment'
                      ? 'Waiting for payment'
                      : topupProvider.paymentstatus == 'Card is Processing'
                          ? 'Card is Processing'
                          : topupProvider.paymentstatus == 'Completed'
                              ? 'Completed'
                              : topupProvider.paymentstatus ==
                                      'Failed to process Top Up, Please Contact Admin.'
                                  ? 'Failed to process a Top Up, Please Contact Admin.'
                                  : 'Waiting for payment',
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 8, right: 16, bottom: 15),
                child: Stack(
                  children: [
                    Container(
                      width: width,
                      height: 16,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 0.5),
                          color: Colors.white),
                      child: Container(),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 0.5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        child: Container(
                          width: topupProvider.paymentstatus ==
                                  'Waiting for payment'
                              ? width * 0.3
                              : topupProvider.paymentstatus ==
                                      'Card is Processing'
                                  ? width * 0.5
                                  : topupProvider.paymentstatus == 'Completed'
                                      ? width * 1.0
                                      : topupProvider.paymentstatus ==
                                              'Failed to process a Gift Card, Please Contact Admin.'
                                          ? width * 0.0
                                          : width * 0.3,
                          // width: dexPro

                          height: 15,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.green.shade500,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.only(top: 20, bottom: 5),
                        child: Text(
                          '${double.parse(args.amount.toString()).toStringAsPrecision(5)}' +
                              ' USDT',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        )),
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Withdrawal Fee:' +
                            '${asset.getCost['defaultFee'] ?? ''}',
                        style: TextStyle(color: warningColor),
                      ),
                    )
                  ],
                ),
              ),
              Card(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          'Mobile Number',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            Text(topupProvider.toActiveCountry['callingCodes']
                                    [0] +
                                ''.toString()),
                            Text(
                              '${args.number}',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              topupProvider.paymentstatus == 'Completed'
                  ? Column(
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/img/approved.png',
                            width: 180,
                          ),
                        ),
                        Text(
                          'Completed',
                          style: TextStyle(color: successColor),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: width * 0.45,
                              padding:
                                  EdgeInsets.only(top: 20, right: 4, left: 4),
                              child: LyoButton(
                                onPressed: (() async {
                                  Navigator.pop(context);
                                }),
                                text: 'Back',
                                active: true,
                                isLoading: topupProvider.iswithdrwal,
                                activeColor: linkColor,
                                activeTextColor: Colors.black,
                              ),
                            ),
                            Container(
                              width: width * 0.45,
                              padding:
                                  EdgeInsets.only(top: 20, right: 4, left: 4),
                              child: LyoButton(
                                onPressed: (() async {
                                  Navigator.pushNamed(
                                      context, '/topup_transaction');
                                }),
                                text: 'Transactions',
                                active: true,
                                isLoading: topupProvider.iswithdrwal,
                                activeColor: linkColor,
                                activeTextColor: Colors.black,
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  : topupProvider.paymentstatus ==
                          'Failed to process a Gift Card, Please Contact Admin.'
                      ? Column(
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/img/rejected.png',
                                width: 180,
                              ),
                            ),
                            Text(
                              'Failed to process a Gift Card, Please Contact Admin.',
                              style: TextStyle(color: Colors.red),
                            ),
                            Container(
                              padding:
                                  EdgeInsets.only(top: 20, right: 4, left: 4),
                              child: LyoButton(
                                onPressed: (() async {
                                  Navigator.pop(context);
                                }),
                                text: 'Back',
                                active: true,
                                isLoading: topupProvider.iswithdrwal,
                                activeColor: linkColor,
                                activeTextColor: Colors.black,
                              ),
                            )
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                ),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                              'Email or Phone Verification code')),
                                      TextFormField(
                                        controller: _optcontroller,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter Verification Code';
                                          }

                                          return null;
                                        },
                                        onChanged: ((value) {}),
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color:
                                                    secondaryTextColor400), //<-- SEE HERE
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: secondaryTextColor400,
                                                width: 0.5),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          hintText:
                                              'Please enter verification code',
                                          suffixIcon: InkWell(
                                            onTap: _startTimer
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _start = 90;
                                                    });
                                                    startTimer(
                                                        args.defaultcoin);
                                                  },
                                            child: Container(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 15,
                                                  right: 10,
                                                ),
                                                child: Text(_startTimer
                                                    ? '${_start}s Get it again'
                                                    : 'Click to send'),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // errorText: _errorText,
                                      ),
                                      topupProvider.isgoogleCode == true
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10, top: 10),
                                                    child: Text(
                                                        'Google authenticator code')),
                                                TextFormField(
                                                  controller:
                                                      _googlecodecontroller,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please Enter Google Authenticator Code';
                                                    }

                                                    return null;
                                                  },
                                                  onChanged: ((value) {}),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          width: 0.5,
                                                          color:
                                                              secondaryTextColor400), //<-- SEE HERE
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              secondaryTextColor400,
                                                          width: 0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    hintText:
                                                        'Please enter google authenticator code',

                                                    // errorText: _errorText,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                                topupProvider.isverify == true
                                    ? Container(
                                        padding: EdgeInsets.only(
                                          top: 35,
                                        ),
                                        child: LyoButton(
                                          onPressed: (() async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              await withDrawal(
                                                  args.defaultcoin,
                                                  args.amount,
                                                  topupProvider.doverify[
                                                      'verificationType']);

                                              await dotransaction(
                                                  args.amount,
                                                  args.operatorid,
                                                  args.countrycode,
                                                  args.number,
                                                  args.topupamount);
                                            }
                                          }),
                                          text: 'Buy Now',
                                          active: true,
                                          isLoading: topupProvider.iswithdrwal,
                                          activeColor: linkColor,
                                          activeTextColor: Colors.black,
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ),
            ],
          ),
        ));
  }
}
