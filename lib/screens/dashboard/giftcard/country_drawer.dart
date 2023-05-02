import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class CountryDrawer extends StatefulWidget {
  const CountryDrawer({Key? key}) : super(key: key);

  @override
  State<CountryDrawer> createState() => _CountryDrawerState();
}

class _CountryDrawerState extends State<CountryDrawer> {
  final TextEditingController searchController = TextEditingController();
  List _foundCountry = [];
  @override
  void initState() {
    // TODO: implement initState
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    _foundCountry = giftcardprovider.allCountries;

    super.initState();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    ;
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    setState(() {
      _foundCountry = [];
    });
    List results = [];
    if (enteredKeyword.isEmpty) {
      results = giftcardprovider.allCountries;
    } else {
      giftcardprovider.allCountries.where(
        (element) {
          if (element["name"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase())) {
            results.add(element);
          }
          return element["name"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase());
        },
      ).toList();
    }
    setState(() {
      _foundCountry = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
      ),
      width: width,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                Container(
                  padding: const EdgeInsets.only(left: 70),
                  child: const Text('Select Country'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
            ),
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
          SizedBox(
              height: height * 0.8,
              child: _foundCountry.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: _foundCountry.length,
                      itemBuilder: (context, index) {
                        var data = _foundCountry[index];

                        ///  print(data['rate']['rate']);

                        return ListTile(
                          onTap: () async {
                            giftcardprovider.setActiveCountry(data);

                            searchController.clear();
                            var userid = await auth.userInfo['id'];
                            Navigator.pop(context);
                            await giftcardprovider.getAllCatalog(
                                context,
                                auth,
                                userid,
                                {
                                  "country":
                                      giftcardprovider.toActiveCountry['iso2']
                                },
                                true);

                            await giftcardprovider.getAllCard(
                                context, auth, userid);
                          },
                          title: Text(data['name']),
                          trailing: Text(data['currency']['code']),
                        );
                      },
                    )
                  : noData('No Data')),
        ],
      ),
    );
  }
}
