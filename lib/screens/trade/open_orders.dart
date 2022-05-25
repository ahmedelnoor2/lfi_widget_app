import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

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
  void initState() {
    getOpenOrders();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getOpenOrders() async {
    var trading = Provider.of<Trading>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);

    if (auth.userInfo.isNotEmpty) {
      await trading.getOpenOrders(context, auth, {
        "entrust": 1,
        "isShowCanceled": 0,
        "orderType": 1,
        "page": 1,
        "pageSize": 10,
        "symbol": "",
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var auth = Provider.of<Auth>(context, listen: true);

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
                child: auth.userInfo.isEmpty
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/authentication');
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: linkColor,
                              ),
                            ),
                          ),
                          Text(' or '),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/authentication');
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: linkColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
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
                child: auth.userInfo.isEmpty
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/authentication');
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: linkColor,
                              ),
                            ),
                          ),
                          Text(' or '),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/authentication');
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: linkColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
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
