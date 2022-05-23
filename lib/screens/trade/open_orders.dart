import 'package:flutter/material.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

class OpenOrders extends StatefulWidget {
  const OpenOrders({Key? key}) : super(key: key);

  @override
  State<OpenOrders> createState() => _OpenOrdersState();
}

class _OpenOrdersState extends State<OpenOrders>
    with SingleTickerProviderStateMixin {
  late final TabController _tabOpenOrderController =
      TabController(length: 2, vsync: this);
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(
          // height: 100,
          width: width,
          child: TabBar(
            onTap: (value) => setState(() {
              // _tabIndicatorColor = value == 0 ? Colors.green : Colors.red;
            }),
            tabs: const <Tab>[
              Tab(text: 'Open Orders(0)'),
              Tab(text: 'Funds'),
            ],
            controller: _tabOpenOrderController,
          ),
        ),
        Flexible(
          // height: height,
          child: TabBarView(
            controller: _tabOpenOrderController,
            children: [
              Container(
                padding: EdgeInsets.only(top: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.folder_off,
                      size: 50,
                      color: secondaryTextColor,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'No Data',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.folder_off,
                      size: 50,
                      color: secondaryTextColor,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'No Data',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
