import 'package:flutter/material.dart';

import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/topup.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class TopupConfirmDrawer extends StatefulWidget {
  const TopupConfirmDrawer({Key? key}) : super(key: key);

  @override
  State<TopupConfirmDrawer> createState() => _TopupConfirmDrawerState();
}

class _TopupConfirmDrawerState extends State<TopupConfirmDrawer> {
  final TextEditingController searchController = TextEditingController();
  List _foundCountry = [];
  @override
  void initState() {
    // TODO: implement initState
    var topupProvider = Provider.of<TopupProvider>(context, listen: false);
    _foundCountry = topupProvider.allCountries;

    super.initState();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    // print(enteredKeyword);
    var topupProvider = Provider.of<TopupProvider>(context, listen: false);
    setState(() {
      _foundCountry = [];
    });
    List results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = topupProvider.allCountries;
    } else {
      topupProvider.allCountries.where(
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
    var topupProvider = Provider.of<TopupProvider>(context, listen: true);
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
                            topupProvider.setActiveCountry(data);
                            searchController.clear();
                            var userid = await auth.userInfo['id'];
                            Navigator.pop(context);
                            await topupProvider.getAllNetWorkprovider(
                                context,
                                auth,
                                userid,
                                {
                                  "country":
                                      topupProvider.toActiveCountry['isoName']
                                },
                                true);

                            // await topupProvider.getAllCard(
                            //     context, auth, userid);
                          },
                          title: Text(data['name']),
                          trailing: Text(data['currencyCode']),
                        );
                      },
                    )
                  : noData('No Data')),
        ],
      ),
    );
  }
}
