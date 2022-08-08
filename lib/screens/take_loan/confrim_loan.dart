import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';

import 'package:lyotrade/providers/loan_provider.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/widget/loading_dialog.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import 'package:provider/provider.dart';

import '../common/widget/error_dialog.dart';

class ConfirmLoan extends StatefulWidget {
  static const routeName = '/confirm_loan';
  const ConfirmLoan({Key? key}) : super(key: key);

  @override
  State<ConfirmLoan> createState() => _ConfirmLoanState();
}

class _ConfirmLoanState extends State<ConfirmLoan> {
  bool agree = false;
  bool _isLoading = false;

  final TextEditingController _textEditingControllerAddress =
      TextEditingController();
  final TextEditingController _textEditingControllerEmail =
      TextEditingController();
  final TextEditingController _textEditingControllerhistory =
      TextEditingController();
  final TextEditingController _textotpcontrolller = TextEditingController();
  final TextEditingController _2faCodeController = TextEditingController();
  //  Future<void> doconfirm(loanid,reciveraddres,email) async {
  //   var loanProvider = Provider.of<LoanProvider>(context, listen: false);
  //   await loanProvider.getConfirm(loanid,reciveraddres,email);
  // }

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setEmailVerification();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingControllerAddress.dispose();
    _textEditingControllerEmail.dispose();
    _textEditingControllerhistory.dispose();
    _2faCodeController.dispose();
    _textotpcontrolller.dispose();
  }

  void setEmailVerification() {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);
    loanProvider.setIsEmailWidgetConverter(false);
  }

  emailformValidation() {
    if (_textEditingControllerEmail.text.isEmpty) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please write Email.",
            );
          });
    } else {
      verifynow();
    }
  }

  verifynow() async {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (c) {
        return LoadingDialog(message: "Checking");
      },
    );

    await loanProvider
        .getemail(context, _textEditingControllerEmail.text.toString())
        .whenComplete(() {
      if (loanProvider.isemailwidgitconverter = true) {
        setState(() {
          loanProvider.isemailwidgitconverter = true;
        });
      } else {
        setState(() {
          loanProvider.isemailwidgitconverter = false;
        });
      }
    });

    Navigator.pop(context);
  }

  confirmloanformValidation() {
    if (_textEditingControllerEmail.text.isEmpty ||
        _textEditingControllerAddress.text.isEmpty ||
        _textotpcontrolller.text.isEmpty) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please write email/address/otp.",
            );
          });
    } else {
      confirmnow();
    }
  }

  confirmnow() async {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (c) {
        return LoadingDialog(message: "Checking");
      },
    );

    await loanProvider.getCustomer2FA(context, {
      'email': _textEditingControllerEmail.text,
    });

    Navigator.pop(context);
    if (loanProvider.cutomer2FA.isNotEmpty) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return twoFactorAuth(
                context,
                setState,
              );
            },
          );
        },
      );
    }
  }

  confirmLoan() async {
    setState(() {
      _isLoading = true;
    });
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);

    await loanProvider.getConfirm(
      context,
      loanProvider.loanid,
      _textEditingControllerAddress.text.trim(),
      _textEditingControllerEmail.text.trim(),
    );
    if (loanProvider.isConfirm) {
      Navigator.pushNamed(context, '/process_loan');
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);
    var loanProvider = Provider.of<LoanProvider>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);

    if (auth.isAuthenticated) {
      if (_textEditingControllerAddress.text.isEmpty) {
        setState(() {
          _textEditingControllerAddress.text =
              asset.changeAddress['addressStr'];
        });
      }
    }

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
                            loanProvider.setIsEmailWidgetConverter(false);
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.chevron_left),
                        ),
                      ),
                      Text(
                        'Confirm Crypto loan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return checkLoanHistory(context, setState);
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(right: 5, left: 15),
                      child: Icon(Icons.menu),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text('Your loan:'),
                        ),
                        Text(
                          loanProvider.loanstatus['loan']['expected_amount']
                              .toString(),
                        ),
                        Text(
                          ' USDT',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text('Your deposit:'),
                        ),
                        Text(
                          loanProvider.loanstatus['deposit']['expected_amount']
                              .toString(),
                        ),
                        Text(
                          'BTC ',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
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
              child: Card(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10, top: 10),
                      width: width,
                      child: Text('Loan Details'),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Loan Term',
                              style: TextStyle(color: greyDarkTextColor)),
                          Text('Unlimited'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Monthly Interest Amount',
                              style: TextStyle(color: greyDarkTextColor)),
                          Row(
                            children: [
                              Text(
                                double.parse(
                                        '${loanProvider.loanestimate['interest_amounts']['month']}')
                                    .toStringAsFixed(4),
                              ),
                              Container(
                                child: Text('ETH'),
                                padding: const EdgeInsets.all(3.0),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LTV',
                            style: TextStyle(color: greyDarkTextColor),
                          ),
                          Text(
                            '${(double.parse('${loanProvider.ltv_percent}') * 100).toString()}%',
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 10),
                            child: Text(
                              'Price Down Limit',
                              style: TextStyle(color: greyDarkTextColor),
                            ),
                          ),
                          Text(
                            double.parse(
                                        '${loanProvider.loanestimate['down_limit']}')
                                    .toStringAsFixed(4) +
                                ' ${loanProvider.fromSelectedCurrency['code']}/${loanProvider.toSelectedCurrency['code']}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(
                      'Your ${loanProvider.toSelectedCurrency['code']}-${loanProvider.toSelectedCurrency['network']} '),
                  Text('payout address'),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
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
                children: [
                  Expanded(
                    flex: 7,
                    child: TextField(
                      readOnly: auth.isAuthenticated,
                      controller: _textEditingControllerAddress,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "Enter address",
                      ),
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                  auth.isAuthenticated
                      ? Container()
                      : Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () async {
                              ClipboardData? data = await Clipboard.getData(
                                Clipboard.kTextPlain,
                              );
                              setState(() {
                                _textEditingControllerAddress.text =
                                    '${data!.text}';
                              });
                            },
                            child: Text(
                              'Paste',
                              style: TextStyle(
                                fontSize: 16,
                                color: linkColor,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            Container(
              width: width,
              padding: EdgeInsets.all(10),
              child: Text('Your email'),
            ),
            Container(
              margin: EdgeInsets.all(10),
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
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _textEditingControllerEmail,
                      readOnly: loanProvider.isemailwidgitconverter,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "Enter your email address",
                      ),
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                  loanProvider.isemailwidgitconverter
                      ? Container()
                      : InkWell(
                          onTap: loanProvider.isemailwidgitconverter
                              ? null
                              : () async {
                                  await emailformValidation();
                                },
                          child: Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              'Verify',
                              style: TextStyle(
                                color: linkColor,
                              ),
                            ),
                          ),
                        )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: loanProvider.isemailwidgitconverter == true
                  ? Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Enter OTP code or  ',
                                style: TextStyle(color: Colors.red),
                              ),
                              GestureDetector(
                                onTap: (() {
                                  setState(() {
                                    loanProvider.isemailwidgitconverter = false;
                                  });
                                }),
                                child: Text(
                                  'Change My Email',
                                  style: TextStyle(
                                    color: linkColor,
                                    decorationThickness: 2,
                                  ),
                                ),
                              )
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
                          child: TextField(
                            controller: _textotpcontrolller,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: TextStyle(
                                fontSize: 14,
                              ),
                              hintText: "Enter OTP",
                            ),
                            onChanged: (text) {
                              if (text.length == 6) {
                                setState(() {
                                  loanProvider.sendOtp(
                                    context,
                                    _textEditingControllerEmail.text.toString(),
                                    _textotpcontrolller.text.trim(),
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ),
            Row(
              children: [
                Checkbox(
                  activeColor: darkgreyColor,
                  value: agree,
                  onChanged: (value) {
                    setState(() {
                      agree = value ?? false;
                    });
                  },
                ),
                const Text(
                  'I have read and accept terms and conditions LYOTRADE',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: LyoButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        text: 'Previous',
                        active: true,
                        activeTextColor: Colors.white,
                        isLoading: false,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: LyoButton(
                        onPressed: agree
                            ? () async {
                                // await confirmloanformValidation();
                                confirmLoan();
                              }
                            : null,
                        text: 'Confirm',
                        active: agree,
                        activeColor: linkColor,
                        activeTextColor: Colors.black,
                        isLoading: _isLoading,
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

  Widget checkLoanHistory(context, setState) {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);

    return SizedBox(
      height: height * 0.9,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: hiddenAppBar(),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Get history on your email',
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
              Divider(),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text('Enter your Email:'),
                  ),
                  Container(
                      child: TextField(
                    controller: _textEditingControllerhistory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'example@domain.com',
                    ),
                    onChanged: (text) {
                      setState(() {
                        //  fullName = text;
                        //you can access nameController in its scope to get
                        // the value of text entered as shown below
                        //fullName = nameController.text;
                      });
                    },
                  )),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: LyoButton(
                  onPressed: () {
                    if (_textEditingControllerhistory.text.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Please insert email",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else {
                      loanProvider
                          .getLoanHistory(
                              _textEditingControllerhistory.text.trim())
                          .whenComplete(() =>
                              loanProvider.myloanhistory['status'] == 200
                                  ? Fluttertoast.showToast(
                                      msg: "Check your Email",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.TOP,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: buttoncolour,
                                      textColor: Colors.white,
                                      fontSize: 16.0)
                                  : null);

                      Navigator.of(context).pop();
                    }
                  },
                  text: 'Submit',
                  active: true,
                  isLoading: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget twoFactorAuth(context, setState) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var loanProvider = Provider.of<LoanProvider>(context, listen: false);

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loanProvider.cutomer2FA['fa_2']
                    ? 'Enter 2FA code to continue'
                    : 'Enable two factor authentication to continue',
                style: TextStyle(
                  fontSize: 15,
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
          loanProvider.cutomer2FA['fa_2']
              ? Container()
              : Container(
                  padding: EdgeInsets.all(10),
                  child: Image.memory(
                    base64Decode(
                      loanProvider.cutomer2FA['data']
                          .split(',')[1]
                          .replaceAll("\n", ""),
                    ),
                    width: 150,
                  ),
                ),
          loanProvider.cutomer2FA['fa_2']
              ? Container()
              : Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Setup key',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
          loanProvider.cutomer2FA['fa_2']
              ? Container()
              : InkWell(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: '${loanProvider.cutomer2FA['secret']}',
                      ),
                    );
                    showAlert(
                      context,
                      Icon(Icons.copy),
                      'Copied',
                      [
                        Text('Successfully copied.'),
                      ],
                      'Ok',
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        style: BorderStyle.solid,
                        width: 0.3,
                        color: Color(0xff5E6292),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${loanProvider.cutomer2FA['secret']}'),
                        Icon(
                          Icons.copy,
                          size: 18,
                        )
                      ],
                    ),
                  ),
                ),
          Divider(),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Enter 2FA Code:'),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Container(
              padding: EdgeInsets.only(top: 5, bottom: 10),
              child: Container(
                padding: EdgeInsets.all(12),
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
                      width: width * 0.6,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter code';
                          }
                          return null;
                        },
                        onChanged: (value) async {
                          // setState(() {
                          //   _amountController.text = value;
                          // });
                        },
                        controller: _2faCodeController,
                        keyboardType: const TextInputType.numberWithOptions(
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
                          hintText: "Enter code",
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () async {
                              ClipboardData? data = await Clipboard.getData(
                                Clipboard.kTextPlain,
                              );
                              setState(() {
                                _2faCodeController.text = '${data!.text}';
                              });
                            },
                            child: Text(
                              'PASTE',
                              style: TextStyle(
                                fontSize: 12,
                                color: linkColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 40),
            child: LyoButton(
              onPressed: () async {
                if (_2faCodeController.text.isEmpty) {
                  showAlert(
                    context,
                    Icon(Icons.error),
                    'Error',
                    [
                      Text('Please enter verification code'),
                    ],
                    'Ok',
                  );
                } else {
                  if (_2faCodeController.text.length == 6) {
                    var verifyStatus =
                        await loanProvider.verify2FACode(context, {
                      "code": _2faCodeController.text,
                      "email": _textEditingControllerEmail.text,
                    });
                    if (verifyStatus) {
                      Navigator.pop(context);
                    }
                  } else {
                    showAlert(
                      context,
                      Icon(Icons.error),
                      'Error',
                      [
                        Text('Invalid code!'),
                      ],
                      'Ok',
                    );
                    setState(() {
                      _2faCodeController.clear();
                    });
                  }
                }
              },
              text: 'Verify',
              active: true,
              activeTextColor: Colors.white,
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }
}
