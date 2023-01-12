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
import 'package:skeletons/skeletons.dart';

class TradeChallengeScreen extends StatefulWidget {
  static const routeName = '/trade_challenge';
  const TradeChallengeScreen({Key? key}) : super(key: key);

  @override
  State<TradeChallengeScreen> createState() => _TradeChallengeScreenState();
}

class _TradeChallengeScreenState extends State<TradeChallengeScreen>
    with TickerProviderStateMixin {
  late final TabController _tabtradechallengController =
      TabController(length: 3, vsync: this);
  var type;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRewardCenter();
    getUserTask();
  }

  // get reward center //
  Future<void> getRewardCenter() async {
    var tradeChallengeProvider =
        Provider.of<TradeChallenge>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    tradeChallengeProvider.getTaskCenter(context, auth);
  }
  Future<void> getDoDailyCheckIN() async {
    var tradeChallengeProvider =
        Provider.of<TradeChallenge>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    tradeChallengeProvider.getTaskCenter(context, auth);
  }

  // User Task ///

  Future<void> getUserTask() async {
    var tradeChallengeProvider =
        Provider.of<TradeChallenge>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    tradeChallengeProvider.getUserTask(context, auth, {"type": type});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var tradeChallengeProvider =
        Provider.of<TradeChallenge>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

    var checkedInDay = tradeChallengeProvider.taskCenter['signInInfo']['seriateSignInNum']-1;

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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              tradeChallengeProvider
                                      .taskCenter['titleRewardAmount'] ??
                                  '',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: tradegreen,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 5),
                              child: tradeChallengeProvider
                                          .taskCenter['signInInfo'] ==
                                      null
                                  ? Text('')
                                  : Text(
                                      tradeChallengeProvider
                                                  .taskCenter['signInInfo']
                                              ['rewardCoin'] ??
                                          '',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: tradegreen,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ],
                        ),
                        Text('Cash reward, easy to get',
                            style: TextStyle(fontWeight: FontWeight.w400)),
                        Container(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              'Do tasks and get rewards ',
                              style: TextStyle(fontSize: 11),
                            )),
                        Container(
                          padding: EdgeInsets.only(
                            top: 10,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/reward_center');
                            },
                            style: ElevatedButton.styleFrom(
                              primary: tradegreen, // background
                              onPrimary: Colors.white, // foreground
                            ),
                            child: Text('Reward Center'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Image.asset('assets/img/tradechallenge.png'),
                  )
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.only(bottom: 15),
            child: Container(
              height: height * 0.25,
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text('Check in for 0 Consecutive Days  ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  height: 2)),
                          Text(
                              'Check in consecutively for 7 days to enjoy double benefits',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  color: neturalcolor)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: 10,
                        ),
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () {
                            var checkInAmount = checkedInDay >= 0 ? tradeChallengeProvider.taskCenter['signInInfo']['rewards'][checkedInDay] : 0;

                             showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return Container(
                                  height: height*0.50,
                                  child:Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: (() {
                                          Navigator.pop(context);
                                        }),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Icon(Icons.close),
                                            Text(checkInAmount),
                                        ],),
                                      ),
                                    )

                                  ],),);
                              },
                            );
                          },
                        );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: tradechallengbtn, // background
                            onPrimary: Colors.white, // foreground
                          ),
                          child: Text(
                            'Check in Now',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: tradeChallengeProvider.isloadingtaskCenter
                        ? SizedBox(
                            height: height * 0.11,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                itemBuilder: (BuildContext context, int index) {
                                  [index];
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SkeletonAvatar(
                                      style: SkeletonAvatarStyle(
                                          shape: BoxShape.rectangle,
                                          width: 140,
                                          height: height * 0.11),
                                    ),
                                  );
                                }),
                          )
                        : SizedBox(
                            height: height * 0.11,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: tradeChallengeProvider
                                    .taskCenter['signInInfo']['rewards'].length,
                                itemBuilder: (BuildContext context, int index) {

                                  var currentindex = index + 1;
                                  var data = tradeChallengeProvider
                                          .taskCenter['signInInfo']['rewards']
                                      [index];
                                  return Container(
                                    width: width * 0.35,
                                    margin: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              height: height * 0.11,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(4)),
                                              ),
                                              child: Image.asset(
                                                'assets/img/clip.png',
                                                fit: BoxFit.cover,
                                                color: checkedInDay >= index ? null : clipcolor,
                                              ),
                                            ),
                                            Text(
                                              currentindex.toString(),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(right: 25),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                data ?? '',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: tradegreen,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                tradeChallengeProvider
                                                                .taskCenter[
                                                            'signInInfo']
                                                        ['rewardCoin'] ??
                                                    '',
                                                style: TextStyle(
                                                  height: 0.8,
                                                  fontSize: 10,
                                                  color: trade_txtColour,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                  ),
                ],
              ),
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
                              width: width * 0.85,
                              child: TabBar(
                                indicatorSize: TabBarIndicatorSize.label,
                                indicatorColor: tradegreen,
                                labelColor: tradegreen,
                                unselectedLabelColor: Colors.white,
                                isScrollable: true,
                                onTap: (value) {
                                  if (value == 1) {
                                    setState(() {
                                      type = 1;
                                      getUserTask();
                                    });
                                  } else if (value == 2) {
                                    type = 0;
                                    getUserTask();
                                  } else {
                                    type = null;
                                    getUserTask();
                                  }
                                },
                                tabs: <Tab>[
                                  Tab(
                                    text: 'All in Progress',
                                  ),
                                  Tab(
                                    text: 'Beginner’s Task',
                                  ),
                                  Tab(
                                    text: 'Daily Task',
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
                              usertasklist(
                                  context, tradeChallengeProvider.usertask),
                              usertasklist(
                                  context, tradeChallengeProvider.usertask),
                              usertasklist(
                                  context, tradeChallengeProvider.usertask),
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

Widget usertasklist(context, usertask) {
  final height = MediaQuery.of(context).size.height;
  final width = MediaQuery.of(context).size.width;
  var tradeChallengeProvider =
      Provider.of<TradeChallenge>(context, listen: true);
  return tradeChallengeProvider.isloadinUserTask
      ? Center(child: CircularProgressIndicator())
      : usertask.isEmpty
          ? noData('No Data')
          : ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: usertask.length,
              padding: EdgeInsets.only(top: 20, left: 8, right: 8),
              itemBuilder: (BuildContext context, int index) {
                var currentindex = usertask[index];

                return Card(
                  child: Container(
                    width: width * 0.30,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 55),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 140,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: tradelistcolor,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  color: tradelistcolor,
                                ),
                                height: 20,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(
                                        currentindex['rewardAmount'] +
                                            " " +
                                            currentindex['rewardCoin'],
                                        style:
                                            TextStyle(color: trade_txtColour),
                                      ),
                                    ),
                                    Container(
                                      width: 70,
                                      height: 19,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Center(
                                          child: Text(
                                            'Cash Reward',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                          currentindex['remindTime']==null?Container():Text(
                            DateFormat('dd-MM-y H:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(int.parse(
                                    '${currentindex['remindTime']}'))),
                            style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 11),)
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    width: 55,
                                    child:
                                        Image.asset('assets/img/tradech1.png')),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: width * 0.55,
                                      child: Text(
                                        "Daily spot trading volumes ≥ " +
                                            currentindex['targetValue']
                                                .toString() +
                                            ' ' +
                                            currentindex['targetCoin']
                                                .toString(),
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 140,
                                          margin: EdgeInsets.only(right: 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: Colors.white,
                                          ),
                                          height: 6,
                                        ),
                                        Text(
                                          "${currentindex['finishedAmount']}/" +
                                              currentindex['targetValue']
                                                  .toString() +
                                              ' ' +
                                              currentindex['targetCoin']
                                                  .toString(),
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 10, left: 15),
                                  height: 35,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      primary: tradechallengbtn, // background
                                      onPrimary: Colors.white, // foreground
                                    ),
                                    child: Text(
                                      'Complete',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                );
              });
}

const _shimmerGradient = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Color(0xFFF4F4F4),
    Color(0xFFEBEBF4),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);
