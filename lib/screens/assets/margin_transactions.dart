import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/assets/transactions/margin_history_list.dart';
import 'package:lyotrade/screens/assets/transactions/margin_loan_list.dart';
import 'package:lyotrade/screens/assets/transactions/margin_transfer_list.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class MarginTransactions extends StatefulWidget {
  static const routeName = '/margin_transactions';
  const MarginTransactions({Key? key}) : super(key: key);

  @override
  State<MarginTransactions> createState() => _MarginTransactionsState();
}

class _MarginTransactionsState extends State<MarginTransactions>
    with SingleTickerProviderStateMixin {
  late final TabController _tabmMarginHistoryController =
      TabController(length: 3, vsync: this);
  int _page = 1;
  int _pageSize = 10;
  String _defaultMarginCoin = 'BTC';
  Map _selectedMarginAssets = {};
  List _marginAssets = [];

  @override
  void initState() {
    getMarginlBalance();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getMarginlBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    await asset.getMarginBalance(auth);
    List _margAssets = [];
    asset.marginBalance['leverMap'].forEach((k, v) {
      if (k.split('/')[0] == _defaultMarginCoin) {
        setState(() {
          _selectedMarginAssets = {
            'coin': k.split('/')[0],
            'market': k,
            'values': v,
          };
        });
      }
      _margAssets.add({
        'coin': k.split('/')[0],
        'market': k,
        'values': v,
      });
    });
    setState(() {
      _marginAssets = _margAssets;
    });
    fetchMarginAccounts();
  }

  void fetchMarginAccounts() {
    if (_tabmMarginHistoryController.index == 0) {
      getMarginLoanTransactions();
    }

    if (_tabmMarginHistoryController.index == 1) {
      getMarginHistoryTransactions();
    }

    if (_tabmMarginHistoryController.index == 2) {
      getMarginTransferTransactions();
    }
  }

  Future<void> getMarginLoanTransactions() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getMarginLoanTransactions(auth, {
      'symbol': null,
      'page': _page,
      'pageSize': _pageSize,
    });
  }

  Future<void> getMarginHistoryTransactions() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getMarginHistoryTransactions(auth, {
      'symbol': null,
      'page': _page,
      'pageSize': _pageSize,
    });
  }

  Future<void> getMarginTransferTransactions() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getMarginTransferTransactions(auth, {
      'symbol': null,
      'page': _page,
      'pageSize': _pageSize,
    });
  }

  @override
  Widget build(BuildContext context) {
    var public = Provider.of<Public>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);

    return Scaffold(
      appBar: hiddenAppBar(),
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
                      'Margin Transaction History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.visibility),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Divider(),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pairs',
                  style: TextStyle(
                    color: secondaryTextColor,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return selectPair(context, public, asset);
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    width: 0.3,
                    color: Color(0xff5E6292),
                  ),
                ),
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
                              '${public.publicInfoMarket['market']['coinList'][_defaultMarginCoin]['icon']}',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text(
                            '${_selectedMarginAssets['market'] ?? '--'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
            TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              isScrollable: true,
              onTap: (value) => setState(() {
                fetchMarginAccounts();
              }),
              tabs: <Tab>[
                Tab(text: 'Current loan'),
                Tab(text: 'Historical lending'),
                Tab(text: 'Trasnfer Record'),
              ],
              controller: _tabmMarginHistoryController,
            ),
            SizedBox(
              height: height * 0.66,
              child: TabBarView(
                controller: _tabmMarginHistoryController,
                children: [
                  asset.depositLists.isEmpty
                      ? noData()
                      : marginLoanList(
                          context, width, height, asset.marginLoanLists),
                  asset.withdrawLists.isEmpty
                      ? noData()
                      : marginHistoryList(
                          context, width, height, asset.marginHistoryLists),
                  asset.financialRecords.isEmpty
                      ? noData()
                      : marginTransferList(
                          context, width, height, asset.marginTransferLists),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget selectPair(context, public, assetProvider) {
    height = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(10),
      height: height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Pair',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
              )
            ],
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _marginAssets.length,
            itemBuilder: (BuildContext context, int index) {
              var asset = _marginAssets[index];

              return ListTile(
                onTap: () {
                  setState(() {
                    _selectedMarginAssets = asset;
                    _defaultMarginCoin = asset['coin'];
                  });
                  Navigator.pop(context);
                },
                leading: CircleAvatar(
                  radius: 15,
                  child: Image.network(
                    '${public.publicInfoMarket['market']['coinList'][asset['coin']]['icon']}',
                  ),
                ),
                title: Text('${asset['market']}'),
                trailing: Icon(
                  Icons.check,
                  color: _selectedMarginAssets['coin'] == asset['coin']
                      ? greenIndicator
                      : secondaryTextColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
