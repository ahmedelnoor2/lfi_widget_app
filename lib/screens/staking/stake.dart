import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/screens/staking/common/all_stake.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';

class Stake extends StatefulWidget {
  static const routeName = '/staking';
  const Stake({Key? key}) : super(key: key);

  @override
  State<Stake> createState() => _StakeState();
}

class _StakeState extends State<Stake> with SingleTickerProviderStateMixin {
  late final TabController _tabStakeController =
      TabController(length: 3, vsync: this);

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Container(
        padding: EdgeInsets.all(10),
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
                      'Staking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.trending_up),
                )
              ],
            ),
            SizedBox(
              height: 35,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                isScrollable: true,
                onTap: (value) {
                  // setState(() {
                  //   // fetchMarginAccounts();
                  // });
                },
                tabs: <Tab>[
                  Tab(text: 'All'),
                  Tab(text: 'Lock-up wealth management'),
                  Tab(text: 'Holding wealth management'),
                ],
                controller: _tabStakeController,
              ),
            ),
            Divider(),
            SizedBox(
              height: height * 0.8,
              child: TabBarView(
                controller: _tabStakeController,
                children: [
                  AllStake(),
                  noData('No Data'),
                  noData('No Data'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
