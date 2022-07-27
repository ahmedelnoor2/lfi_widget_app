import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

import 'package:qr_flutter/qr_flutter.dart';

class PixPayment extends StatefulWidget {
  static const routeName = '/pix_payment';
  const PixPayment({Key? key}) : super(key: key);

  @override
  State<PixPayment> createState() => _PixPaymentState();
}

class _PixPaymentState extends State<PixPayment>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _formKey = GlobalKey<FormState>();
  final _formAdditinalInformationKey = GlobalKey<FormState>();
  final TextEditingController _amountBrlController = TextEditingController();
  final TextEditingController _amountUsdtController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  Timer? _timer;

  String _name = '';
  String _email = '';
  String _cpf = '';
  Map _fieldErrors = {};
  bool _loading = false;
  bool _processKyc = false;
  bool _processTransaction = false;
  bool _reRequestKYCAuth = false;
  String _sendUsdtAmount = '';
  Map _userAddresses = {};

  String _transactionType = 'bank_transfer';

  @override
  void initState() {
    _amountBrlController.clear();
    _amountUsdtController.clear();
    _nameController.clear();
    _emailController.clear();
    _cpfController.clear();
    getExchangeRate();
    getUserAddress();
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _amountBrlController.dispose();
    _amountUsdtController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> getUserAddress() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    if (auth.isAuthenticated) {
      if (public.publicInfoMarket.isNotEmpty) {
        public.publicInfoMarket['market']['followCoinList']['USDT']
            .forEach((key, value) async {
          await asset.getChangeAddress(context, auth, key);
          setState(() {
            _userAddresses[key] = asset.changeAddress['addressStr'];
          });
        });
      }
    }
  }

  Future<void> getExchangeRate() async {
    setState(() {
      _loading = true;
      _sendUsdtAmount = '';
    });
    var auth = Provider.of<Auth>(context, listen: false);

    var payments = Provider.of<Payments>(context, listen: false);
    await payments.getPixCurrencyExchangeRate({"type": "Dollar"});
    await payments.getPixCurrencyCommissionRate();

    await payments.getKycVerificationDetails({
      'userId': auth.userInfo['id'],
    });
    if (payments.pixKycClients.isEmpty) {
      payments.clearKycTransactions();
    } else {
      if (payments.pixKycClients['activate'] == false) {
        await payments.getKycVerificationTransaction(
          payments.pixKycClients['client_uuid'],
        );

        if (payments.kycTransaction.isNotEmpty) {
          await payments.decryptPixQR({
            "qr_code": payments.kycTransaction['qr_code'],
          });
        }
      }
    }

    setState(() {
      _loading = false;
    });
  }

  void calculateRates(from, value) {
    var payments = Provider.of<Payments>(context, listen: false);
    if (from == 'BRL') {
      if (value.isNotEmpty) {
        setState(() {
          _amountUsdtController.text =
              ((double.parse(value) / payments.pixCurrencyExchange) -
                      ((double.parse(value) / payments.pixCurrencyExchange) *
                          (double.parse('${payments.pixCurrencyCommission}') /
                              100)))
                  .toStringAsFixed(4);
          _sendUsdtAmount =
              ((double.parse(value) / payments.pixCurrencyExchange) +
                      ((double.parse(value) / payments.pixCurrencyExchange) *
                          (double.parse('${payments.pixCurrencyCommission}') /
                              100)))
                  .toStringAsFixed(4);
        });
      } else {
        setState(() {
          _amountUsdtController.clear();
          _sendUsdtAmount = '';
        });
      }
    }

    if (from == 'USDT') {
      if (value.isNotEmpty) {
        setState(() {
          _amountBrlController.text =
              ((double.parse(value) * payments.pixCurrencyExchange) +
                      ((double.parse(value) * payments.pixCurrencyExchange) *
                          (double.parse('${payments.pixCurrencyCommission}') /
                              100)))
                  .toStringAsFixed(2);
          _sendUsdtAmount =
              '${(double.parse('$value') + (double.parse('$value') * (double.parse('${payments.pixCurrencyCommission}') / 100)))}';
        });
      } else {
        setState(() {
          _amountBrlController.clear();
        });
      }
    }
  }

  Future<void> requestKyc() async {
    setState(() {
      _processKyc = true;
      _loading = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var payments = Provider.of<Payments>(context, listen: false);

    await payments.requestKyc(context, {
      "client_id": '${auth.userInfo['id']}',
      "email": _email,
      "cpf":
          '${_cpf.substring(0, 3)}.${_cpf.substring(3, 6)}.${_cpf.substring(6, 9)}-${_cpf.substring(9, 11)}',
      "name": _name,
    });

    if (payments.newKyc.isNotEmpty) {
      await payments.getKycVerificationDetails({
        'userId': '${auth.userInfo['id']}',
      });
      await payments
          .getKycVerificationTransaction(payments.newKyc['client_uuid']);
      Navigator.pop(context);
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
            builder: (BuildContext context, StateSetter setState) {
              return GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: kycInformation(
                  context,
                  setState,
                  0.9,
                ),
              );
            },
          );
        },
      );
    }
    setState(() {
      _processKyc = false;
      _loading = false;
    });
  }

  Future<void> reRequestKyc() async {
    setState(() {
      _processKyc = true;
      _loading = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var payments = Provider.of<Payments>(context, listen: false);

    await payments.reRequestKyc(context, {
      'uuid': payments.pixKycClients['client_uuid'],
      "cpf":
          '${_cpf.substring(0, 3)}.${_cpf.substring(3, 6)}.${_cpf.substring(6, 9)}-${_cpf.substring(9, 11)}',
    });

    if (payments.newKyc.isNotEmpty) {
      await payments.getKycVerificationDetails({
        'userId': '${auth.userInfo['id']}',
      });
      await payments
          .getKycVerificationTransaction(payments.newKyc['client_uuid']);
      Navigator.pop(context);
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
            builder: (BuildContext context, StateSetter setState) {
              return GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: kycInformation(
                  context,
                  setState,
                  0.9,
                ),
              );
            },
          );
        },
      );
    }
    setState(() {
      _processKyc = false;
      _loading = false;
      _reRequestKYCAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);
    var payments = Provider.of<Payments>(context, listen: true);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: hiddenAppBar(),
        body: Container(
          padding: EdgeInsets.all(15),
          child: Form(
            key: _formKey,
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
                                  Navigator.pop(context);
                                },
                                child: Icon(Icons.chevron_left),
                              ),
                            ),
                            Text(
                              'Deposit BRL',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/pix_transactions');
                          },
                          icon: Icon(Icons.history),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 15, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Currency'),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
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
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 10),
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
                                  width: 30,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(right: 5),
                                child: Text(
                                  'BRL',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                'Brazilian Real',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: width * 0.3,
                            child: TextFormField(
                              textAlign: TextAlign.end,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter amount';
                                } else if (double.parse(value) < 100) {
                                  return 'Minimum 100 BRL';
                                }
                                return null;
                              },
                              onChanged: (value) async {
                                calculateRates('BRL', value);
                              },
                              controller: _amountBrlController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                ),
                                hintText: "Enter 10-100000",
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 5),
                      child: IconButton(
                        onPressed: () async {
                          // togglePairs();
                        },
                        icon: Image.asset(
                          'assets/img/transfer.png',
                          width: 32,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
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
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 10),
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
                                  'assets/img/usdt.png',
                                  width: 30,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(right: 5),
                                child: Text(
                                  'USDT',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                'Tether USD',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: width * 0.3,
                            child: TextFormField(
                              textAlign: TextAlign.end,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter amount';
                                }
                                return null;
                              },
                              onChanged: (value) async {
                                calculateRates('USDT', value);
                              },
                              controller: _amountUsdtController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                ),
                                hintText: "Enter USDT value",
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 20,
                        bottom: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'You receive:',
                                style: TextStyle(color: secondaryTextColor),
                              ),
                              Text(
                                '${_amountUsdtController.text.isNotEmpty ? _amountUsdtController.text : 0.00} USDT',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'You pay:',
                                style: TextStyle(color: secondaryTextColor),
                              ),
                              Text(
                                '${_amountBrlController.text.isNotEmpty ? _amountBrlController.text : 0.00} BRL',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 20,
                        bottom: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 10),
                            child: Text(
                              'Deposit with',
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color(0xff3F4374),
                            ),
                            padding: EdgeInsets.all(5),
                            child: Text(
                              'Recommended',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          style: BorderStyle.solid,
                          width: 1,
                          color: linkColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Radio(
                              activeColor: linkColor,
                              value: _transactionType,
                              groupValue: 'bank_transfer',
                              onChanged: (value) {
                                setState(() {
                                  _transactionType = value as String;
                                });
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    'Bank Transfer (PIX)',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    '${payments.pixCurrencyCommission}% Fee, Real-time payment',
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
                      ),
                    ),
                  ],
                ),
                LyoButton(
                  onPressed: (_amountBrlController.text.isEmpty ||
                          _amountUsdtController.text.isEmpty ||
                          _processTransaction)
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            payments.getKycVerificationDetails({
                              'userId': auth.userInfo['id'],
                            });
                            setState(() {
                              _fieldErrors = {};
                              _nameController.clear();
                              _emailController.clear();
                              _cpfController.clear();
                              _name = '';
                              _email = '';
                              _cpf = '';
                              _loading = false;
                              _processKyc = false;
                            });

                            if (payments.pixKycClients.isNotEmpty) {
                              if (payments.pixKycClients['activate']) {
                                setState(() {
                                  _processTransaction = true;
                                });
                                await payments.createNewPixTransaction(
                                    context,
                                    {
                                      "client_id":
                                          payments.pixKycClients['userId'],
                                      "value": _sendUsdtAmount,
                                      "client": payments.pixKycClients,
                                      "userAddresses": _userAddresses,
                                    },
                                    _amountBrlController.text);
                                setState(() {
                                  _processTransaction = false;
                                });
                                if (payments.pixNewTransaction.isNotEmpty) {
                                  Navigator.pushNamed(
                                      context, '/pix_process_payment');
                                }
                              } else {
                                showModalBottomSheet<void>(
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
                                        return GestureDetector(
                                          onTap: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: kycInformation(
                                            context,
                                            setState,
                                            0.9,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              }
                            } else {
                              showModalBottomSheet<void>(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(25.0),
                                  ),
                                ),
                                context: context,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        child: kycInformation(
                                          context,
                                          setState,
                                          0.9,
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          }
                        },
                  text: 'Continue',
                  active: true,
                  isLoading: _processTransaction,
                  activeColor: (_amountBrlController.text.isEmpty ||
                          _amountUsdtController.text.isEmpty)
                      ? Color(0xff5E6292)
                      : linkColor,
                  activeTextColor: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getClientUpdate(payments) async {
    if (payments.clientUpdateCall == 1) {
      var auth = Provider.of<Auth>(context, listen: false);
      var payments = Provider.of<Payments>(context, listen: false);
      await payments.getKycVerificationTransaction(
        payments.pixKycClients['client_uuid'],
      );
      await payments.getKycVerificationDetails({
        'userId': auth.userInfo['id'],
      });
      await payments.getAllPixTransactions(
        payments.pixKycClients['client_uuid'],
      );
    }
  }

  Widget kycInformation(context, setState, heightCal) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var payments = Provider.of<Payments>(context, listen: true);

    if (payments.kycTransaction.isNotEmpty) {
      if (payments.kycTransaction['status'] == 'PROCESSING') {
        if (_timer == null) {
          setState(() {
            if (payments.kycTransaction.isNotEmpty) {
              if (payments.kycTransaction['date_end'] != null) {
                _timer = Timer.periodic(
                  const Duration(seconds: 1),
                  (Timer timer) {
                    final nowDate = DateTime.now().toLocal();
                    var endDate =
                        DateTime.parse(payments.kycTransaction['date_end'])
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
                    payments.setClientUpdateCall(payments.clientUpdateCall - 1);
                    if (payments.clientUpdateCall == 0) {
                      payments.setClientUpdateCall(10);
                    }
                    getClientUpdate(payments);
                  },
                );
              }
            }
          });
        } else {
          setState(() {
            _timer!.cancel();
            _timer = null;
          });
          setState(() async {
            if (payments.pixKycClients.isNotEmpty) {
              await payments.getKycVerificationTransaction(
                payments.pixKycClients['client_uuid'],
              );
            }
            if (payments.kycTransaction.isNotEmpty) {
              if (payments.kycTransaction['date_end'] != null) {
                _timer = Timer.periodic(
                  const Duration(seconds: 1),
                  (Timer timer) {
                    final nowDate = DateTime.now().toLocal();
                    var endDate =
                        DateTime.parse(payments.kycTransaction['date_end'])
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
                    payments.setClientUpdateCall(payments.clientUpdateCall - 1);
                    if (payments.clientUpdateCall == 0) {
                      payments.setClientUpdateCall(10);
                    }
                    getClientUpdate(payments);
                  },
                );
              }
            }
          });
        }
      }
    }

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        padding: EdgeInsets.only(right: 10, left: 10),
        height: height * 0.9,
        child: Form(
          key: _formAdditinalInformationKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              (payments.kycTransaction.isNotEmpty)
                  ? Container(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'KYC Verification',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  if (_timer != null) {
                                    _timer!.cancel();
                                  }
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.close,
                                  size: 20,
                                ),
                              )
                            ],
                          ),
                          Divider(),
                          Container(
                            child: Text(
                              'The QR code with 5 Dollar deposit is used to verify your CPF account. Once Approved, you will be redirect to next screen for transferring payments for deposit.',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: payments.kycTransaction.isNotEmpty
                                ? payments.kycTransaction['status'] ==
                                        'ACCEPTED'
                                    ? Align(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          'assets/img/approved.png',
                                          width: 50,
                                        ),
                                      )
                                    : Stack(
                                        children: [
                                          Image.asset(
                                            'assets/img/qr_scan.png',
                                            width: 150,
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 9, left: 10),
                                            child: payments
                                                    .kycTransaction.isNotEmpty
                                                ? QrImage(
                                                    data: utf8.decode(
                                                      base64.decode(payments
                                                                      .kycTransaction[
                                                                  'qr_code'] !=
                                                              null
                                                          ? payments
                                                                  .kycTransaction[
                                                              'qr_code']
                                                          : ''),
                                                    ),
                                                    version: QrVersions.auto,
                                                    backgroundColor:
                                                        Colors.white,
                                                    size: 130.0,
                                                  )
                                                : Container(),
                                          ),
                                          payments.kycTransaction.isNotEmpty
                                              ? (payments.kycTransaction[
                                                              'status'] ==
                                                          'CHARGEBACK' ||
                                                      payments.kycTransaction[
                                                              'status'] ==
                                                          'REVERSED')
                                                  ? InkWell(
                                                      onTap: () async {
                                                        setState(() {
                                                          _reRequestKYCAuth =
                                                              true;
                                                        });
                                                        await payments
                                                            .clearKycTransactions();
                                                        // reRequestKyc();
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            top: 5, left: 5),
                                                        height: 140,
                                                        width: 140,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Color.fromARGB(
                                                              207, 94, 98, 146),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          border: Border.all(
                                                            style: BorderStyle
                                                                .solid,
                                                            width: 0.3,
                                                            color: Color(
                                                                0xff5E6292),
                                                          ),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Icon(
                                                            Icons.refresh,
                                                            size: 50,
                                                          ),
                                                        ),
                                                      ))
                                                  : Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5, left: 5),
                                                      height: 140,
                                                      width: 140,
                                                    )
                                              : Container(
                                                  margin: EdgeInsets.only(
                                                      top: 5, left: 5),
                                                  height: 140,
                                                  width: 140,
                                                ),
                                        ],
                                      )
                                : Container(),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text:
                                      '${payments.kycTransaction['qr_code'] != null ? payments.kycTransaction['qr_code'] : ''}',
                                ),
                              );
                              showAlert(
                                context,
                                Icon(Icons.copy),
                                'Copied',
                                [Text('QR Code copied!')],
                                'Ok',
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                          Container(
                            padding: EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text('Status'),
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        '${payments.kycTransaction['status']}',
                                        style: TextStyle(
                                          color: payments.kycTransaction[
                                                      'status'] ==
                                                  'ACCEPTED'
                                              ? successColor
                                              : warningColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('Countdown'),
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        payments.kycTransaction['status'] ==
                                                'PROCESSING'
                                            ? payments.awaitingTime
                                            : payments.kycTransaction[
                                                        'status'] ==
                                                    'ACCEPTED'
                                                ? 'KYC Verified'
                                                : '0 h 00 min 00 sec',
                                        style: TextStyle(
                                          color: linkColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(
                                    '${payments.pixKycClients['name_client']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                      '${payments.pixKycClients['email_client']}'),
                                ),
                                Container(
                                  child: Text(
                                      '${payments.pixKycClients['cpf_client']}'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Additional Information',
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
                        Divider(),
                        Container(
                          child: Text(
                            'Please input your own CPF to proceed with the transactions. Any other CPF will cause the deposit to fail.',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        _reRequestKYCAuth
                            ? Container()
                            : Column(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 15, bottom: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Full Name'),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        style: BorderStyle.solid,
                                        width: 0.3,
                                        color: Color(0xff5E6292),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: width * 0.85,
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter name';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              setState(() {
                                                _name = value;
                                              });
                                            },
                                            controller: _nameController,
                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.zero,
                                              isDense: true,
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                              hintStyle: TextStyle(
                                                fontSize: 14,
                                              ),
                                              hintText: "Enter your name",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _fieldErrors['name'] != null
                                      ? Container(
                                          padding: EdgeInsets.all(5),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              _fieldErrors['name'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: errorColor,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                        _reRequestKYCAuth
                            ? Container()
                            : Column(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 15, bottom: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Email'),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        style: BorderStyle.solid,
                                        width: 0.3,
                                        color: Color(0xff5E6292),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: width * 0.85,
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter email';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              setState(() {
                                                _email = value;
                                              });
                                            },
                                            controller: _emailController,
                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.zero,
                                              isDense: true,
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                              hintStyle: TextStyle(
                                                fontSize: 14,
                                              ),
                                              hintText: "Enter your email",
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  _fieldErrors['email'] != null
                                      ? Container(
                                          padding: EdgeInsets.all(5),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              _fieldErrors['email'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: errorColor,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                        Container(
                          padding: EdgeInsets.only(top: 15, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('CPF'),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
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
                                width: width * 0.85,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter CPF account number';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _cpf = value;
                                    });
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  controller: _cpfController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                    ),
                                    hintText: "Enter 11 digits of your CPF",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        _fieldErrors['cpf'] != null
                            ? Container(
                                padding: EdgeInsets.all(5),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _fieldErrors['cpf'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: errorColor,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
              payments.kycTransaction.isNotEmpty
                  ? Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: payments.kycTransaction['status'] ==
                                    'PROCESSING'
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Icon(
                                          Icons.timer,
                                          color: warningColor,
                                        ),
                                      ),
                                      Text(
                                        'Awaiting payment',
                                        style: TextStyle(
                                          color: warningColor,
                                        ),
                                      ),
                                    ],
                                  )
                                : payments.kycTransaction['status'] ==
                                        'ACCEPTED'
                                    ? TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          setState(() {
                                            _processTransaction = true;
                                          });
                                          await payments
                                              .createNewPixTransaction(
                                            context,
                                            {
                                              "client_id": payments
                                                  .pixKycClients['userId'],
                                              "value": _sendUsdtAmount,
                                              "client": payments.pixKycClients,
                                              "userAddresses": _userAddresses,
                                            },
                                            _amountBrlController.text,
                                          );
                                          setState(() {
                                            _processTransaction = false;
                                          });
                                          if (payments
                                              .pixNewTransaction.isNotEmpty) {
                                            Navigator.pushNamed(context,
                                                '/pix_process_payment');
                                          }
                                        },
                                        child: Text('Continue'),
                                      )
                                    : TextButton(
                                        onPressed: () async {
                                          // print(payments.pixKycClients[0]['client_uuid']);
                                          setState(() {
                                            _reRequestKYCAuth = true;
                                          });
                                          await payments.clearKycTransactions();
                                          // reRequestKyc();
                                        },
                                        child: Text('Resend KYC verification'),
                                      ),
                          ),
                        ),
                        Container(
                          width: width,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(bottom: 50),
                          decoration: BoxDecoration(
                            color: Color(0xff1E2144),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              style: BorderStyle.solid,
                              width: 0.3,
                              color: Color(0xff1E2144),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.info,
                                  size: 15,
                                  color: secondaryTextColor,
                                ),
                              ),
                              Text(
                                'Please scan the code to pay to verify your CPF',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : LyoButton(
                      onPressed: ((_name.isEmpty || !_reRequestKYCAuth) ||
                              (_email.isEmpty || !_reRequestKYCAuth) ||
                              _cpf.isEmpty ||
                              _loading)
                          ? null
                          : () {
                              if (!_reRequestKYCAuth) {
                                if (!RegExp(
                                  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
                                ).hasMatch(_email)) {
                                  setState(() {
                                    _fieldErrors['email'] =
                                        'Invalid email format';
                                  });
                                } else {
                                  setState(() {
                                    _fieldErrors.remove('email');
                                  });
                                }
                              }

                              if (_cpf.length < 11 || _cpf.length > 11) {
                                setState(() {
                                  _fieldErrors['cpf'] = 'Invalid cpf account';
                                });
                              } else if (double.tryParse(_cpf) == null) {
                                setState(() {
                                  _fieldErrors['cpf'] = 'Invalid cpf account';
                                });
                              } else {
                                setState(() {
                                  _fieldErrors.remove('cpf');
                                });
                              }

                              if (_fieldErrors.isEmpty) {
                                if (_reRequestKYCAuth) {
                                  reRequestKyc();
                                } else {
                                  requestKyc();
                                }
                              }
                            },
                      text: 'Continue',
                      active: true,
                      isLoading: _processKyc,
                      activeColor: (_name.isEmpty ||
                              _email.isEmpty ||
                              _cpf.isEmpty ||
                              _loading)
                          ? Color(0xff5E6292)
                          : linkColor,
                      activeTextColor: Colors.black,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
