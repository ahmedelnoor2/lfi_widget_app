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

class TopupNetworkBottomSheet extends StatefulWidget {
  const TopupNetworkBottomSheet({Key? key}) : super(key: key);

  @override
  State<TopupNetworkBottomSheet> createState() =>
      _TopupNetworkBottomSheetState();
}

class _TopupNetworkBottomSheetState extends State<TopupNetworkBottomSheet> {
  final TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();

  List _foundCountry = [];
  @override
  void initState() {
    // TODO: implement initState
    var topupProvider = Provider.of<TopupProvider>(context, listen: false);
    _foundCountry = topupProvider.allTopupNetwork;
    super.initState();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    // print(enteredKeyword);
    var topupProvider = Provider.of<TopupProvider>(context, listen: false);
    //print(topupProvider.allCatalog);
    setState(() {
      _foundCountry = [];
    });
    List results = [];
    if (enteredKeyword.isEmpty) {
      results = topupProvider.allTopupNetwork;
    } else {
      topupProvider.allTopupNetwork.where(
        (element) {
          //  print(element["brand"].toString());
          if (element["operatorName"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase())) {
            results.add(element);
          }
          return element["operatorName"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase());
        },
      ).toList();
    }
    setState(() {
      _foundCountry = results;
    });
  }

  Future<void> getEstimateRate() async {
    var topupProvider = Provider.of<TopupProvider>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);
    var userid = await auth.userInfo['id'];
    await topupProvider.getEstimateRate(context, auth, userid, {
      "currency": "${topupProvider.toActiveCountry['currencyCode']}",
      "payment": topupProvider.topupamount,
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    var topupProvider = Provider.of<TopupProvider>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);
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
                    if (searchFocus.hasFocus) searchFocus.unfocus();
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
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: SizedBox(
              height: width * 0.13,
              child: TextField(
                onChanged: (value) async {
                  _runFilter(value);
                },
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _foundCountry.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: _foundCountry.length,
                    itemBuilder: (context, index) {
                      var data = _foundCountry[index];

                      return InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          var userid = await auth.userInfo['id'];
                          topupProvider.setActiveNetWorkprovider(data);

                          // await topupProvider.getAllNetWorkprovider(
                          //     context,
                          //     auth,
                          //     userid,
                          //     {
                          //       "country":
                          //           topupProvider.toActiveCountry['isoName']
                          //     },
                          //     true);

                          getEstimateRate();
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
                                  data['logo'][0] == null
                                      ? Container()
                                      : Container(
                                          width: 100,
                                          child: FadeInImage.memoryNetwork(
                                            placeholder: kTransparentImage,
                                            image: data['logo'][0].toString(),
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
                                        Text(data['operatorName'] ?? ''),
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
                      );
                    },
                  )
                : noData('Empty'),
          ),
        ],
      ),
    );
  }
}
