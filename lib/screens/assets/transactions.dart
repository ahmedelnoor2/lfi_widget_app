import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/assets/transactions/deposit_lists.dart';
import 'package:lyotrade/screens/assets/transactions/financial_records.dart';
import 'package:lyotrade/screens/assets/transactions/orders_lists.dart';
import 'package:lyotrade/screens/assets/transactions/withdraw_lists.dart';
import 'package:lyotrade/screens/common/drawer.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Coins.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  GlobalKey refresherKey = GlobalKey();

  bool _loadingAddress = false;
  bool _loadingDepositTransactions = false;
  bool _loadingWithdrawTransactions = false;
  bool _loadingFinancialTransactions = false;
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

  Future<void> fetchRecords() async {
    if (_tabTxHistoryController.index == 0) {
      await getDepositTransactions();
    }
    if (_tabTxHistoryController.index == 1) {
      await getWithdrawTransactions();
    }
    if (_tabTxHistoryController.index == 3) {
      await getFinancialRecords();
    }
    return;
  }

  Future<void> getDepositTransactions() async {
    setState(() {
      _loadingDepositTransactions = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getDepositTransactions(auth, {
      'coinSymbol': null,
      'page': _page,
      'pageSize': _pageSize,
    });
    setState(() {
      _loadingDepositTransactions = false;
    });
  }

  Future<void> getWithdrawTransactions() async {
    setState(() {
      _loadingWithdrawTransactions = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getWithdrawTransactions(auth, {
      'coinSymbol': null,
      'page': _page,
      'pageSize': _pageSize,
    });
    setState(() {
      _loadingWithdrawTransactions = false;
    });
  }

  Future<void> getFinancialRecords() async {
    setState(() {
      _loadingFinancialTransactions = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getFinancialRecords(auth, {
      'financialType': 0,
      'gainCoin': "",
      'page': _page,
      'pageSize': _pageSize,
    });
    setState(() {
      _loadingFinancialTransactions = false;
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

  // Future<void> refreshList() async {
  //   refreshKey.currentState?.show(atTop: false);
  //   fetchRecords();
  //   return;
  // }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var asset = Provider.of<Asset>(context, listen: true);
    var public = Provider.of<Public>(context, listen: true);
    var languageprovider = Provider.of<LanguageChange>(context, listen: true);

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
        null,
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
                      languageprovider.getlanguage['history_detail']['title'] ??
                          'Transaction History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ],
            ),
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

                  // _tabIndicatorColor = value == 0 ? Colors.green : Colors.red;
                }),
                tabs: <Tab>[
                  Tab(
                      text: languageprovider.getlanguage['history_detail']
                              ['option1']['title'] ??
                          'Deposits'),
                  Tab(
                      text: languageprovider.getlanguage['history_detail']
                              ['option2']['title'] ??
                          'Withdrawals'),
                  Tab(
                      text: languageprovider.getlanguage['history_detail']
                              ['option3']['title'] ??
                          'Other'),
                  Tab(
                      text: languageprovider.getlanguage['history_detail']
                              ['option4']['title'] ??
                          'Financial Records'),
                ],
                controller: _tabTxHistoryController,
              ),
            ),
            SizedBox(
              height: height * 0.79,
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabTxHistoryController,
                children: [
                  Tab(
                    child: _loadingDepositTransactions
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : asset.depositLists.isEmpty
                            ? noData('No Transactions')
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                  Expanded(
                                    flex: 2,
                                    child: SmartRefresher(
                                      key: refresherKey,
                                      controller: _refreshController,
                                      enablePullDown: true,
                                      enablePullUp: true,
                                      physics: BouncingScrollPhysics(),
                                      header: WaterDropHeader(),
                                      footer: ClassicFooter(),
                                      onRefresh: (() async {
                                        setState(() {
                                          _pageSize = 10;
                                        });
                                        return Future.delayed(
                                          Duration(seconds: 2),
                                          () async {
                                            fetchRecords();

                                            if (mounted) setState(() {});
                                            _refreshController.loadComplete();
                                          },
                                        );
                                      }),
                                      onLoading: (() async {
                                        setState(() {
                                          _pageSize += 10;
                                        });
                                        return Future.delayed(
                                          Duration(seconds: 2),
                                          () async {
                                            fetchRecords();

                                            if (mounted) setState(() {});
                                            _refreshController.loadComplete();
                                          },
                                        );
                                      }),
                                      child: ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        itemCount: asset.depositLists.length,
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          var deposit =
                                              asset.depositLists[index];
                                          return InkWell(
                                            onTap: () async {
                                              var asset = Provider.of<Asset>(
                                                  context,
                                                  listen: false);
                                              await asset.setTransactionDetails(
                                                  deposit);
                                              Navigator.pushNamed(context,
                                                  '/transaction_details');
                                            },
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10),
                                                        child: CircleAvatar(
                                                          radius: 15,
                                                          child: public.publicInfoMarket[
                                                                              'market']
                                                                          [
                                                                          'coinList']
                                                                      [deposit[
                                                                          'symbol']] !=
                                                                  null
                                                              ? Image.network(
                                                                  '${public.publicInfoMarket['market']['coinList'][deposit['symbol']]['icon']}')
                                                              : Icon(
                                                                  Icons
                                                                      .hourglass_empty,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                '${getCoinName('${public.publicInfoMarket['market']['coinList'][deposit['symbol']]['showName']}')}'),
                                                            Text(
                                                              '${DateFormat('dd-MM-y H:mm').format(DateTime.parse(deposit['createdAt']))}',
                                                              style: TextStyle(
                                                                  color:
                                                                      secondaryTextColor,
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      '${deposit['amount']}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: SizedBox(
                                                      height: height * 0.035,
                                                      width: width * 0.18,
                                                      child: Card(
                                                        shadowColor:
                                                            Colors.transparent,
                                                        color:
                                                            greenPercentageIndicator,
                                                        child: Center(
                                                          child: Text(
                                                            '${deposit['status_text']}',
                                                            style: TextStyle(
                                                              color:
                                                                  greenIndicator,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                  ),
                  Tab(
                      child: _loadingWithdrawTransactions
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : asset.withdrawLists.isEmpty
                              ? noData('No Transactions')
                              : Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                    Expanded(
                                      flex: 2,
                                      child: SmartRefresher(
                                        key: refresherKey,
                                        controller: _refreshController,
                                        enablePullDown: true,
                                        enablePullUp: true,
                                        physics: BouncingScrollPhysics(),
                                        header: WaterDropHeader(),
                                        footer: ClassicFooter(),
                                        onRefresh: (() async {
                                          setState(() {
                                            _pageSize = 10;
                                          });
                                          return Future.delayed(
                                            Duration(seconds: 2),
                                            () async {
                                              fetchRecords();

                                              if (mounted) setState(() {});
                                              _refreshController.loadComplete();
                                            },
                                          );
                                        }),
                                        onLoading: (() async {
                                          setState(() {
                                            _pageSize += 10;
                                          });
                                          return Future.delayed(
                                            Duration(seconds: 2),
                                            () async {
                                              fetchRecords();

                                              if (mounted) setState(() {});
                                              _refreshController.loadComplete();
                                            },
                                          );
                                        }),
                                        child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: asset.withdrawLists.length,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            var withdrawal =
                                                asset.withdrawLists[index];
                                            return InkWell(
                                              onTap: () async {
                                                var asset = Provider.of<Asset>(
                                                    context,
                                                    listen: false);
                                                await asset
                                                    .setTransactionDetails(
                                                        withdrawal);
                                                Navigator.pushNamed(context,
                                                    '/transaction_details');
                                              },
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          child: CircleAvatar(
                                                            radius: 15,
                                                            child: public.publicInfoMarket['market']
                                                                            [
                                                                            'coinList']
                                                                        [
                                                                        withdrawal[
                                                                            'symbol']] !=
                                                                    null
                                                                ? Image.network(
                                                                    '${public.publicInfoMarket['market']['coinList'][withdrawal['symbol']]['icon']}')
                                                                : Icon(
                                                                    Icons
                                                                        .hourglass_empty,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${getCoinName('${public.publicInfoMarket['market']['coinList'][withdrawal['symbol']]['showName']}')}',
                                                              ),
                                                              Text(
                                                                '${DateFormat('dd-MM-y H:mm').format(DateTime.parse(withdrawal['createdAt']))}',
                                                                style: TextStyle(
                                                                    color:
                                                                        secondaryTextColor,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      child: Text(
                                                        '${withdrawal['amount']}',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      child: SizedBox(
                                                        height: height * 0.035,
                                                        width: width * 0.18,
                                                        child: Card(
                                                          shadowColor: Colors
                                                              .transparent,
                                                          color:
                                                              greenPercentageIndicator,
                                                          child: Center(
                                                            child: Text(
                                                              '${withdrawal['status_text']}',
                                                              style: TextStyle(
                                                                color:
                                                                    greenIndicator,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                  Tab(
                    child: noData('No Transactions'),
                  ),
                  Tab(
                    child: SmartRefresher(
                      key: refresherKey,
                      controller: _refreshController,
                      enablePullDown: true,
                      enablePullUp: true,
                      physics: BouncingScrollPhysics(),
                      header: WaterDropHeader(),
                      footer: ClassicFooter(),
                      onRefresh: (() async {
                        setState(() {
                          _pageSize = 10;
                        });
                        return Future.delayed(
                          Duration(seconds: 2),
                          () async {
                            fetchRecords();

                            if (mounted) setState(() {});
                            _refreshController.loadComplete();
                          },
                        );
                      }),
                      onLoading: (() async {
                        setState(() {
                          _pageSize += 10;
                        });
                        return Future.delayed(
                          Duration(seconds: 2),
                          () async {
                            fetchRecords();

                            if (mounted) setState(() {});
                            _refreshController.loadComplete();
                          },
                        );
                      }),
                      child: _loadingFinancialTransactions
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : asset.financialRecords.isEmpty
                              ? noData('No Transactions')
                              : Column(
                                  children: [
                                    SizedBox(
                                      height: height * 0.60,
                                      width: width,
                                      child: ListView.builder(
                                        itemCount:
                                            asset.financialRecords.length,
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          var financialRecord =
                                              asset.financialRecords[index];
                                          return Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 15),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    padding: EdgeInsets.only(
                                                                        bottom:
                                                                            8,
                                                                        right:
                                                                            5),
                                                                    child: Text(
                                                                      '${financialRecord['gainCoin']}',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  SizedBox(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          padding:
                                                                              EdgeInsets.only(bottom: 5),
                                                                          child:
                                                                              Text(
                                                                            'Type',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              color: secondaryTextColor,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          padding:
                                                                              EdgeInsets.only(bottom: 5),
                                                                          child:
                                                                              Text(
                                                                            'Amount',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              color: secondaryTextColor,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          child:
                                                                              Text(
                                                                            'Status',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              color: secondaryTextColor,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 5),
                                                          child: Text(
                                                            '${DateFormat('yyy-mm-dd hh:mm:ss').format(DateTime.parse('${financialRecord['createTime']}'))}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  secondaryTextColor,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 5),
                                                          child: Text(
                                                            '${financialRecord['financialType']}',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    redIndicator),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 5),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                '${financialRecord['amount']}',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          // padding: EdgeInsets.only(right: 20),
                                                          child: Text(
                                                            '${financialRecord['status']}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Divider(),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
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
}
