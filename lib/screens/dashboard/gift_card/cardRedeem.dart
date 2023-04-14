import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class CardRedeem extends StatefulWidget {
  CardRedeem({
    Key? key,
    this.brandid,
    this.transactionId,
  }) : super(key: key);

  var brandid;
  var transactionId;
  @override
  State<CardRedeem> createState() => _CardRedeemState();
}

class _CardRedeemState extends State<CardRedeem> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRedeem();
  }

  Future<void> getRedeem() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];

    await giftcardprovider.getRedeem(
        context, auth, userid, widget.transactionId, widget.brandid);
  }

  @override
  Widget build(BuildContext context) {
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);
    return Container(
        height: MediaQuery.of(context).size.height * 0.55,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          width: width,
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: secondaryTextColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 8.0, right: 8.0),
                child: Card(
                  color: cardcolor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("cardNumber"),
                                Row(
                                  children: [
                                    Text(giftcardprovider.redeem['cardNumber']),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: giftcardprovider
                                                .redeem['cardNumber'],
                                          ),
                                        );

                                        snackAlert(context, SnackTypes.success,
                                            'Copied');
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Image.asset(
                                          'assets/img/copy.png',
                                          width: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("pinCode:"),
                                Row(
                                  children: [
                                    Text(giftcardprovider.redeem['pinCode']),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: giftcardprovider
                                                .redeem['pinCode'],
                                          ),
                                        );

                                        snackAlert(context, SnackTypes.success,
                                            'Copied');
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Image.asset(
                                          'assets/img/copy.png',
                                          width: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        // SizedBox(
                        //     height: 50,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Text("Expiration Date:"),
                        //         Text(currentIndex['giftCardDetails'][0]
                        //             ['Expiration Date']),
                        //       ],
                        //     )),
                        // SizedBox(
                        //     child: Column(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text("Redemption Details:"),
                        //     SizedBox(height: 10),
                        //     Container(
                        //         height: height * 0.20,
                        //         width: width * 0.90,
                        //         child: SingleChildScrollView(
                        //             scrollDirection: Axis.vertical,
                        //             child: Text(currentIndex['giftCardDetails']
                        //                     [0]['Redemption Details'] +
                        //                 currentIndex['giftCardDetails'][0]
                        //                     ['Redemption Details']))),
                        //   ],
                        // )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
