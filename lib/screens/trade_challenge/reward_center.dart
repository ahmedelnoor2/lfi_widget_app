import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/trade_challenge.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RewardCenterScreen extends StatefulWidget {
  static const routeName = '/reward_center';
  const RewardCenterScreen({Key? key}) : super(key: key);

  @override
  State<RewardCenterScreen> createState() => _RewardCenterScreenState();
}

class _RewardCenterScreenState extends State<RewardCenterScreen>
    with TickerProviderStateMixin {
  late final TabController _tabtradechallengController =
      TabController(length: 3, vsync: this);
  var rewardPage = 1;
  var rewardPageSize = 10;

  var user_withdrawalpagesized = 10;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  GlobalKey _refresherKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRewardCenter();
    getRewardRecord();
    getRewardOverview();
    getUserWithDrawalRecord();
  }

  // get reward center //
  Future<void> getRewardCenter() async {
    var tradeChallengeProvider =
        Provider.of<TradeChallenge>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    tradeChallengeProvider.getRewardCenter(context, auth);
  }

  ///Reward record///
  Future<void> getRewardRecord() async {
    var tradeChallengeProvider =
        Provider.of<TradeChallenge>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    tradeChallengeProvider.getRewardRecord(
        context, auth, {"page": '$rewardPage', "pageSize": '$rewardPageSize'});
  }

