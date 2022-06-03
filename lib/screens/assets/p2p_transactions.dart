import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/assets/transactions/p2p_lists.dart';
import 'package:lyotrade/screens/common/drawer.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class P2pTransactions extends StatefulWidget {
  static const routeName = '/p2p_transactions';
  const P2pTransactions({Key? key}) : super(key: key);

  @override
  State<P2pTransactions> createState() => _P2pTransactionsState();
}

class _P2pTransactionsState extends State<P2pTransactions> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _defaultCoin = 'LYO1';
  List _toAccounts = ['P2P Account', 'Margin Account'];
  String _selectedToAccount = 'P2P Account';
  String _defaultMarginCoin = 'BTC';
  List _allNetworks = [];
  List _p2pAssets = [];
  List _marginAssets = [];
  Map _selectedMarginAssets = {};
  Map _selectedP2pAssets = {};

  int _page = 1;
  int _pageSize = 10;

  @override
  void initState() {
    getP2pBalance();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getP2pBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    await asset.getP2pBalance(auth);
    asset.p2pBalance['allCoinMap'].forEach((p2pAccount) {
      if (p2pAccount['coinSymbol'] == _defaultCoin) {
        setState(() {
          _selectedP2pAssets = p2pAccount;
        });
      }
    });
    setState(() {
      _p2pAssets = asset.p2pBalance['allCoinMap'];
    });
  }

  Future<void> getP2pTransactions() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getP2pTransactions(auth, {
      'coinSymbol': null,
      'transactionType': null,
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
        });
      });
    } else {
      setState(() {
        _allNetworks.clear();
        _allNetworks
            .add(public.publicInfoMarket['market']['coinList'][netwrkType]);
        _defaultCoin = netwrkType;
      });
    }
    getP2pBalance();
  }

  void selectP2pCoin(account) {
    setState(() {
      _selectedP2pAssets = account;
      _defaultCoin = account['coinSymbol'];
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);

    return Scaffold(
      key: _scaffoldKey,
      appBar: hiddenAppBar(),
      drawer: transferDrawer(
        context,
        width,
        height,
        _selectedP2pAssets,
        _p2pAssets,
        public,
        selectP2pCoin,
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
                      'P2P Transaction History',
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
                  'Coins',
                  style: TextStyle(
                    color: secondaryTextColor,
                  ),
                ),
              ),
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
                              '${public.publicInfoMarket['market']['coinList'][_defaultCoin]['icon']}',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text(
                            _selectedToAccount == 'Margin Account'
                                ? _defaultMarginCoin
                                : _defaultCoin,
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
            asset.p2pLists.isEmpty
                ? Center(child: noData())
                : p2pList(context, width, height, asset.p2pLists)
          ],
        ),
      ),
    );
  }
}
