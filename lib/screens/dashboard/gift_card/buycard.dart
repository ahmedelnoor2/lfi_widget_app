import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/dex_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/dex_swap/common/exchange_now.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:provider/provider.dart';

class BuyCard extends StatefulWidget {
  static const routeName = '/buy_card';
  const BuyCard({Key? key}) : super(key: key);

  @override
  State<BuyCard> createState() => _BuyCardState();
}

class _BuyCardState extends State<BuyCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {},
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
                child: Text('status'),
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
                          width: width * 0.5,
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
              Card(
                child: Container(
                  padding: EdgeInsets.all(10),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Container(
                    //padding: EdgeInsets.only(top: 20, bottom: 20),
                    child: Image.asset(
                      "assets/img/transfer.gif",
                      width: 70.0,
                    ),
                  ),
                ),
              ),
              Card(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          'Receive',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Divider(),
                      // Container(
                      //   child: dexProvider.toActiveCurrency.isNotEmpty
                      //       ? SvgPicture.network(
                      //           '${dexProvider.toActiveCurrency['image']}',
                      //           width: 40,
                      //         )
                      //       : Container(),
                      // ),
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          'amount',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5, bottom: 10),
                        child: Text(
                          'ticker'.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            top: 15, bottom: 15, right: 15, left: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            width: 0.3,
                            color: Color(0xff5E6292),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Clipboard.setData(
                            //   ClipboardData(
                            //     text: dexProvider.processPayment['payoutAddress'],
                            //   ),
                            // );
                            // snackAlert(context, SnackTypes.success, 'Copied');
                          },
                          child: Row(
                            children: [
                              Container(
                                width: width * 0.70,
                                child: Text(
                                  '3422',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Image.asset(
                                    'assets/img/copy.png',
                                    width: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
