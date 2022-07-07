import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/notification/notifactionListingpage.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

class Notificationsscreen extends StatefulWidget {
  static const routeName = '/notification_screen';
  const Notificationsscreen({Key? key}) : super(key: key);

  @override
  State<Notificationsscreen> createState() => _NotificationsscreenState();
}

class _NotificationsscreenState extends State<Notificationsscreen> with SingleTickerProviderStateMixin{
  @override
 

  TabController? _tabController;

  var _pages = [
    NotificationListingpage(),
    NotificationListingpage(),
    NotificationListingpage(),
    NotificationListingpage(),
    NotificationListingpage(),
    NotificationListingpage(),
    NotificationListingpage(),
    NotificationListingpage(),
 
  ];

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(
      vsync: this,
      length: 8,
      initialIndex: 0,
    );
  }
  Widget build(BuildContext context) {
      final _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: hiddenAppBar(),
      body: SafeArea(
          child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 20),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.chevron_left),
                    ),
                  ),
                  Text(
                    'Messages Center',
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
          ),
          Expanded(
              child: Column(
                children: [
                  PreferredSize(
                    preferredSize: Size.fromHeight(40),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TabBar(
                        isScrollable: true,
                        controller: _tabController,
                        labelColor: whiteTextColor,
                        indicatorColor: selecteditembordercolour,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 1.0,
                        indicatorPadding:
                            EdgeInsets.symmetric(horizontal: 1.0),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: _size.width / 28.0,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: _size.width / 28.0,
                        ),
                        tabs: [
                          Container(
                            width: _size.width * .1,
                            child: Tab(
                              text: 'All',
                            ),
                          ),
                          Container(
                            width: _size.width * .3,
                            child: Tab(
                              text: 'System MSG',
                            ),
                          ),
                            Container(
                            width: _size.width * .3,
                            child: Tab(
                              text: 'Deposit/Withdraw',
                            ),
                          ),
                            Container(
                            width: _size.width * .2,
                            child: Tab(
                              text: 'Safety MSG',
                            ),
                          ),
                            Container(
                            width: _size.width * .2,
                            child: Tab(
                              text: 'KYC MSG',
                            ),
                          ),
                            Container(
                            width: _size.width * .3,
                            child: Tab(
                              text: 'OTC message',
                            ),
                          ),
                            Container(
                            width: _size.width * .3,
                            child: Tab(
                              text: 'Mining Pool',
                            ),
                          ),
                            Container(
                            width: _size.width * .2,
                            child: Tab(
                              text: 'Loan MSG',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(thickness: 1, height: 1),
               
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: _pages.map((Widget tab) {
                        return tab;
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          
        ],
      )),
    );
  }
}
