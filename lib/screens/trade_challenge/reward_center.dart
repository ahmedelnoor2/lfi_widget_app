import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

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
          // Card(
          //   margin: EdgeInsets.all(12),
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Container(
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               SizedBox(
          //                 height: 5,
          //               ),
          //               Text(
          //                 '100 USDT ',
          //                 style: TextStyle(
          //                     fontSize: 18,
          //                     color: tradegreen,
          //                     fontWeight: FontWeight.bold),
          //               ),
          //               Text('Cash reward, easy to get',
          //                   style: TextStyle(fontWeight: FontWeight.w400)),
          //               Container(
          //                   padding: EdgeInsets.only(top: 10),
          //                   child: Text(
          //                     'Do tasks and get rewards ',
          //                     style: TextStyle(fontSize: 11),
          //                   )),
          //               Container(
          //                 padding: EdgeInsets.only(
          //                   top: 10,
          //                 ),
          //                 child: ElevatedButton(
          //                   onPressed: () {},
          //                   style: ElevatedButton.styleFrom(
          //                     primary: tradegreen, // background
          //                     onPrimary: Colors.white, // foreground
          //                   ),
          //                   child: Text('Reward Center'),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //         Container(
          //           height: 100,
          //           child: Image.asset('assets/img/tradechallenge.png'),
          //         )
          //       ],
          //     ),
          //   ),
          // ),
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
                        Text('0.00 USDT',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: tradegreen)),
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
                          Text('0.00 USDT',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: tradegreen)),
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
                              rewardrecords(context),
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

Widget rewardrecords(context) {
  final height = MediaQuery.of(context).size.height;
  final width = MediaQuery.of(context).size.width;

  return ListView.builder(
    shrinkWrap: true,
    scrollDirection: Axis.vertical,
    itemCount: 15,
    padding: EdgeInsets.only(top: 5, left: 8, right: 8),
    itemBuilder: (BuildContext context, int index) => Card(
      child:  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reward currency',
                    style: TextStyle(color: neturalcolor, fontSize: 14,height: 2),
                  ),
                  Text(
                    'USDT',
                    style: TextStyle(color: neturalcolor, fontSize: 14,height: 2),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Task type',
                    style: TextStyle(color: neturalcolor, fontSize: 14,height: 2),
                  ),
                  Text(
                    'Daily Task',
                    style: TextStyle(color: neturalcolor, fontSize: 14,height: 2),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Task name',
                    style: TextStyle(color: neturalcolor, fontSize: 14,height: 2),
                  ),
                  Text(
                    'Daily check-in',
                    style: TextStyle(color: neturalcolor, fontSize: 14,height: 2),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reward amount',
                    style: TextStyle(color: neturalcolor, fontSize: 14,height: 2),
                  ),
                  Text(
                    '0.01',
                    style: TextStyle(color: neturalcolor, fontSize: 14,height: 2),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Equivalent amount(USDT)',
                    style: TextStyle(color: neturalcolor, fontSize: 14,height: 2),
                  ),
                  Text(
                    '0.01',
                    style: TextStyle(color: neturalcolor, fontSize: 14,height: 2),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time',
                    style: TextStyle(color: neturalcolor, fontSize: 14,height: 2),
                  ),
                  Text(
                    '2023-01-09 10:45:51',
                    style: TextStyle(color: neturalcolor, fontSize: 14,height: 2),
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
