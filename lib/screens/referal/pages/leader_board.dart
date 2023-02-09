import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/providers/referral.dart';

import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/no_data.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class LeaderBoard extends StatefulWidget {
  static const routeName = '/LeaderBoard_screen';

  const LeaderBoard({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  @override
  void initState() {
    super.initState();
    getrewards();
  }

  Future<void> getrewards() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var referalprovider = Provider.of<ReferralProvider>(context, listen: false);

    await referalprovider.getrewards(context, auth);
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    var referalprovider = Provider.of<ReferralProvider>(context, listen: true);
    var languageprovider = Provider.of<LanguageChange>(context, listen: true);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Column(
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
                    languageprovider.getlanguage['referral_reward_rank']
                            ['title'] ??
                        'List of reward rankings',
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
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  languageprovider.getlanguage['referral_reward_rank']
                          ['text'] ??
                      'Reward rankings are updated hourly',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: referalprovider.isrewards
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ListView.builder(
                      itemCount: referalprovider.rewardlist.length,
                      itemBuilder: (context, ind) {
                        var index = ind + 1;
                        return referalprovider.rewardlist.isEmpty
                            ? Center(child: noData('No Rewards'))
                            : Container(
                                padding: EdgeInsets.all(2),
                                margin: EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                  color: listcolor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: ListTile(
                                  leading: ClipOval(
                                    child: Container(
                                      color: clipCircle[
                                              'out_${index.toString()}'] ??
                                          listselectcolor,
                                      height: 40,
                                      width: 40,
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        child: CircleAvatar(
                                          backgroundColor: clipCircle[
                                                  'in_${index.toString()}'] ??
                                              listcolorinner,
                                          child: Text(
                                            index.toString(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: neturalcolor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    referalprovider.rewardlist[ind]['rewardUid']
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: Text(
                                    referalprovider.rewardlist[ind]
                                            ['totalConversionRewardAmount']
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                      },
                    ),
            ),
          )
        ],
      ),
    );
  }
}
