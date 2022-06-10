import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/assets/transactions/deposit_lists.dart';
import 'package:lyotrade/screens/assets/transactions/financial_records.dart';
import 'package:lyotrade/screens/assets/transactions/orders_lists.dart';
import 'package:lyotrade/screens/assets/transactions/withdraw_lists.dart';
import 'package:lyotrade/screens/common/drawer.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/no_data.dart';
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
  int _page = 1;
  int _pageSize = 10;

  @override
  void initState() {
    fetchRecords();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void fetchRecords() {
    if (_tabTxHistoryController.index == 0) {
      getDepositTransactions();
    }
    if (_tabTxHistoryController.index == 1) {
      getWithdrawTransactions();
    }
    if (_tabTxHistoryController.index == 3) {
      getFinancialRecords();
    }
  }

  Future<void> getDepositTransactions() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getDepositTransactions(auth, {
      'coinSymbol': null,
      'page': _page,
      'pageSize': _pageSize,
    });
  }

  Future<void> getWithdrawTransactions() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getWithdrawTransactions(auth, {
      'coinSymbol': null,
      'page': _page,
      'pageSize': _pageSize,
    });
  }

  Future<void> getFinancialRecords() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getFinancialRecords(auth, {
      'financialType': 0,
      'gainCoin': "",
      'page': _page,
      'pageSize': _pageSize,
    });
  }

  Future<void> getCoinCosts(netwrkType) async {
    setState(() {
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

    await asset.getCoinCosts(auth, _defaultCoin);

    List _digitialAss = [];
    asset.accountBalance['allCoinMap'].forEach((k, v) {
      if (v['depositOpen'] == 1) {
        _digitialAss.add({
          'coin': k,
          'values': v,
        });
      }
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
          // bottom: 15,
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
                  icon: Icon(Icons.visibility),
                ),
              ],
            ),
            // Container(
            //   padding: EdgeInsets.only(bottom: 10),
            //   child: Divider(),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     _scaffoldKey.currentState!.openDrawer();
            //   },
            //   child: Container(
            //     padding: EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(5),
            //         border: Border.all(
            //           style: BorderStyle.solid,
            //           width: 0.3,
            //           color: Color(0xff5E6292),
            //         )),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Row(
            //           children: [
            //             Container(
            //               padding: EdgeInsets.only(right: 10),
            //               child: CircleAvatar(
            //                 radius: 12,
            //                 child: Image.network(
            //                   '${public.publicInfoMarket['market']['coinList'][_defaultCoin]['icon']}',
            //                 ),
            //               ),
            //             ),
            //             Container(
            //               padding: EdgeInsets.only(right: 5),
            //               child: Text(
            //                 '$_defaultCoin',
            //                 style: TextStyle(
            //                   fontSize: 16,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //             ),
            //             Text(
            //               '${public.publicInfoMarket['market']['coinList'][_defaultCoin]['longName']}',
            //               style: TextStyle(
            //                 fontSize: 14,
            //                 fontWeight: FontWeight.normal,
            //               ),
            //             ),
            //           ],
            //         ),
            //         Icon(Icons.keyboard_arrow_down),
            //       ],
            //     ),
            //   ),
            // ),
            Container(
              padding: EdgeInsets.only(bottom: 20),
              width: width,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                isScrollable: true,
                onTap: (value) => setState(() {
                  _page = 1;
                  _pageSize = 10;
                  fetchRecords();
                  print(_tabTxHistoryController.index);
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
                  asset.depositLists.isEmpty
                      ? noData('No Transactions')
                      : depositList(context, width, height, asset.depositLists),
                  asset.withdrawLists.isEmpty
                      ? noData('No Transactions')
                      : withdrawList(
                          context, width, height, asset.withdrawLists),
                  noData('No Transactions'),
                  asset.financialRecords.isEmpty
                      ? noData('No Transactions')
                      : financialRecords(
                          context, width, height, asset.financialRecords),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
