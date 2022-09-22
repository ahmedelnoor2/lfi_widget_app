import 'package:flutter/material.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/utils/Translate.utils.dart';
import 'package:provider/provider.dart';

import '../../../utils/Colors.utils.dart';

class PayementMethod extends StatefulWidget {
  PayementMethod(this.payementMethod);

  final payementMethod;

  @override
  State<PayementMethod> createState() => _PayementMethodState();
}

class _PayementMethodState extends State<PayementMethod> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var payments = Provider.of<Payments>(context, listen: true);

    return SizedBox(
      width: size.width,
      height: size.height * .58,
      child: Container(
        width: size.width,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 12),
                ),
                shrinkWrap: true,
                itemCount: payments.paymentMethods.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          style: BorderStyle.solid,
                          width: 1,
                          color: payments.selectedpaymentmethod ==
                                  payments.paymentMethods[index]
                              ? linkColor
                              : seconadarytextcolour,
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          setState(() {
                            payments.selectedpaymentmethod =
                                payments.paymentMethods[index];
                          });

                          await payments.getOnrampEstimateRate(context, {
                            "fromCurrency":
                                payments.selectedOnrampFiatCurrency['code'],
                            "toCurrency":
                                payments.selectedOnrampCryptoCurrency['code'],
                            "paymentMethod": payments.selectedpaymentmethod,
                            "amount": payments.amount
                          });
                          
                        },
                        child: Row(
                          children: [
                            // Container(
                            //   padding: EdgeInsets.only(left: 10),
                            //   child: ClipOval(
                            //     child: CachedNetworkImage(
                            //       width: 45,
                            //       height: 45,
                            //       placeholder: (context, url) =>
                            //           const CircularProgressIndicator(
                            //         color: Colors.amber,
                            //       ),
                            //       imageUrl: payment.allCurencies[index]['icon']
                            //           .toString(),
                            //     ),
                            //   ),
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                payments.selectedpaymentmethod ==
                                        payments.paymentMethods[index]
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.radio_button_on,
                                          color: linkColor,
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.radio_button_off),
                                      ),
                                Container(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Text(
                                    convertpaymentmethodText(widget
                                        .payementMethod[index]
                                        .toString()),
                                    style: TextStyle(
                                      // color: payments.tappedIdentifier == index
                                      //     ? Colors.blueGrey
                                      //     : Colors.blue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Text(
                                //   'lj',
                                //     //'Available paying with EUR, USD, GBP or other currencies',
                                //     style: TextStyle(
                                //       fontSize: 16,
                                //     )),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
