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
import 'package:lyotrade/utils/Translate.utils.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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
  String _sendUsdtAmountwithouttax = '';
  Map _userAddresses = {};

  String _transactionType = 'bank_transfer';

  MaskTextInputFormatter? formatter;
  FormFieldValidator<String>? validator;
  String? hint;
  bool isMinmum = false;

  @override
  void initState() {
    _amountBrlController.clear();
    _amountUsdtController.clear();
    _cpfController.clear();

    getminimumWithDrawalAmount();
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
          if (asset.changeAddress.isNotEmpty) {
            setState(() {
              _userAddresses[key] = asset.changeAddress['addressStr'];
            });
          }
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
          _amountUsdtController.text = (double.parse(value) /
                  double.parse(
                      payments.minimumWithdarwalAmt['rate'].toString()))
              .toStringAsFixed(0);
          _sendUsdtAmountwithouttax =
              '${(double.parse(value)) / double.parse(payments.minimumWithdarwalAmt['rate'].toString())}';
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
          _amountBrlController.text = (double.parse(value) *
                  double.parse(
                      payments.minimumWithdarwalAmt['rate'].toString()))
              .toStringAsFixed(0);

          _sendUsdtAmountwithouttax =
              '${(double.parse(value) * double.parse(payments.minimumWithdarwalAmt['rate'].toString()))}';
          print(_sendUsdtAmountwithouttax);

          // _sendUsdtAmount =
          //     '${(double.parse('$value') + (double.parse('$value') * (double.parse('${payments.pixCurrencyCommission}') / 100)))}';
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
      "cpf": _cpfController.text,
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
      'userId': '${auth.userInfo['id']}',
      "cpf": _cpfController.text,
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

/////
  Future<void> validateCPF() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var payments = Provider.of<Payments>(context, listen: false);

    await payments.getCpf(context, auth, {
      "cpf": _cpfController.text,
      'email': payments.minimumWithdarwalAmt['email'].toString(),
      'name': payments.minimumWithdarwalAmt['name'].toString(),
    });
  }

