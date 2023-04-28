import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class GiftCardServiceProvider extends StatefulWidget {
  static const routeName = '/gift_card_service_provider';
  @override
  _GiftCardServiceProviderState createState() =>
      _GiftCardServiceProviderState();
}

class _GiftCardServiceProviderState extends State<GiftCardServiceProvider> {
  @override
  void initState() {
    getAllGiftProvider();
    // TODO: implement initState
    super.initState();
  }

  Future<void> getAllGiftProvider() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    await giftcardprovider.getAllGiftProvider();
  }

  @override
  Widget build(BuildContext context) {
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.chevron_left),
                    ),
                    Text(
                      'Providers',
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: width,
                height: height * 0.20,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    image: DecorationImage(
                        image: AssetImage('assets/img/gift_provider.png'),
                        fit: BoxFit.cover)),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: height,
              padding: EdgeInsets.only(top: 20, left: 10, right: 10),
              decoration: BoxDecoration(
                  color: giftcardcolor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12))),
              child: Column(
                children: [
                  Center(
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: giftcardprovider.allgiftprovider.length,
                      itemBuilder: (ctx, i) {
                        var data = giftcardprovider.allgiftprovider[i];
                        return InkWell(
                          onTap: () {
                            giftcardprovider
                                .setproiverid(data['providerId'].toString());
                            print(giftcardprovider.providerid);
                            Navigator.pushNamed(context, '/gift_card');
                          },
                          child: Card(
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              margin: EdgeInsets.all(5),
                              padding: EdgeInsets.all(5),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Text(
                                          data['name'].toString(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 0.0,
                        mainAxisSpacing: 5,
                        mainAxisExtent: 100,
                      ),
                    ),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Container(
                  //       width: width * 0.45,
                  //       height: height * 0.15,
                  //       padding: EdgeInsets.all(20),
                  //       decoration: BoxDecoration(
                  //         color: Colors.white,
                  //         borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  //       ),
                  //       child: Image.asset(
                  //         'assets/img/reloadly.png',
                  //       ),
                  //     ),
                  //     InkWell(
                  //       onTap: () {
                  //         Navigator.pushNamed(context, '/gift_card');
                  //       },
                  //       child: Container(
                  //         width: width * 0.45,
                  //         height: height * 0.15,
                  //         padding: EdgeInsets.all(20),
                  //         decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  //         ),
                  //         child: Image.asset('assets/img/globe.png'),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
