import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';

import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/screens/common/header.dart';

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

class _PixPaymentDetailsState extends State<PixPaymentDetails> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 5), (Timer t) => getminimumWithDrawalAmount());
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  // get minimum with drawal amount
  Future<void> getminimumWithDrawalAmount() async {
    var payment = Provider.of<Payments>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    await payment
        .getminimumWithDrawalAmount(auth, {"uaTime": "2022-11-23 11:20:07"});

    if (payment.minimumWithdarwalAmt['cpfStatus'] == 1) {
      setState(() {
        payment.setCpfStatus(true);
      });
      print(payment.cpfStatus);
    } else {
      setState(() {
        payment.setCpfStatus(false);
      });
      print(payment.cpfStatus);
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
              Container(
                child: Column(
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
                      ],
                    ),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Text(
                        getPortugeseTrans(
                            'The QR code with 5 BRL deposit is used to verify your CPF account. Once Approved, you will be redirect to next screen for transferring payments for deposit.'),
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 9, left: 10),
                          child: payments.kycTransaction.isNotEmpty
                              ? QrImage(
                                  data: utf8.decode(
                                    base64.decode(
                                        payments.cpf['data']['qrCode'] ?? ''),
                                  ),
                                  version: QrVersions.auto,
                                  backgroundColor: Colors.white,
                                  size: 130.0,
                                )
                              : Container(),
                        ),
                        Container(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              'Pay R\$ 5.00',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 20,
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
                              enabled: false,
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
                                  hintText: payments.cpf['data']['cpf'] ?? ''),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 15, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width * 0.85,
                            child: TextFormField(
                              enabled: false,
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
                                      payments.cpf['data']['email'] ?? ''),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 15, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Name'),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          style: BorderStyle.solid,
                          width: 0.0,
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
                                  hintText: payments.cpf['data']['name'] ?? ''),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status'),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width * 0.85,
                            child: Text(
                              payments.cpfStatus ? "Un-verified" : 'Verified',
                              style: TextStyle(color: orangeBGColor),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      height: 60,
                      color: textFieldTextColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width * 0.85,
                            child: Text(
                              'Please scan the code to make payment to verify your CPF',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )));
  }
}
