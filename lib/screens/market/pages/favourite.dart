import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    getFavouriteMarket();
  }

  Future<void> getFavouriteMarket() async {
    var public = Provider.of<Public>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);

    await public.getFavMarketList(context, {
      'token': "${auth.loginVerificationToken}",
      'userId': "${auth.userInfo['id']}",
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    var public = Provider.of<Public>(context, listen: false);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: public.favMarketList.isEmpty
                ? noData('No Favorites')
                : ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    shrinkWrap: true,
                    itemCount: public.favMarketList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(
                          Icons.star,
                          size: 20,
                          color: seconadarytextcolour,
                        ),
                        minLeadingWidth: 5,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'lyo',
                                  // '${_market['showName'].split('/')[0]}',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'market',
                                  //  ' /${_market['showName'].split('/')[1]}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    Navigator.pushNamed(context, '/trade');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      top: 5,
                                      bottom: 5,
                                      right: 10,
                                    ),
                                    child: Text(
                                      'Trade',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: linkColor,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    // await public.setActiveMarket(_market);
                                    Navigator.pushNamed(
                                        context, '/kline_chart');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      top: 5,
                                      bottom: 5,
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: Text(
                                      'Info',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: linkColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              '',
                              style: TextStyle(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
    ;
  }
}
