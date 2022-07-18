import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/referral.dart';

import 'package:lyotrade/screens/common/header.dart';

import 'package:lyotrade/screens/referal/pages/commision_record.dart';
import 'package:lyotrade/screens/referal/pages/position_statistics.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class Referal extends StatefulWidget {
  static const routeName = '/referal_screen';
  @override
  State<StatefulWidget> createState() => _ReferalState();
}

class _ReferalState extends State<Referal> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  var currenttabindex = 0;
//TextEditingController generalcontroller = TextEditingController();
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
  String labelText = 'UID';

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    var referalprovider = Provider.of<ReferralProvider>(context, listen: false);
   

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
          SizedBox(
            height: 20,
          ),
          FutureBuilder(
              future: referalprovider.getreferral(auth),
              builder: (context, dataSnapshot) {
                if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                 } else {
                  if (dataSnapshot.error != null) {
                    return Center(
                      child: Text('An error occured'),
                    );
                  } else {
                    return Consumer<ReferralProvider>(
                        builder: (context, refData, child) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.44,
                                  height: 62,
                                  color: selectboxcolour,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Total invitees',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: Text(
                                              refData.referraldata['count']
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ]),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.44,
                                  height: 62,
                                  color: selectboxcolour,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Total income',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: Text(
                                              refData.referraldata[
                                                          'allBonusAmount']
                                                      .toString() +
                                                  " " +
                                                  refData.referraldata[
                                                          'allBonusCoin']
                                                      .toString(),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ]),
                                ),
                              ],
                            ));
                  }
                }
              }),
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
    var auth = Provider.of<Auth>(context, listen: false);
    var referalprovider = Provider.of<ReferralProvider>(context, listen: false);

    return Container(
      padding: EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 30,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                  color: selectboxcolour,
                  borderRadius: BorderRadius.circular(5)),
              child: DropdownButton<String>(
                underline: SizedBox(),
                value: referalprovider.coinName,
                items: <String>['LYO', 'USDT', 'HT', 'DASH', 'XRP']
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
                    if (currenttabindex == 0) {
                      referalprovider.coinName = newValue!;
                      referalprovider.getreferral(auth);
                    }

                    if (currenttabindex == 1) {
                      referalprovider.pcoinName = newValue!;
                      referalprovider.getpositionreferral(auth);
                    }
                  });
                },
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 30,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                  color: selectboxcolour,
                  borderRadius: BorderRadius.circular(5)),
              child: DropdownButton<String>(
                underline: SizedBox(),
                value: dropdownValue1,
                items: <String>[
                  'UID',
                  'Phone Number',
                  'Email',
                ].map<DropdownMenuItem<String>>((String value) {
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
                    if (newValue == 'UID') {
                      dropdownValue1 = newValue!;
                      if (currenttabindex == 0) {
                        referalprovider.keyborad = '1';
                        referalprovider.getreferral(auth);
                      }
                      if (currenttabindex == 1) {
                        referalprovider.pkeyborad = '1';
                        referalprovider.getpositionreferral(auth);
                      }
                    }
                    if (newValue == 'Phone Number') {
                      dropdownValue1 = newValue!;
                      if (currenttabindex == 0) {
                        referalprovider.keyborad = '2';
                        referalprovider.getreferral(auth);
                      }
                      if (currenttabindex == 1) {
                        referalprovider.pkeyborad = '2';
                        referalprovider.getpositionreferral(auth);
                      }

                      labelText = 'Phone Number';
                    }
                    if (newValue == 'Email') {
                      dropdownValue1 = newValue!;
                      if (currenttabindex == 0) {
                        referalprovider.keyborad = '3';
                        referalprovider.getreferral(auth);
                      }
                      if (currenttabindex == 1) {
                        referalprovider.pkeyborad = '3';
                        referalprovider.getpositionreferral(auth);
                      }

                      labelText = 'Email';
                    }
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
                height: MediaQuery.of(context).size.width * 0.09,
                child: TextField(
                  onChanged: (value) {
                    referalprovider.keyword = value;
                    print(referalprovider.keyword);
                    referalprovider.getreferral(auth);
                  },
                  decoration: InputDecoration(
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
