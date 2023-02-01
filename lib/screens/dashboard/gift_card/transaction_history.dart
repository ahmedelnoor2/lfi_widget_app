import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../utils/AppConstant.utils.dart';

class GiftCardTransaction extends StatefulWidget {
  static const routeName = '/gift_transaction_detail';
  const GiftCardTransaction({Key? key}) : super(key: key);

  @override
  State<GiftCardTransaction> createState() => _GiftCardTransactionState();
}

class _GiftCardTransactionState extends State<GiftCardTransaction> {
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllTransaction();
  }

  Future<void> getAllTransaction() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await giftcardprovider.getAllTransaction(context, auth, userid);
  }

  @override
  Widget build(BuildContext context) {
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);

    return Scaffold(
      body: SafeArea(
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
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: giftcardprovider.istransactionloading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : giftcardprovider.transaction.length == 0
                      ? Center(
                          child: noData("No Transaction."),
                        )
                      : ListView.builder(
                          itemCount: giftcardprovider.transaction.length,
                          itemBuilder: (BuildContext context, int index) {
                            var currentIndex =
                                giftcardprovider.transaction[index];

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            5),
                                                                child: Text(
                                                                  'TRX ID :',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            5),
                                                                child: Text(
                                                                  'Name',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        secondaryTextColor,
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            5),
                                                                child: Text(
                                                                  'Total Amount',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        secondaryTextColor,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                child: Text(
                                                                  'Created Date :',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        secondaryTextColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                    bottom: 5, right: 5),
                                                child: Text(
                                                  currentIndex['transactionID']
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(bottom: 5),
                                                child: Text(
                                                  currentIndex['name'] ?? '',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: redIndicator),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                    bottom: 5, right: 5),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      currentIndex['summary'][
                                                              'totalCustomerCostUSD']
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(right: 5),
                                                child: Text(
                                                  '${DateFormat('dd-MM-y H:mm').format(DateTime.parse(currentIndex['createdAt']))}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                          top: 16,
                                          bottom: 8),
                                      child: Container(
                                        padding: EdgeInsets.only(left: 5),
                                        child: LyoButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (builder) {
                                                return new Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      1.1,
                                                  child: new Container(
                                                    decoration: new BoxDecoration(
                                                        borderRadius: new BorderRadius
                                                                .only(
                                                            topLeft: const Radius
                                                                .circular(20.0),
                                                            topRight: const Radius
                                                                    .circular(
                                                                20.0))),
                                                    child: Container(
                                                        child: WebView(
                                                      initialUrl: currentIndex[
                                                              'giftCardDetails']
                                                          [0]['Redemption URL'],
                                                      javascriptMode:
                                                          JavascriptMode
                                                              .unrestricted,
                                                      onPageStarted: (url) {
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                      },
                                                      onPageFinished: (finish) {
                                                        setState(() {
                                                          isLoading = false;
                                                        });
                                                      },
                                                    )),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          text: 'Redme',
                                          active: true,
                                          activeColor: linkColor,
                                          activeTextColor: Colors.black,
                                          isLoading: false,
                                        ),
                                      ),
                                    ),
                                  ],
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
