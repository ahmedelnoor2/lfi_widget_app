import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/providers/notification_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/screens/dashboard/gift_card/catalog.dart';
import 'package:lyotrade/screens/dashboard/gift_card/country_drawer.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class GiftCard extends StatefulWidget {
  static const routeName = '/gift_card';
  const GiftCard({Key? key}) : super(key: key);

  @override
  State<GiftCard> createState() => _GiftCardState();
}

class _GiftCardState extends State<GiftCard> with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllWallet();
    getAllCountries();
    getCatalog();
  }

  // Get wallets//
  Future<void> getAllWallet() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await giftcardprovider.getAllWallet(context, auth,userid);
  }
  
  
  Future<void> getAllCountries() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await giftcardprovider.getAllCountries(context, auth, userid);
  }

  Future<void> getCatalog() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await giftcardprovider.getAllCatalog(context, auth, userid);
    getAllCard();
  }

  Future<void> getAllCard() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await giftcardprovider.getAllCard(
      context,
      auth,
      userid,
    );
  }

  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var auth = Provider.of<Auth>(context, listen: true);

    final List<Widget> imageSliders = giftcardprovider.sliderlist
        .map((item) => InkWell(
              onTap: (() async {
                giftcardprovider.settActiveCatalog(item);
                var userid = await auth.userInfo['id'];
          
                await giftcardprovider.getAllCard(context, auth, userid);
              }),
              child: Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: item['card_image'],
                          placeholderFadeInDuration:
                              Duration(milliseconds: 1000),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.transparent, BlendMode.colorBurn)),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                          ),
                        ),
                      ],
                    )),
              ),
            ))
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CountryDrawer(),
      appBar: hiddenAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 10, top: 10),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.chevron_left),
                      ),
                    ),
                    Text(
                      'Gift Card',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: () {
                      snackAlert(
                          context, SnackTypes.warning, 'Comming soon...');
                      // Navigator.pushNamed(context, '/gift_transaction_detail');
                    },
                    icon: Icon(Icons.history),
                  ),
                ),
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: (() {
                  _scaffoldKey.currentState!.openDrawer();
                }),
                child: Container(
                  color: Color(0xff292C51),
                  // padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        style: BorderStyle.solid,
                        width: 0.3,
                        color: Color(0xff76B9A),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        '${giftcardprovider.toActiveCountry['name']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: giftcardprovider.toActiveCountry['currency'] ==
                              null
                          ? Container()
                          : Text(
                              'Currency: ${giftcardprovider.toActiveCountry['currency']['code']}'),
                      trailing: Icon(
                        Icons.arrow_drop_down,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 180,
              child: giftcardprovider.IsCatalogloading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      child: CarouselSlider(
                        items: imageSliders,
                        carouselController: _controller,
                        options: CarouselOptions(
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.7,
                            aspectRatio: 4.0,
                            initialPage: 0,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            height: height * 30,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _current = index;
                              });
                            }),
                      ),
                    ),
            ),
            Container(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    giftcardprovider.sliderlist.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: _current == entry.key ? 30.0 : 12.0,
                      height: _current == entry.key ? 10.0 : 12.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: _current == entry.key
                              ? Color(0xff01FEF5)
                              : Color(0xff5E6292)),
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(
              height: height * 0.54,
              width: width,
              decoration: BoxDecoration(
                color: Color(0xff25284A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                    ),
                    child: Text(
                      'Buy Gift Card',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  InkWell(
                    onTap: (() {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return CatalogBottomSheet();
                            },
                          );
                        },
                      );
                    }),
                    child: Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      width: width,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            style: BorderStyle.solid,
                            width: 0.3,
                            color: bottombuttoncolour,
                          ),
                          color: bottombuttoncolour),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            giftcardprovider.toActiveCatalog['brand']
                                .toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: InkWell(
                  //     onTap: (() {
                  //       showModalBottomSheet<void>(
                  //         context: context,
                  //         builder: (BuildContext context) {
                  //           return StatefulBuilder(
                  //             builder:
                  //                 (BuildContext context, StateSetter setState) {
                  //               return CatalogBottomSheet();
                  //             },
                  //           );
                  //         },
                  //       );
                  //     }),
                  //     child: Container(
                  //       color: Color(0xff292C51),
                  //       padding: EdgeInsets.only(top: 5, bottom: 5),
                  //       child: Container(
                  //         padding: EdgeInsets.all(12),
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(5),
                  //           border: Border.all(
                  //             style: BorderStyle.solid,
                  //             width: 0.3,
                  //             color: Color(0xff76B9A),
                  //           ),
                  //         ),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             SizedBox(
                  //               width: width * 0.50,
                  //               child: TextFormField(
                  //                 enabled: false,
                  //                 validator: (value) {
                  //                   if (value == null || value.isEmpty) {
                  //                     return 'Please enter wallet address';
                  //                   }
                  //                   return null;
                  //                 },
                  //                 decoration: const InputDecoration(
                  //                   contentPadding: EdgeInsets.zero,
                  //                   isDense: true,
                  //                   border: UnderlineInputBorder(
                  //                     borderSide: BorderSide.none,
                  //                   ),
                  //                   hintStyle: TextStyle(
                  //                       fontSize: 14, color: Color(0xff5E6292)),
                  //                   hintText: "Search",
                  //                   // prefixIcon: Icon(Icons.search)
                  //                 ),
                  //               ),
                  //             ),
                  //             Row(
                  //               children: [
                  //                 giftcardprovider.toActiveCatalog.isNotEmpty
                  //                     ? Container(
                  //                         padding: EdgeInsets.only(right: 10),
                  //                         child: GestureDetector(
                  //                           onTap: () async {},
                  //                           child: Text(
                  //                             giftcardprovider
                  //                                 .toActiveCatalog['brand']
                  //                                 .toString(),
                  //                             style: TextStyle(
                  //                               fontSize: 14,
                  //                               color: Colors.white,
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       )
                  //                     : Container(),
                  //               ],
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: giftcardprovider.cardloading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : giftcardprovider.allCard.length <= 0
                            ? Center(
                                child: noData('No Cards Available'),
                              )
                            : ListView.separated(
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(),
                                shrinkWrap: true,
                                itemCount: giftcardprovider.allCard.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var currentindex =
                                      giftcardprovider.allCard[index];
                                  return ListTile(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/gift_detail',
                                        arguments: {'data': currentindex},
                                      );
                                    },
                                    leading: Container(
                                          width: 100,
                                          child: FadeInImage.memoryNetwork(
                                            placeholder: kTransparentImage,
                                            image:giftcardprovider
                                          .toActiveCatalog['card_image']
                                                      .toString(),
                                                      fit: BoxFit.cover,
                                          ),
                                        ),
                                    title: Text('${currentindex['name']}'),
                                    subtitle: currentindex['is_a_range']
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Min price: ${currentindex['min']}'),
                                              Text(
                                                  'Max price: ${currentindex['max']}'),
                                            ],
                                          )
                                        : Text('Price: ${currentindex['max']}'),
                                    trailing: Icon(Icons.chevron_right),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
