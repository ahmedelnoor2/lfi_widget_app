import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';

import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class GiftDetail extends StatefulWidget {
  static const routeName = '/gift_detail';
  const GiftDetail({Key? key}) : super(key: key);

  @override
  State<GiftDetail> createState() => _GiftDetailState();
}

class _GiftDetailState extends State<GiftDetail> {
  double _selectedPercentage = 0;

  final _amountcontroller = TextEditingController();
  @override
  void initState() {
    super.initState();
    getAccountBalance();
  }

  Future<void> getAccountBalance() async {
    var asset = Provider.of<Asset>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);

    await asset.getAccountBalance(context, auth, "USDT");
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
    var asset = Provider.of<Asset>(context, listen: true);
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    return Scaffold(
      appBar: hiddenAppBar(),
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/giftbg.png"),
                fit: BoxFit.cover,
              ),
            ),
            height: height * 0.20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.chevron_left),
                          ),
                        ),
                        Text(
                          'Gift Detail',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  child: Column(
                    children: [
                      Text(
                        arguments['data']['name'] ?? '',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text('Receive a reward of up to x times your entry fee!'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.topCenter,
              fit: StackFit.loose,
              children: <Widget>[
                Container(
                  height: height * 0.75,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Color(0xff25284A),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            child: Row(children: [
                              Text(
                                'Buy',
                              ),
                            ]),
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  arguments['data']['currency']['name']
                                      .toString(),
                                ),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: secondaryTextColor400,
                              width: .5,
                            ),
                          ),
                          height: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Container(
                            child: Row(children: [
                              Text(
                                'Amount',
                              ),
                            ]),
                          ),
                        ),
                        TextFormField(
                          controller: _amountcontroller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                          
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 0.5,
                                  color: secondaryTextColor400), //<-- SEE HERE
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: secondaryTextColor400, width: 0.5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            hintText: 'Amount',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Wallet Balance',
                                  style:
                                      TextStyle(color: secondaryTextColor400),
                                ),
                                Text(asset.accountBalance['totalBalance']
                                    .toString())
                              ]),
                        ),
                        LyoButton(
                          onPressed: (() async {
                            dotransaction();
                          }),
                          text: 'Buy Now',
                          active: true,
                          isLoading: giftcardprovider.dotransactionloading,
                          activeColor: linkColor,
                          activeTextColor: Colors.black,
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                    top: -50,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            giftcardprovider.toActiveCatalog['card_image']
                                .toString(),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      height: 120,
                      width: 200,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
