import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/dex_provider.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/dex_swap/common/exchange_now.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:provider/provider.dart';

class BuyCard extends StatefulWidget {
  static const routeName = '/buy_card';
  const BuyCard({Key? key, this.amount, this.totalprice, this.defaultcoin,this.productID})
      : super(key: key);

  final String? amount;
  final double? totalprice;
  final String? defaultcoin;
  final String ? productID;

  @override
  State<BuyCard> createState() => _BuyCardState();
}

class _BuyCardState extends State<BuyCard> {

  bool _isverify=false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> dotransaction() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];

    await giftcardprovider.getDoTransaction(context, auth, userid, {
      "productID": "15009",
      "amount": "1.0",
      "firstName": "Ivan",
      "lastName": "Begumisa",
      "email": "i.b@lyopay.com",
      "orderId": "0213457",
      "quantity": " 1"
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);
    final args = ModalRoute.of(context)!.settings.arguments as BuyCard;
    // print(args.productID);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.chevron_left),
          ),
          title: Text(
            'Buy Card',
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
                child: Text(giftcardprovider.paymentstatus.toString()),
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
                          width: giftcardprovider.paymentstatus=='Waiting for payment'?width * 0.3:width * 0.3,
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
                          '${double.parse(args.totalprice.toString()).toStringAsPrecision(7)}'
                           +
                              ' ' +
                              args.defaultcoin.toString(),
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        )),
                    Container(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Text('Amount')),
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
                          'Payment',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          args.amount.toString()+' '+giftcardprovider
                                  .toActiveCountry['currency']['code'],
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 50, right: 4, left: 4),
                child: LyoButton(
                  onPressed: (() async {
                    dotransaction();
                  }),
                  text: 'Buy Now',
                  active: true,
                  isLoading: giftcardprovider.dotransactionloading,
                  activeColor: linkColor,
                  activeTextColor: Colors.black,
                ),
              )
            ],
          ),
        ));
  }
}
