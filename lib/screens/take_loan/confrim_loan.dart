import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:lyotrade/providers/loan_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/widget/loading_dialog.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import 'package:provider/provider.dart';

import '../common/widget/error_dialog.dart';

class Confirmloan extends StatefulWidget {
  static const routeName = '/confirm_loan';
  const Confirmloan({Key? key}) : super(key: key);

  @override
  State<Confirmloan> createState() => _ConfirmloanState();
}

class _ConfirmloanState extends State<Confirmloan> {
  bool agree = false;

  final TextEditingController _textEditingControllerAddress =
      TextEditingController();
  final TextEditingController _textEditingControllerEmail =
      TextEditingController();
  final TextEditingController _textEditingControllerhistory =
      TextEditingController();
  final TextEditingController _textotpcontrolller = TextEditingController();
  //  Future<void> doconfirm(loanid,reciveraddres,email) async {
  //   var loanProvider = Provider.of<LoanProvider>(context, listen: false);
  //   await loanProvider.getConfirm(loanid,reciveraddres,email);
  // }

  final _formKey = GlobalKey<FormState>();

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
        });

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
        });

    await loanProvider.getConfirm(
      loanProvider.loanid,
      _textEditingControllerAddress.text.trim(),
      _textEditingControllerEmail.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var loanProvider = Provider.of<LoanProvider>(context, listen: true);

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: hiddenAppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                          'Confirm Crypto loan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        RaisedButton(
                          color: Colors.transparent,
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: buttoncolour,
                                    content: Stack(
                                      children: <Widget>[
                                        Positioned(
                                          right: -40.0,
                                          top: -40.0,
                                          child: InkResponse(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: CircleAvatar(
                                              child: Icon(Icons.close),
                                              backgroundColor: Colors.red,
                                            ),
                                          ),
                                        ),
                                        Form(
                                          // key: _formKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                color: blackTextColor,
                                                height: 30,
                                                child: Text(
                                                    'Show my loans history'),
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text('Your Email'),
                                                  Container(
                                                      child: TextField(
                                                    controller:
                                                        _textEditingControllerhistory,
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelText:
                                                          'example@domain.com',
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
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: RaisedButton(
                                                  color: blackTextColor,
                                                  child: Text("Submitß"),
                                                  onPressed: () {
                                                    if (_textEditingControllerhistory
                                                        .text.isEmpty) {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Please insert email",
                                                          toastLength: Toast
                                                              .LENGTH_SHORT,
                                                          gravity: ToastGravity
                                                              .CENTER,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor:
                                                              Colors.red,
                                                          textColor:
                                                              Colors.white,
                                                          fontSize: 16.0);
                                                    } else {
                                                      loanProvider
                                                          .getLoanHistory(
                                                              _textEditingControllerhistory.text
                                                                  .trim())
                                                          .whenComplete(() => loanProvider
                                                                          .myloanhistory[
                                                                      'status'] ==
                                                                  200
                                                              ? Fluttertoast.showToast(
                                                                  msg:
                                                                      "Check your Email",
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity:
                                                                      ToastGravity
                                                                          .TOP,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  backgroundColor:
                                                                      buttoncolour,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  fontSize:
                                                                      16.0)
                                                              : null);

                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: Text("View All loan"),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Text('Your loan:'),
                          Text(loanProvider.loanstatus['loan']
                                  ['expected_amount']
                              .toString()),
                          Text(' USDT'),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Your deposit'),
                          Text('BTC '),
                          Text(loanProvider.loanstatus['deposit']
                                  ['expected_amount']
                              .toString()),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: selectboxcolour,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [Text('Loan Details')],
                        ),
                      ),
                      Divider(
                        thickness: 2,
                      ),
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
                      SizedBox(
                        height: 5,
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
                                  loanProvider.loanestimate['interest_amounts']
                                          ['month'] ??
                                      'empty',
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
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('LTV',
                                style: TextStyle(color: greyDarkTextColor)),
                            Text(loanProvider.ltv_percent.toString())
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price Down Limit',
                              style: TextStyle(color: greyDarkTextColor),
                            ),
                            Text(
                              loanProvider.loanestimate['down_limit'] +
                                      'BTC/USDT' ??
                                  'empty',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text('Your USDT-ETH  '),
                    Text('payout address'),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                    child: TextField(
                  controller: _textEditingControllerAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'TX7gY7ts8PpJYcupF4kHpkGazopd9jH8Cs',
                  ),
                  onChanged: (text) {
                    setState(() {});
                  },
                )),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [Text('Your email')],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: TextField(
                    controller: _textEditingControllerEmail,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'example@gmail.com',
                        suffixIcon: GestureDetector(
                          onTap: () async {
                            await emailformValidation();
                          },
                          child: Container(
                            child: Text(
                              'Verify',
                              style: TextStyle(
                                color: selecteditembordercolour,
                              ),
                            ),
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(3.0),
                          ),
                        )),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                Container(
                  child: loanProvider.isemailwidgitconverter == true
                      ? Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Enter OTP Code or  ',
                                  style: TextStyle(color: Colors.red),
                                ),
                                GestureDetector(
                                  onTap: (() {
                                    setState(() {
                                      loanProvider.isemailwidgitconverter =
                                          false;
                                    });
                                  }),
                                  child: Text(
                                    'Change My Email',
                                    style: TextStyle(
                                        color: tabBarindicatorColor,
                                        decoration: TextDecoration.underline,
                                        decorationThickness: 2),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: TextField(
                                controller: _textotpcontrolller,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Enter Otp',
                                    suffixIcon: Container(
                                      child: Text(
                                        'Send',
                                        style: TextStyle(
                                          color: selecteditembordercolour,
                                        ),
                                      ),
                                      margin: const EdgeInsets.all(15.0),
                                      padding: const EdgeInsets.all(3.0),
                                    )),
                                onChanged: (text) {
                                  if (text.length == 6) {
                                    setState(() {
                                      loanProvider.sendOtp(
                                          context,
                                          _textEditingControllerEmail.text
                                              .toString(),
                                          _textotpcontrolller.text.trim());
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ),
                SizedBox(
                  height: 10,
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
                      'I have read and accept terms and conditions loytrade',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: secondaryTextColor400,
                          minimumSize: Size(180, 40)),
                      onPressed: (() {
                        Navigator.pop(context);
                      }),
                      child: Text('Previous'),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(180, 40)),
                        onPressed: agree
                            ? () async {
                                await confirmloanformValidation();
                              }
                            : null,
                        child: const Text('Confirm'))
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
