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
import 'package:lyotrade/screens/dashboard/giftcard/catalog.dart';
import 'package:lyotrade/screens/dashboard/giftcard/country_drawer.dart';
import 'package:lyotrade/screens/dashboard/giftcard/gift_detail.dart';

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
    getAcountBalance();
    getAllCountries();
  }

  // Get wallets//
  Future<void> getAllWallet() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await giftcardprovider.getAllWallet(context, auth, userid);
  }

  Future<void> getAllCountries() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await giftcardprovider.getAllCountries(context, auth, userid);
    await getCatalog();
  }

  Future<void> getCatalog() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await giftcardprovider.getAllCatalog(context, auth, userid,
        {"country": giftcardprovider.toActiveCountry['iso2']}, true);
    await getAllCard();
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

  // Get  Accout balance company lyo/
  Future<void> getAcountBalance() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await giftcardprovider.getaccountBalance(context, auth, userid);
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
                      Navigator.pushNamed(context, '/gift_transaction_detail');
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
                      title: giftcardprovider.isCountryLoading
                          ? Row(
                              children: [
                                CircularProgressIndicator(),
                              ],
                            )
                          : giftcardprovider.toActiveCountry['name'] == null
                              ? Container()
                              : Text(
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
                  : giftcardprovider.sliderlist.isEmpty
                      ? Center(child: noData('No Card Available'))
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
                      giftcardprovider.toActiveCatalog.isNotEmpty
                          ? showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.85,
                                        child: CatalogBottomSheet());
                                  },
                                );
                              },
                            )
                          : null;
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
                          giftcardprovider.toActiveCatalog['brand'] == null
                              ? Container()
                              : Text(
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
                  SizedBox(
                    height: height * 0.35,
                    child: giftcardprovider.cardloading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : giftcardprovider.allCard.length <= 0
                            ? Center(
                                child: noData('No Cards Available'),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.only(bottom: 30),
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
                                      // if()
                                      // var min = double.parse(currentindex['min']
                                      //     .replaceAll(',', ""));
                                      // var max = double.parse(currentindex['max']
                                      //     .replaceAll(',', ""));
                                      // print(min == max);

                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          settings: RouteSettings(
                                            name: GiftDetail.routeName,
                                          ),
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              GiftDetail(
                                            data: currentindex,
                                            isEqualMinMax:
                                                currentindex['price_type'] ==
                                                        "fixed"
                                                    ? false
                                                    : true,
                                          ),
                                          transitionDuration:
                                              Duration(seconds: 0),
                                        ),
                                      );
                                      // Navigator.pushNamed(
                                      //   context,
                                      //   '/gift_detail',
                                      //   arguments: {'data': currentindex,'isEqualMinMax':min==max?false:true},
                                      // );
                                    },
                                    leading: Container(
                                      width: 100,
                                      child: FadeInImage.memoryNetwork(
                                        placeholder: kTransparentImage,
                                        image: giftcardprovider
                                            .toActiveCatalog['card_image']
                                            .toString(),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text('${currentindex['name']}'),
                                    subtitle: priceType(currentindex),
                                    // ? Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: [
                                    //       Text(
                                    //           'Min price: ${currentindex['min'].replaceAll(',', "")} ${giftcardprovider.toActiveCountry['currency']['code']}'),
                                    //       Text(
                                    //           'Max price: ${currentindex['max'].replaceAll(',', "")} ${giftcardprovider.toActiveCountry['currency']['code']}'),
                                    //     ],
                                    //   )
                                    // : Text(
                                    //     'Price: ${currentindex['max'].replaceAll(',', "")} ${giftcardprovider.toActiveCountry['currency']['code']}'),
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

  Widget priceType(Map data) {
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);

    if (data['price_type'] == "list") {
      return Container(
        child: Wrap(
          children: [
            Text('Amount:'),
            Text(data['price']['list'].map((item) {
              if (giftcardprovider.toActiveCountry['currency']['code'] !=
                  'AED') {
                return (item * giftcardprovider.toActiveCountry['rate']['rate'])
                    .toStringAsPrecision(4);
              } else {
                return item;
              }
            }).join(', ')),
            Text(giftcardprovider.toActiveCountry['currency']['code'])
          ],
        ),
      );
    } else if (data['price_type'] == "range") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Min price: ${giftcardprovider.toActiveCountry['currency']['code'] != 'AED' ? (data['price']['range']['min'] * giftcardprovider.toActiveCountry['rate']['rate']).toStringAsFixed(4) : data['price']['range']['min'].toStringAsFixed(4)} ${giftcardprovider.toActiveCountry['currency']['code']}'),
          Text(
              'Max price: ${giftcardprovider.toActiveCountry['currency']['code'] != 'AED' ? (data['price']['range']['max'] * giftcardprovider.toActiveCountry['rate']['rate']).toStringAsFixed(4) : data['price']['range']['max']..toStringAsFixed(4)} ${giftcardprovider.toActiveCountry['currency']['code']}'),
        ],
      );
    } else if (data['price_type'] == "fixed") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Min price: ${giftcardprovider.toActiveCountry['currency']['code'] != 'AED' ? (data['price']['fixed']['min'] * giftcardprovider.toActiveCountry['rate']['rate']).toStringAsFixed(4) : data['price']['fixed']['min'].toStringAsFixed(4)} ${giftcardprovider.toActiveCountry['currency']['code']}'),
          Text(
              'Max price: ${giftcardprovider.toActiveCountry['currency']['code'] != 'AED' ? (data['price']['fixed']['max'] * giftcardprovider.toActiveCountry['rate']['rate']).toStringAsFixed(4) : data['price']['fixed']['max'].toStringAsFixed(4)} ${giftcardprovider.toActiveCountry['currency']['code']}'),
        ],
      );
    } else {
      return Container();
    }
  }
}
