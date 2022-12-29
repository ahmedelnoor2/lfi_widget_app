import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';
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
                      onChanged: (text) async {
                        if (text.length > 0) {
                          searching = true;
                          filtered.value = [];
                          giftcardprovider.allCountries.forEach((country) {
                            if (country['currency']['name']
                                    .toString()
                                    .toUpperCase()
                                    .contains(text.toUpperCase()) ||
                                country['currency']['name']
                                    .toString()
                                    .toLowerCase()
                                    .contains(text.toLowerCase())) {
                              filtered.value.add(country);
                            }
                          });
                        } else {
                          searching = false;
                          filtered.value = [];
                        }
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
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: searching
                        ? filtered.value.length
                        : giftcardprovider.allCountries.length,
                    itemBuilder: (context, index) {
                      var data = giftcardprovider.allCountries[index];

                      return ListTile(
                        onTap: () async {
                          giftcardprovider.setActiveCountry(data);
                          searchController.clear();
                          var userid = await auth.userInfo['id'];
                          Navigator.pop(context);
                          await giftcardprovider.getAllCard(
                              context, auth, userid);
                        },
                        // leading: CircleAvatar(
                        //   radius: width * 0.035,
                        //   child: Image.network(
                        //     '${public.publicInfoMarket['market']['coinList'][_asset['coin']]['icon']}',
                        //   ),
                        // ),
                        title: Text(data['name']),
                        trailing: Text(data['currency']['code']),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}
