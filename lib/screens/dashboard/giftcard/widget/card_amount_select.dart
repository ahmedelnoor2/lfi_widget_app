import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/providers/topup.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class CardAmountSelect extends StatefulWidget {
  CardAmountSelect(
    this.amountlist,
    this.billerid, {
    Key? key,
  }) : super(key: key);
  List? amountlist;
  var billerid;
  @override
  State<CardAmountSelect> createState() => _CardAmountSelectState();
}

class _CardAmountSelectState extends State<CardAmountSelect> {
  Future<void> getEstimateRate() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await giftcardprovider.getEstimateRate(context, auth, userid, {
      "currency": "${giftcardprovider.toActiveCountry['currency']['code']}",
      "payment": giftcardprovider.giftcardamount,
      "productID": widget.billerid
    });
    return;
  }

  double getamount(String country, String amount, String rate) {
    if (country == 'AED') {
      return double.parse(amount);
    }
    return double.parse(amount) * double.parse(rate);
  }

  @override
  Widget build(BuildContext context) {
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      width: width,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Select Amount',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
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
          Expanded(
            child: GridView.builder(
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: widget.amountlist!.length,
              itemBuilder: (context, index) {
                var currentindex = getamount(
                    giftcardprovider.toActiveCountry['currency']['code'],
                    widget.amountlist![index].toString(),
                    giftcardprovider.toActiveCountry['rate']['rate']
                        .toString());
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          giftcardprovider.setgiftcardamount(currentindex);
                          getEstimateRate();
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            // border: Border.all(color: Color(0xff940D5A)),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(17.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 40.0,
                                ),
                                child: Text(
                                  "${(currentindex.toStringAsFixed(2)) + ' ' + giftcardprovider.toActiveCountry['currency']['code']}",
                                  style: TextStyle(
                                      color: Color(0xff00315C),
                                      fontSize: 14.0,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600),
                                  // textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                height: 20,
                                width: width,
                                decoration: BoxDecoration(
                                  color: seconadarytextcolour,
                                  borderRadius: BorderRadius.circular(17.0),
                                ),
                                child: Center(
                                    child: Text(
                                  'Amount',
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                )),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
