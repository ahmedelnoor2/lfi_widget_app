import 'dart:developer';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/referral.dart';

import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/referal/pages/myinvitation.dart';
import 'package:lyotrade/screens/referal/pages/myrewards.dart';


import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class Refralinvitation extends StatefulWidget {
  static const routeName = '/Refralinvitation_screen';

  const Refralinvitation({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _RefralinvitationState();
}

class _RefralinvitationState extends State<Refralinvitation> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  var currenttabindex = 0;
//TextEditingController generalcontroller = TextEditingController();
  var _pages = [
    Myinvitation(),
    Myrewards(),
  ];

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    );
  }



  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    var Refralinvitationprovider = Provider.of<ReferralProvider>(context, listen: false);
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
                    padding: EdgeInsets.only(right: 20),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.chevron_left),
                    ),
                  ),
                  Text(
                    'Invitation Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
      
           Container(
            child: Expanded(
              child: Column(
                children: [
                  PreferredSize(
                    preferredSize: Size.fromHeight(40),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TabBar(
                        onTap: (value) {
                          setState(() {
                            currenttabindex = value;
                          });
                        },
                        isScrollable: true,
                        controller: _tabController,
                        labelColor: whiteTextColor,
                        indicatorColor: selecteditembordercolour,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 1.0,
                        indicatorPadding:
                            EdgeInsets.symmetric(horizontal: 70.0),
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
                            width: _size.width * .4,
                            child: Tab(
                              text: 'My Invitation',
                            ),
                          ),
                          Container(
                            width: _size.width * .4,
                            child: Tab(
                              text: 'My Invitation Rewards',
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
          ),
        
      
    
        ]
      ),
    );
  }
}
