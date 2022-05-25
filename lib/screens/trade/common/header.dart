import 'package:flutter/material.dart';

appHeader(context, tabController) {
  return AppBar(
    shadowColor: Colors.transparent,
    toolbarHeight: 0,
    bottom: TabBar(
      tabs: const <Tab>[
        Tab(text: 'Trade'),
        Tab(text: 'Margin'),
      ],
      controller: tabController,
    ),
  );
}