// Reward overview///
  Future<void> getRewardOverview() async {
    var tradeChallengeProvider =
        Provider.of<TradeChallenge>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    tradeChallengeProvider.getRewardOverview(
      context,
      auth,
    );
  }

  //// User With Drawal ///

  Future<void> getUserWithDrawalRecord() async {
    var tradeChallengeProvider =
        Provider.of<TradeChallenge>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    tradeChallengeProvider.getUserWithDrawalRecord(
        context, auth, {"page": '1', "pageSize": '$user_withdrawalpagesized'});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var tradeChallengeProvider =
        Provider.of<TradeChallenge>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

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
                    'Trade Challenge',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(
            thickness: 1,
            height: 1,
          ),
          Card(
            margin: EdgeInsets.all(12),
            child: Container(
              height: height * 0.27,
              padding: EdgeInsets.all(8),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text('Withdrawn',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                height: 2)),
                        Row(
                          children: [
                            Text(
                                tradeChallengeProvider
                                        .rewardcenter['withdrewAmount'] ??
                                    '',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: tradegreen)),
                            Text(' USDT',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: tradegreen)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      height: 95.0,
                      width: 1.5,
                      color: Colors.white30,
                      margin: const EdgeInsets.only(
                          left: 50.0, right: 10.0, top: 10),
                    ),
                    Container(
                      width: width * 0.50,
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pending Withdrawal',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  height: 2)),
                          Row(
                            children: [
                              Text(
                                  tradeChallengeProvider
                                          .rewardcenter['unWithdrawAmount'] ??
                                      '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: tradegreen)),
                              Text(' USDT',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: tradegreen))
                            ],
                          ),
                          Text(
                              'Also need 1.98 USDT to withdraw  to the spot account',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  height: 2))
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.only(top: 5),
                    child: LyoButton(
                      onPressed: () {},
                      text: 'Withdraw',
                      active: true,
                      activeColor: tradechallengbtn,
                      isLoading: false,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          Expanded(
              flex: 1,
              child: Card(
                margin: EdgeInsets.all(0),
                child: Container(
                    width: width,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              // height: 100,
                              width: width,
                              child: TabBar(
                                indicatorSize: TabBarIndicatorSize.label,
                                indicatorColor: tradegreen,
                                labelColor: tradegreen,
                                unselectedLabelColor: Colors.white,
                                isScrollable: true,
                                onTap: (value) {
                                  setState(() {
                                    // _tabIndicatorColor = value == 0 ? Colors.green : Colors.red;
                                  });
                                },
                                tabs: <Tab>[
                                  Tab(
                                    text: 'Reward record',
                                  ),
                                  Tab(
                                    text: 'Reward Overview',
                                  ),
                                  Tab(
                                    text: 'Withdrawal Record',
                                  ),
                                ],
                                controller: _tabtradechallengController,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 0,
                          color: Color(0xff5E6292),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabtradechallengController,
                            children: [
                              tradeChallengeProvider.isloadingrewardRecord
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : tradeChallengeProvider.rewardRecord.isEmpty
                                      ? noData("No Data")
                                      : SmartRefresher(
                                          key: _refresherKey,
                                          controller: _refreshController,
                                          enablePullDown: false,
                                          enablePullUp: true,
                                          physics: BouncingScrollPhysics(),
                                          footer: ClassicFooter(
                                            loadStyle:
                                                LoadStyle.ShowWhenLoading,
                                            completeDuration:
                                                Duration(milliseconds: 500),
                                          ),
                                          onLoading: (() async {
                                            setState(() {
                                              rewardPageSize += 10;
                                              getRewardRecord();
                                            });
                                            return Future.delayed(
                                              Duration(seconds: 2),
                                              () async {
                                                if (mounted) setState(() {});
                                                _refreshController
                                                    .loadComplete();
                                              },
                                            );
                                          }),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount: tradeChallengeProvider
                                                .rewardRecord.length,
                                            padding: EdgeInsets.only(
                                                top: 5, left: 8, right: 8),
                                            itemBuilder: (BuildContext context,
                                                    int index) =>
                                                Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Reward currency',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                        Text(
                                                          tradeChallengeProvider
                                                                      .rewardRecord[
                                                                  index]['coin'] ??
                                                              '',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Task type',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                        Text(
                                                          'Daily Task',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Task name',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                        Text(
                                                          'Daily check-in',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Reward amount',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                        Text(
                                                          tradeChallengeProvider
                                                                          .rewardRecord[
                                                                      index]
                                                                  ['amount'] ??
                                                              '',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Equivalent amount(USDT)',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                        Text(
                                                          tradeChallengeProvider
                                                                          .rewardRecord[
                                                                      index][
                                                                  'usdtAmount'] ??
                                                              '',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Time',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                        tradeChallengeProvider
                                                                            .rewardRecord[
                                                                        index][
                                                                    'receiveTime'] ==
                                                                null
                                                            ? Container()
                                                            : Text(
                                                                DateFormat(
                                                                        'dd-MM-y H:mm')
                                                                    .format(DateTime
                                                                        .fromMillisecondsSinceEpoch(
                                                                            int.parse('${tradeChallengeProvider.rewardRecord[index]['receiveTime']}'))),
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        11),
                                                              )
                                                      ],
                                                    ),
                                                    Divider()
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                              tradeChallengeProvider.isloadingrewardOverview
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : tradeChallengeProvider
                                          .rewardRecordOverview.isEmpty
                                      ? noData("No Data")
                                      : rewardOverview(
                                          context,
                                          tradeChallengeProvider
                                              .rewardRecordOverview),
                              tradeChallengeProvider.isLoadingWithDrawal
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : tradeChallengeProvider
                                          .userRecordWithDrawal.isEmpty
                                      ? noData("No Data")
                                      : SmartRefresher(
                                          key: _refresherKey,
                                          controller: _refreshController,
                                          enablePullDown: false,
                                          enablePullUp: true,
                                          physics: BouncingScrollPhysics(),
                                          footer: ClassicFooter(
                                            loadStyle:
                                                LoadStyle.ShowWhenLoading,
                                            completeDuration:
                                                Duration(milliseconds: 500),
                                          ),
                                          onLoading: (() async {
                                            setState(() {
                                              user_withdrawalpagesized += 10;
                                              getUserWithDrawalRecord();
                                            });
                                            return Future.delayed(
                                              Duration(seconds: 2),
                                              () async {
                                                if (mounted) setState(() {});
                                                _refreshController
                                                    .loadComplete();
                                              },
                                            );
                                          }),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount: tradeChallengeProvider
                                                .userRecordWithDrawal.length,
                                            padding: EdgeInsets.only(
                                                top: 5, left: 8, right: 8),
                                            itemBuilder: (BuildContext context,
                                                    int index) =>
                                                Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Reward currency',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                        Text(
                                                          tradeChallengeProvider
                                                                      .userRecordWithDrawal[
                                                                  index]['coin'] ??
                                                              '',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Task type',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                        Text(
                                                          'Daily Task',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Task name',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                        Text(
                                                          'Daily check-in',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Reward amount',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                        Text(
                                                          tradeChallengeProvider
                                                                          .userRecordWithDrawal[
                                                                      index]
                                                                  ['amount'] ??
                                                              '',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Equivalent amount(USDT)',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                        Text(
                                                          tradeChallengeProvider
                                                                          .userRecordWithDrawal[
                                                                      index][
                                                                  'usdtAmount'] ??
                                                              '',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Time',
                                                          style: TextStyle(
                                                              color:
                                                                  neturalcolor,
                                                              fontSize: 14,
                                                              height: 2),
                                                        ),
                                                        tradeChallengeProvider
                                                                            .userRecordWithDrawal[
                                                                        index][
                                                                    'receiveTime'] ==
                                                                null
                                                            ? Container()
                                                            : Text(
                                                                DateFormat(
                                                                        'dd-MM-y H:mm')
                                                                    .format(DateTime
                                                                        .fromMillisecondsSinceEpoch(
                                                                            int.parse('${tradeChallengeProvider.userRecordWithDrawal[index]['receiveTime']}'))),
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        11),
                                                              )
                                                      ],
                                                    ),
                                                    Divider()
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                            ],
                          ),
                        )
                      ],
                    )),
              ))
        ],
      ),
    );
  }
}