// get minimum with drawal amount
  Future<void> getminimumWithDrawalAmount() async {
    var payment = Provider.of<Payments>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    await payment
        .getminimumWithDrawalAmount(auth, {"uaTime": "2022-11-23 11:20:07"});

    print(payment.minimumWithdarwalAmt['cpfStatus']);

    if (payment.minimumWithdarwalAmt['cpfStatus'] == 1) {
      setState(() {
        payment.setCpfStatus(true);
      });
    } else if (payment.minimumWithdarwalAmt['cpfStatus'] == 2) {
      setState(() {
        payment.setCpfStatus(false);
      });
    }
  }

  //// get create order
  Future<void> getCreateorder() async {
    var payment = Provider.of<Payments>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    await payment.getCreatePixOrder(
        context, auth, {"amount": _amountBrlController.text});
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);
    var payments = Provider.of<Payments>(context, listen: true);

    var getPortugeseTrans = payments.getPortugeseTrans;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                              '${getPortugeseTrans('Deposit')} BRL',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Switch(
                              value: payments.portugeseLang,
                              onChanged: (val) {
                                payments.toggleEnLang();
                              },
                              activeColor: greenIndicator,
                              activeThumbImage:
                                  const AssetImage('assets/img/brl_lang.png'),
                              inactiveThumbImage:
                                  const AssetImage('assets/img/en_lang.png'),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/pix_transactions');
                              },
                              icon: Icon(Icons.history),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 15, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${getPortugeseTrans('Currency')}'),
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
                                  return getPortugeseTrans(
                                    'Please enter amount',
                                  );
                                } else if (double.parse(value) < 110) {
                                  setState(() {
                                    _processTransaction = false;
                                  });
                                  return '${getPortugeseTrans(
                                    'Minimum',
                                  )} ${payments.minimumWithdarwalAmt['minAmount'].toString() + " BRL"}';
                                } else if (double.parse(value) > 5400) {
                                  setState(() {
                                    _processTransaction = false;
                                  });
                                  return '${getPortugeseTrans(
                                    'Maximum',
                                  )} ${payments.minimumWithdarwalAmt['maxAmount'].toString() + " BRL"}';
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
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                ),
                                hintText:
                                    "${getPortugeseTrans('Enter')} 10-100000",
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
                                  return getPortugeseTrans(
                                      'Please enter amount');
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
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                ),
                                hintText:
                                    "${getPortugeseTrans('Enter')} USDT ${getPortugeseTrans('value')}",
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
                                '${getPortugeseTrans('You receive')}:',
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
                                '${getPortugeseTrans('You pay')}:',
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
                              getPortugeseTrans('Deposit with'),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color(0xff3F4374),
                            ),
                            padding: EdgeInsets.all(5),
                            child: Text(
                              getPortugeseTrans('Recommended'),
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
                                    '${getPortugeseTrans('Bank Transfer')} (PIX)',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    '1% ${getPortugeseTrans('Fee')}, ${getPortugeseTrans('Real-time payment')}',
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
                    Container(
                      padding: EdgeInsets.only(top: 15),
                      child: Text(
                        'Note: There will be a network fee charge between 1.2 USDT to 10 USDT during transfer USDT assets to your wallet. This fee depends on the blockchain network.',
                        style: TextStyle(color: warningColor),
                      ),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: LyoButton(
                    onPressed: (_amountBrlController.text.isEmpty ||
                            _amountUsdtController.text.isEmpty ||
                            _processTransaction)
                        ? null
                        : () async {
                            setState(() {
                              _processTransaction = true;
                            });
                            if (_formKey.currentState!.validate()) {
                              if (payments.cpfStatus == false) {
                                await getCreateorder();
                                setState(() {
                                  _processTransaction = false;
                                });
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
                                setState(() {
                                  _processTransaction = false;
                                });
                              }
                            }
                          },
                    text: getPortugeseTrans(
                      'Continue',
                    ),
                    active: true,
                    isLoading: _processTransaction,
                    activeColor: (_amountBrlController.text.isEmpty ||
                            _amountUsdtController.text.isEmpty)
                        ? Color(0xff5E6292)
                        : linkColor,
                    activeTextColor: Colors.black,
                  ),
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
      var payments = Provider.of<Payments>(context, listen: true);
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

    var getPortugeseTrans = payments.getPortugeseTrans;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        padding: EdgeInsets.only(right: 10, left: 10),
        height: height * 0.9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getPortugeseTrans('Verify your CPF'),
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
                    getPortugeseTrans(
                        'Kindly type your own CPF to continue with the deposit. Putting other users CPF will cancel the transaction'),
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
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
                              return getPortugeseTrans(
                                  'Please enter CPF account number');
                            }
                            return null;
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          controller: _cpfController,
                          inputFormatters: [
                            MaskTextInputFormatter(mask: "###.###.###-##")
                          ],
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: TextStyle(
                              fontSize: 14,
                            ),
                            hintText: getPortugeseTrans(
                              "Enter 11 digits of your CPF",
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 15, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getPortugeseTrans(
                              "Email (This email is for verification only)",
                            ),
                          ),
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
                              enabled: false,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                  ),
                                  hintText:
                                      payments.minimumWithdarwalAmt['email'] ??
                                          ''),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 15, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getPortugeseTrans('Name'),
                          ),
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
                              enabled: false,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                  ),
                                  hintText:
                                      payments.minimumWithdarwalAmt['name'] ??
                                          ''),
                            ),
                          ),
                        ],
                      ),
                    ),

                    ///  check cpf number is validiate//

                    // Container(
                    //     padding: EdgeInsets.only(top: 15, bottom: 5),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Row(
                    //           children: [

                    //             SizedBox(
                    //               width: 10,
                    //             ),
                    //             Text(payments.cpfStatus == false?'Invalid Cpf':'',
                    //                 style: TextStyle(color: errorColor)),
                    //           ],
                    //         ),
                    //       ],
                    //     ),
                    //   )
                  ],
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(bottom: 30),
              child: LyoButton(
                onPressed: (_cpfController.text.isEmpty ||
                        _cpfController.text.length < 14)
                    ? null
                    : () {
                        if (_cpfController.text.length < 14) {
                          setState(() {
                            _fieldErrors['cpf'] = 'Invalid cpf account';
                          });
                        } else {
                          setState(() {
                            _fieldErrors.remove('cpf');
                          });
                        }
                        validateCPF();
                      },
                text: getPortugeseTrans('Continue'),
                active: true,
                isLoading: payments.isCpfLoading,
                activeColor: (_cpfController.text.isEmpty ||
                        _cpfController.text.length < 14)
                    ? Color(0xff5E6292)
                    : linkColor,
                activeTextColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
