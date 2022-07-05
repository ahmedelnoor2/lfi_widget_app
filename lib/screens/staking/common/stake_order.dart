import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/staking.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class StakeOrder extends StatefulWidget {
  static const routeName = '/stake_order';
  const StakeOrder({Key? key}) : super(key: key);

  @override
  State<StakeOrder> createState() => _StakeOrderState();
}

class _StakeOrderState extends State<StakeOrder> {
  final _formStakeKey = GlobalKey<FormState>();
  final TextEditingController _authCodeController = TextEditingController();

  List _totalAccounts = [];
  Map _currentAccount = {};

  late Timer _timerSecur;
  int _startSecur = 90;
  bool _startTimerSecur = false;

  @override
  void initState() {
    getOrderDetails();
    super.initState();
  }

  @override
  void dispose() async {
    _authCodeController.dispose();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _startTimerSecur = true;
    });

    sendVerificationCode();
    const oneSecSecur = Duration(seconds: 1);
    _timerSecur = Timer.periodic(
      oneSecSecur,
      (Timer timer) {
        if (_startSecur == 0) {
          setState(() {
            setState(() {
              _startTimerSecur = false;
            });
            _timerSecur.cancel();
          });
        } else {
          setState(() {
            _startSecur--;
          });
        }
      },
    );
  }

  Future<void> sendVerificationCode() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.sendMobileValidCode(context, {
      "operationType": 15,
      "code": "",
      "mobile": "",
      "smsType": "0",
    });
  }

  Future<void> getOrderDetails() async {
    var staking = Provider.of<Staking>(context, listen: false);

    await staking.getOrderDetails(
      context,
      {
        'orderNum': staking.activeStakingOrder['orderNum'],
        'appKey': staking.activeStakingOrder['appKey'],
      },
    );

    List _totalStakeAccounts =
        json.decode(staking.stakeOrderData['totalAccount']);
    setState(() {
      _totalAccounts = _totalStakeAccounts;
      _currentAccount = _totalStakeAccounts[0];
    });
  }

  Future<void> payStakeOrder() async {
    var staking = Provider.of<Staking>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);

    await staking.payStakeOrder(
      context,
      {
        'appKey': staking.stakeOrderData["appKey"],
        'assetType': _currentAccount['accountType'],
        'googleCode': _authCodeController.text,
        'orderNum': staking.stakeOrderData["orderNum"],
        'smsAuthCode': "",
        'userId': staking.stakeOrderData["userId"],
      },
    );
    await public.getStakeLists();
  }

  Future<void> processStakeOrder() async {
    var staking = Provider.of<Staking>(context, listen: false);

    if (staking.stakeOrderData['googleStatus'] == "1") {
      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return _verifyAuth(
                context,
                staking.stakeOrderData,
                setState,
              );
            },
          );
        },
      );
    } else if (staking.stakeOrderData['isOpenMobileCheck'] == "1") {
      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return _verifyAuth(
                context,
                staking.stakeOrderData,
                setState,
              );
            },
          );
        },
      );
    } else {
      snackAlert(
        context,
        SnackTypes.warning,
        'You need to enable Google Auth or SMS verification',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    var staking = Provider.of<Staking>(context, listen: true);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 20),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.chevron_left),
                      ),
                    ),
                    Text(
                      'Payment Confirmation',
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
              width: width,
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  // Container(
                  //   padding: EdgeInsets.only(right: 10),
                  //   child: Image.network(
                  //     '${public.publicInfoMarket['market']['coinList'][staking.stakeOrderData['payCoinSymbol']]['icon']}',
                  //   ),
                  // ),
                  Text(
                    '${staking.stakeOrderData['showName']}',
                    style: TextStyle(fontSize: 20),
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
                  Text(
                    'Order ID:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '${staking.stakeOrderData['orderNum']}',
                    style: TextStyle(fontSize: 15, color: linkColor),
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
                  Text(
                    'Beneficiary:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'LYOTRADE',
                    style: TextStyle(fontSize: 15, color: linkColor),
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
                  Text(
                    'Payment cost:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '${staking.stakeOrderData['orderAmount']} ${staking.stakeOrderData['showName']}',
                    style: TextStyle(fontSize: 15, color: linkColor),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                bottom: 10,
                top: 10,
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return selectAccount(context);
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: 0.3,
                          color: Color(0xff5E6292),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 5),
                                child: Text(
                                  '${_currentAccount['accountName'] ?? '--'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 5, left: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Availalbe',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  Text(
                    '${double.parse(_currentAccount['accountBalance'] ?? '0').toStringAsFixed(2)} ${staking.stakeOrderData['showName']}',
                  ),
                ],
              ),
            ),
            LyoButton(
              onPressed: () {
                processStakeOrder();
              },
              text: 'Confrim',
              active: true,
              activeColor: linkColor,
              activeTextColor: Colors.black,
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget selectAccount(context) {
    width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(10),
      height: height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
              )
            ],
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _totalAccounts.length,
            itemBuilder: (BuildContext context, int index) {
              var account = _totalAccounts[index];

              return ListTile(
                onTap: () {
                  setState(() {
                    _currentAccount = account;
                  });
                  Navigator.pop(context);
                },
                title: Text('${account['accountName']}'),
                trailing: Icon(
                  Icons.check,
                  color:
                      _currentAccount['accountType'] == account['accountType']
                          ? greenIndicator
                          : secondaryTextColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _verifyAuth(context, stakeOrderData, setState) {
    return Container(
      padding: EdgeInsets.all(10),
      height: height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Authentication',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
              )
            ],
          ),
          Form(
            key: _formStakeKey,
            child: Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.only(top: 15, bottom: 15, left: 15),
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
                          return 'Please enter verification code';
                        }
                        return null;
                      },
                      controller: _authCodeController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: stakeOrderData['googleStatus'] == "1"
                            ? 'Google verification code'
                            : 'SMS verification code',
                      ),
                    ),
                  ),
                  stakeOrderData['googleStatus'] == "1"
                      ? Container(
                          padding: EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () async {
                              ClipboardData? data = await Clipboard.getData(
                                Clipboard.kTextPlain,
                              );
                              _authCodeController.text = '${data!.text}';
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
                      : Container(
                          padding: EdgeInsets.only(right: 10),
                          child: TextButton(
                            onPressed: _startTimerSecur
                                ? null
                                : () {
                                    setState(() {
                                      _startSecur = 90;
                                    });
                                    startTimer();
                                  },
                            child: Text(_startTimerSecur
                                ? '${_startSecur}s Get it again'
                                : 'Click to send'),
                          ),
                        ),
                ],
              ),
            ),
          ),
          LyoButton(
            onPressed: () {
              if (_formStakeKey.currentState!.validate()) {
                payStakeOrder();
              }
            },
            text: 'Pay',
            active: true,
            activeColor: linkColor,
            activeTextColor: Colors.black,
            isLoading: false,
          )
        ],
      ),
    );
  }
}
