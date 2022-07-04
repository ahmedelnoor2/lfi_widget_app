import 'package:flutter/material.dart';


import 'package:lyotrade/screens/common/header.dart';

import 'package:lyotrade/screens/referal/pages/commision_record.dart';
import 'package:lyotrade/screens/referal/pages/position_statistics.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

class Referal extends StatefulWidget {
  static const routeName = '/referal_screen';
  @override
  State<StatefulWidget> createState() => _ReferalState();
}

class _ReferalState extends State<Referal> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  var _pages = [
    CommisonPage(),
   Postionpage(),
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

// Step 1.
  String dropdownValue = 'USDT';
   String dropdownValue1 = 'UID';

  @override
  Widget build(BuildContext context) {
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
                    'Referral',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(thickness: 1, height: 1),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.44,
                height: 62,
                color: selectboxcolour,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Total invitees',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Text('100',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                      ),
                    ]),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.44,
                height: 62,
                color: selectboxcolour,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Total income',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Text('0.09244421 USDT',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                      ),
                    ]),
              ),
            ],
          ),
          SizedBox(
            height: 20,
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
                              text: 'Commission record',
                            ),
                          ),
                          Container(
                            width: _size.width * .4,
                            child: Tab(
                              text: 'Position statistics',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(thickness: 1, height: 1),
                  _buildTopBar(context),
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
        ],
      ),
    );
  }

  Widget _buildTopBar(context) {
    final _size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 30,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
  decoration: BoxDecoration(
      color:  selectboxcolour, borderRadius: BorderRadius.circular(5)),
              child: DropdownButton<String>(
                underline: SizedBox(),
                value: dropdownValue,
                items: <String>['Eth', 'Eth', 'USDT', 'Eth']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                    
                      value,
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
              ),
            ),
          ),
          SizedBox(width: 5,),
          Expanded(
            flex: 1,
            child: Container(
               height: 30,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
  decoration: BoxDecoration(
      color:  selectboxcolour, borderRadius: BorderRadius.circular(5)),
              child: DropdownButton<String>(
underline: SizedBox(),
                
                value: dropdownValue1,
                items: <String>['UID', 'Eth', 'USDT', 'Eth']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue1 = newValue!;
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: SizedBox(
              height:MediaQuery.of(context).size.width*0.09,
              
              child: TextField(
                
              
                
                decoration: const InputDecoration(
                  labelText: "UID",
                  hintText: "UID",
                  
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}
