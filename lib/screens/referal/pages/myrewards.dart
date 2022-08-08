import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/referral.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Myrewards extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyrewardsState();
}

class _MyrewardsState extends State<Myrewards> {
    RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  GlobalKey _contentKey = GlobalKey();
  GlobalKey _refresherKey = GlobalKey();
  var pagesized = 10;
  @override
  void initState() {
    getMyinvitationRewards();
    super.initState();
  }

  Future<void> getMyinvitationRewards() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var referalprovider = Provider.of<ReferralProvider>(context, listen: false);

    await referalprovider.getMyInvitationRewards(context, auth,{"page": "1", "pageSize": "$pagesized"});
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    var referalprovider = Provider.of<ReferralProvider>(context, listen: true);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 30, left: 16, right: 15, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Registerred Account',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),
              Text(
                'USDTValuation',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: referalprovider.isinvitationrewards
              ? SizedBox(
                  height: MediaQuery.of(context).size.height / 1.3,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : referalprovider.myinvitationrewardslist.isEmpty
                  ? Center(child: noData('No Rewards'))
                  : SmartRefresher
                  (
                           key: _refresherKey,
                        controller: _refreshController,
                        enablePullDown: false,
                        enablePullUp: true,
                        physics: const BouncingScrollPhysics(),
                        footer: ClassicFooter(
                          loadStyle: LoadStyle.ShowWhenLoading,
                          completeDuration: Duration(milliseconds: 500),
                        ),
                        onLoading: (() async {
                          setState(() {
                          pagesized += 10;
                          });
                          return Future.delayed(
                            Duration(seconds: 2),
                            () async {
                              await referalprovider.getMyInvitationRewards(context, auth,{"page": "1", "pageSize": "$pagesized"});

                              if (mounted) setState(() {});
                              _refreshController.loadFailed();
                            },
                          );
                        }),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: referalprovider.myinvitationrewardslist.length,
                        itemBuilder: (context, index) {
                          var emailText = referalprovider
                              .myinvitationrewardslist[index]['userAccountNum']
                              .toString();
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 8, bottom: 8),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            emailText.length > 30
                                                ? '${emailText.substring(0, 15)}.....${emailText.substring(emailText.length - 10, emailText.length)}'
                                                : emailText,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(top: 5),
                                            child: Text(
                                              '${double.parse(referalprovider.myinvitationrewardslist[index]['rewardAmount']).toStringAsPrecision(8)}' +
                                                  " " +
                                                  '${referalprovider.myinvitationrewardslist[index]['rewardCoinSymbol']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                              '${double.parse(referalprovider.myinvitationrewardslist[index]['conversionAmount']).toStringAsPrecision(3)}' +
                                                  ' USDT',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              )),
                                          Container(
                                            padding: EdgeInsets.only(top: 5),
                                            child: Text(
                                              DateFormat('yyy-mm-dd hh:mm:ss')
                                                  .format(DateTime
                                                      .fromMicrosecondsSinceEpoch(
                                                          referalprovider
                                                                  .myinvitationrewardslist[
                                                              index]['sendTime'])),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: seconadarytextcolour,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ),
        ),
      ],
    );
  }
}
