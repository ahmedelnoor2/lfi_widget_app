import 'package:flutter/material.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

appHeader(context, tabController) {
  return AppBar(
    shadowColor: Colors.transparent,
    toolbarHeight: 0,
    bottom: TabBar(
      indicatorSize: TabBarIndicatorSize.label,
      isScrollable: true,
      tabs: <Tab>[
        Tab(text: 'Spot'),
        Tab(text: 'Cross Margin'),
      ],
      controller: tabController,
    ),
  );
}

klineHeader(context, scaffoldKey, market) {
  return AppBar(
    shadowColor: Colors.transparent,
    // toolbarHeight: 1,
    centerTitle: true,
    leading: IconButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/trade',
            (route) => false,
          );
        },
        icon: Icon(Icons.chevron_left)),
    title: InkWell(
      onTap: () {
        scaffoldKey!.currentState.openDrawer();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swap_horiz),
          Text(
            '$market',
            style: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.normal,
            ),
          ),
        ],
      ),
    ),
    actions: [
      IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.star,
          color: secondaryTextColor,
        ),
      )
    ],
  );
}