Widget rewardOverview(
  context,
  rewardOverviewList,
) {
  final height = MediaQuery.of(context).size.height;
  final width = MediaQuery.of(context).size.width;
  return ListView.builder(
    shrinkWrap: true,
    scrollDirection: Axis.vertical,
    itemCount: rewardOverviewList.length,
    padding: EdgeInsets.only(top: 5, left: 8, right: 8),
    itemBuilder: (BuildContext context, int index) => Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reward currency',
                  style:
                      TextStyle(color: neturalcolor, fontSize: 14, height: 2),
                ),
                Text(
                  rewardOverviewList[index]['coin'] ?? '',
                  style:
                      TextStyle(color: neturalcolor, fontSize: 14, height: 2),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Rewards',
                  style:
                      TextStyle(color: neturalcolor, fontSize: 14, height: 2),
                ),
                Text(
                  rewardOverviewList[index]['rewardedAmount'] ?? '',
                  style:
                      TextStyle(color: neturalcolor, fontSize: 14, height: 2),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Withdrawn',
                  style:
                      TextStyle(color: neturalcolor, fontSize: 14, height: 2),
                ),
                Text(
                  rewardOverviewList[index]['withdrewAmount'] ?? '',
                  style:
                      TextStyle(color: neturalcolor, fontSize: 14, height: 2),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending Withdrawal',
                  style:
                      TextStyle(color: neturalcolor, fontSize: 14, height: 2),
                ),
                Text(
                  rewardOverviewList[index]['unWithdrawAmount'] ?? '',
                  style:
                      TextStyle(color: neturalcolor, fontSize: 14, height: 2),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending Withdrawal Equivalent(USDT)',
                  style:
                      TextStyle(color: neturalcolor, fontSize: 14, height: 2),
                ),
                Text(
                  rewardOverviewList[index]['unWithdrawUsdtAmount'] ??
                      ''
                          '',
                  style:
                      TextStyle(color: neturalcolor, fontSize: 14, height: 2),
                ),
              ],
            ),
            Divider()
          ],
        ),
      ),
    ),
  );
}
