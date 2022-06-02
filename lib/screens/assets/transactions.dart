import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/drawer.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class Transactions extends StatefulWidget {
  static const routeName = '/transactions';
  const Transactions({Key? key, this.txtype}) : super(key: key);

  final txtype;

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions>
    with SingleTickerProviderStateMixin {
  late final TabController _tabTxHistoryController =
      TabController(length: 4, vsync: this);
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loadingAddress = false;
  String _defaultNetwork = 'ERC20';
  String _defaultCoin = 'USDT';
  List _allNetworks = [];

  @override
  void initState() {
    getDigitalBalance();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getDigitalBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getAccountBalance(auth, "");
    getCoinCosts(_defaultCoin);
  }

  Future<void> getCoinCosts(netwrkType) async {
    setState(() {
      _loadingAddress = true;
      _defaultCoin = netwrkType;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);

    if (public.publicInfoMarket['market']['followCoinList'][netwrkType] !=
        null) {
      setState(() {
        _allNetworks.clear();
      });

      public.publicInfoMarket['market']['followCoinList'][netwrkType]
          .forEach((k, v) {
        setState(() {
          _allNetworks.add(v);
          _defaultCoin = netwrkType;
          _defaultNetwork = '${v['mainChainName']}';
        });
      });
    } else {
      setState(() {
        _allNetworks.clear();
        _allNetworks
            .add(public.publicInfoMarket['market']['coinList'][netwrkType]);
        _defaultCoin = netwrkType;
        _defaultNetwork =
            '${public.publicInfoMarket['market']['coinList'][netwrkType]['mainChainName']}';
      });
    }

    await asset.getCoinCosts(auth, _defaultNetwork);
    await asset.getChangeAddress(auth, _defaultNetwork);

    List _digitialAss = [];
    asset.accountBalance['allCoinMap'].forEach((k, v) {
      if (v['depositOpen'] == 1) {
        _digitialAss.add({
          'coin': k,
          'values': v,
        });
      }
    });

    setState(() {
      _loadingAddress = false;
    });
    asset.setDigAssets(_digitialAss);
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var asset = Provider.of<Asset>(context, listen: true);
    var public = Provider.of<Public>(context, listen: true);

    return Scaffold(
      key: _scaffoldKey,
      appBar: hiddenAppBar(),
      drawer: drawer(
        context,
        width,
        height,
        asset,
        public,
        _searchController,
        getCoinCosts,
      ),
      body: Container(
        padding: EdgeInsets.only(
          bottom: 15,
          right: 15,
          left: 15,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.chevron_left),
                    ),
                    Text(
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.remove_red_eye),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Divider(),
            ),
            GestureDetector(
              onTap: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      style: BorderStyle.solid,
                      width: 0.3,
                      color: Color(0xff5E6292),
                    )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: CircleAvatar(
                            radius: 12,
                            child: Image.network(
                              '${public.publicInfoMarket['market']['coinList'][_defaultCoin]['icon']}',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text(
                            '$_defaultCoin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${public.publicInfoMarket['market']['coinList'][_defaultCoin]['longName']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              width: width,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                isScrollable: true,
                onTap: (value) => setState(() {
                  // _tabIndicatorColor = value == 0 ? Colors.green : Colors.red;
                }),
                tabs: <Tab>[
                  Tab(text: 'Deposits'),
                  Tab(text: 'Withdrawals'),
                  Tab(text: 'Other'),
                  Tab(text: 'Financial Records'),
                ],
                controller: _tabTxHistoryController,
              ),
            ),
            SizedBox(
              height: height * 0.66,
              child: TabBarView(
                controller: _tabTxHistoryController,
                children: [
                  depositList(context),
                  withdrawList(context),
                  Text(
                    'Status',
                    style: TextStyle(
                      color: secondaryTextColor,
                    ),
                  ),
                  Text(
                    'Status',
                    style: TextStyle(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget depositList(context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: width * 0.4,
              child: Text(
                'Currency',
                style: TextStyle(
                  color: secondaryTextColor,
                ),
              ),
            ),
            Text(
              'Amount',
              style: TextStyle(
                color: secondaryTextColor,
              ),
            ),
            Text(
              'Status',
              style: TextStyle(
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        Divider(
          height: 0,
        ),
        SizedBox(
          height: height * 0.63,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: _allNetworks.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: CircleAvatar(
                            radius: 15,
                            child: Icon(Icons.person),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('LYO/USDT'),
                              Text(
                                '${DateFormat('yyyy-mm-dd hh:mm:ss').format(DateTime.now())}',
                                style: TextStyle(
                                    color: secondaryTextColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: Text(
                        '777.49',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      child: SizedBox(
                        height: height * 0.035,
                        width: width * 0.18,
                        child: Card(
                          shadowColor: Colors.transparent,
                          color: greenPercentageIndicator,
                          child: Center(
                            child: Text(
                              'Completed',
                              style: TextStyle(
                                color: greenIndicator,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget withdrawList(context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: width * 0.4,
              child: Text(
                'Currency',
                style: TextStyle(
                  color: secondaryTextColor,
                ),
              ),
            ),
            Text(
              'Amount',
              style: TextStyle(
                color: secondaryTextColor,
              ),
            ),
            Text(
              'Status',
              style: TextStyle(
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        Divider(
          height: 0,
        ),
        SizedBox(
          height: height * 0.63,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: _allNetworks.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: CircleAvatar(
                            radius: 15,
                            child: Icon(Icons.person),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('LYO/USDT'),
                              Text(
                                '${DateFormat('yyyy-mm-dd hh:mm:ss').format(DateTime.now())}',
                                style: TextStyle(
                                    color: secondaryTextColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: Text(
                        '777.49',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      child: SizedBox(
                        height: height * 0.035,
                        width: width * 0.18,
                        child: Card(
                          shadowColor: Colors.transparent,
                          color: greenPercentageIndicator,
                          child: Center(
                            child: Text(
                              'Completed',
                              style: TextStyle(
                                color: greenIndicator,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
