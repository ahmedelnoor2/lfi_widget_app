import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class CatalogBottomSheet extends StatefulWidget {
  const CatalogBottomSheet({Key? key}) : super(key: key);

  @override
  State<CatalogBottomSheet> createState() => _CatalogBottomSheetState();
}

class _CatalogBottomSheetState extends State<CatalogBottomSheet> {
  final TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  ValueNotifier<List<Map>> filtered = ValueNotifier<List<Map>>([]);
  bool searching = false;
  @override
  Widget build(BuildContext context) {
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);
    return ValueListenableBuilder<List>(
        valueListenable: filtered,
        builder: (context, value, _) {
          return Container(
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
                          searchController.clear();
                          searching = false;
                          filtered.value = [];
                          if (searchFocus.hasFocus) searchFocus.unfocus();
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.close,
                          color: secondaryTextColor,
                          size: 20,
                        ),
                      ),
                      // Container(
                      //   padding: const EdgeInsets.only(left: 70),
                      //   child: const Text('Select Country'),
                      // ),
                    ],
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.only(
                //     left: 15,
                //     right: 15,
                //   ),
                //   child: SizedBox(
                //     height: width * 0.13,
                //     child: TextField(
                //       onChanged: (text) async {
                //         if (text.length > 0) {
                //           searching = true;
                //           filtered.value = [];
                //           giftcardprovider.allCountries.forEach((country) {
                //             if (country['name']
                //                 .toString()
                //                 .toLowerCase()
                //                 .contains(text.toLowerCase())||
                //                   country['name'].toString().toUpperCase().contains(text)) {
                //               filtered.value.add(country);
                //             }
                //           });
                //         } else {
                //           searching = false;
                //           filtered.value = [];
                //         }
                //       },

                //       controller: searchController,
                //       decoration: const InputDecoration(
                //         labelText: "Search",
                //         hintText: "Search",
                //         prefixIcon: Icon(Icons.search),
                //         border: OutlineInputBorder(
                //           borderRadius: BorderRadius.all(
                //             Radius.circular(25.0),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: giftcardprovider.allCatalog.length,
                    itemBuilder: (context, index) {
                      var data = giftcardprovider.allCatalog[index];
                      return (data['iso2'] ==
                              giftcardprovider.toActiveCountry['iso2'])
                          ? InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                giftcardprovider.settActiveCatalog(data);
//print(giftcardprovider.toActiveCatalog);
                                var userid = await auth.userInfo['id'];
                                await giftcardprovider.getAllCatalog(
                                    context, auth, userid, {
                                  "country":
                                      giftcardprovider.toActiveCountry['iso2'],
                                }, false);
                                await giftcardprovider.getAllCard(
                                    context, auth, userid);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 10.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 70,
                                    color: Color(0xff292C51),
                                    child: Row(
                                      children: <Widget>[
                                        data['card_image'] == null
                                            ? Container()
                                            : Container(
                                                width: 100,
                                                child:
                                                    FadeInImage.memoryNetwork(
                                                  placeholder:
                                                      kTransparentImage,
                                                  image: data['card_image']
                                                      .toString(),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(data['brand'] ?? ''),
                                              // Text(
                                              //     'expiration: ' + data['expiration'],
                                              //     style:
                                              //         TextStyle(color: greyTextColor))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container();
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}
