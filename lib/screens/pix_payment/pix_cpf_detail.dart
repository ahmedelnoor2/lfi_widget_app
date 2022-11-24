import 'dart:convert';

import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                                hintText: payments.cpf['data']['cpf']??''
                              ),
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
                                hintText: payments.cpf['data']['email']??''
                              ),
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
                                hintText: payments.cpf['data']['name']??''
                              ),
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
