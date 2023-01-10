import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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
                        Text(
                          '100 USDT ',
                          style: TextStyle(
                              fontSize: 18,
                              color: tradegreen,
                              fontWeight: FontWeight.bold),
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
              height: height * 0.27,
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
                          onPressed: () {},
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
                    child: SizedBox(
                      height: height * 0.11,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: 15,
                        itemBuilder: (BuildContext context, int index) => Card(
                          color: Colors.white,
                          child: Container(
                            width: width * 0.30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/img/clip.png',
                                      color: index == 0 ? null : clipcolor,
                                    ),
                                    Text(
                                      index.toString(),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '0.01',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: tradegreen,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'USDT',
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
                          ),
                        ),
                      ),
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
                                  setState(() {
                                    // _tabIndicatorColor = value == 0 ? Colors.green : Colors.red;
                                  });
                                },
                                tabs: <Tab>[
                                  Tab(
                                    text: 'All in Progress',
                                  ),
                                  Tab(
                                    text: 'Beginner’s',
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
                              allprogressList(context),
                              Text('data'),
                              Text('data')
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

Widget allprogressList(context) {
  final height = MediaQuery.of(context).size.height;
  final width = MediaQuery.of(context).size.width;

  return ListView.builder(
    shrinkWrap: true,
    scrollDirection: Axis.vertical,
    itemCount: 15,
    padding: EdgeInsets.only(top: 20,left: 8,right: 8),
    itemBuilder: (BuildContext context, int index) => Card(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            '0.1 USDT',
                            style: TextStyle(color: trade_txtColour),
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
                                    color: Colors.black, fontSize: 10),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                    '2020-04-01 12:12:38',
                    style: TextStyle(color: neturalcolor, fontSize: 11),
                  ),
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
                        child: Image.asset('assets/img/tradech1.png')),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: width*0.55,
                          child: Text(
                            "Daily spot trading volumes ≥ 100 USDT ",
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
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.white,
                              ),
                              height: 6,
                            ),
                            Text(
                              "0.00/100 USDT",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
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
            Divider(color: Colors.white,)
          ],
        ),
      ),
    ),
  );
}
