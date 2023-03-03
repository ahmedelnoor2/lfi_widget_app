import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/screens/assets/assets.dart';
import 'package:lyotrade/screens/common/drawer.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Coins.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class TransferAssets extends StatefulWidget {
  static const routeName = '/transfer_assets';
  const TransferAssets({Key? key}) : super(key: key);

  @override
  State<TransferAssets> createState() => _TransferAssetsState();
}

class _TransferAssetsState extends State<TransferAssets> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // String _defaultCoin = 'LYO1';
  List _toAccounts = ['P2P Account', 'Margin Account'];
  String _selectedToAccount = 'P2P Account';
  // String _defaultMarginCoin = 'BTC';
  List _allNetworks = [];
  // List _p2pAssets = [];
  // List _marginAssets = [];
  // Map _selectedMarginAssets = {};
  // Map _selectedP2pAssets = {};
  bool _fromDigitalAccountToOtherAccount = true;
  bool _processTransfer = false;

  String _availableBalanceFrom = '0.000';
  String _availableBalanceTo = '0.000';

  @override
  void initState() {
    getDigitalBalance();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> getDigitalBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getAccountBalance(context, auth, "");
    await asset.getP2pBalance(context, auth);
    await asset.getMarginBalance(auth);
    getCoinCosts(asset.defaultCoin);
    setState(() {
      _availableBalanceFrom = _fromDigitalAccountToOtherAccount
          ? '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}'
          : _selectedToAccount == 'Margin Account'
              ? getMarketBalanceCoin(asset)
              : '${asset.selectedP2pAssets['normal']}';
      _availableBalanceTo = _fromDigitalAccountToOtherAccount
          ? _selectedToAccount == 'Margin Account'
              ? getMarketBalanceCoin(asset)
              : '${asset.selectedP2pAssets['normal']}'
          : '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}';
      // _availableBalanceFrom = _fromDigitalAccountToOtherAccount
      //     ? '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}'
      //     : _selectedToAccount == 'Margin Account'
      //         ? getMarketBalanceCoin(asset)
      //         : '${asset.selectedP2pAssets['normal']}';
      // _availableBalanceTo = _fromDigitalAccountToOtherAccount
      //     ? _selectedToAccount == 'Margin Account'
      //         ? getMarketBalanceCoin(asset)
      //         : '${asset.selectedP2pAssets['normal']}'
      //     : '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}';
    });
  }

  Future<void> getP2pBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    await asset.getP2pBalance(context, auth);

    // asset.p2pBalance['allCoinMap'].forEach((p2pAccount) {
    //   if (p2pAccount['coinSymbol'] == _defaultCoin) {
    //     setState(() {
    //       _selectedP2pAssets = p2pAccount;
    //     });
    //   }
    // });
    // setState(() {
    //   _p2pAssets = asset.p2pBalance['allCoinMap'];
    // });
  }

  Future<void> getMarginlBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    await asset.getMarginBalance(auth);
    // List _margAssets = [];
    // asset.marginBalance['leverMap'].forEach((k, v) {
    //   if (k.split('/')[0] == _defaultMarginCoin) {
    //     setState(() {
    //       _selectedMarginAssets = {
    //         'coin': k.split('/')[0],
    //         'market': k,
    //         'values': v,
    //       };
    //     });
    //   }
    //   _margAssets.add({
    //     'coin': k.split('/')[0],
    //     'market': k,
    //     'values': v,
    //   });
    // });
    // setState(() {
    //   _marginAssets = _margAssets;
    // });
  }

  Future<void> getCoinCosts(netwrkType) async {
    // setState(() {
    //   _defaultCoin = netwrkType;
    // });
    var public = Provider.of<Public>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    // asset.setDefaultCoin(netwrkType);

    if (public.publicInfoMarket['market']['followCoinList'][netwrkType] !=
        null) {
      setState(() {
        _allNetworks.clear();
      });

      public.publicInfoMarket['market']['followCoinList'][netwrkType]
          .forEach((k, v) {
        // asset.setDefaultCoin(netwrkType);
        setState(() {
          _allNetworks.add(v);
          // _defaultCoin = netwrkType;
        });
      });
    } else {
      // asset.setDefaultCoin(netwrkType);
      setState(() {
        _allNetworks.clear();
        _allNetworks
            .add(public.publicInfoMarket['market']['coinList'][netwrkType]);
        // _defaultCoin = netwrkType;
      });
    }
    setState(() {
      _availableBalanceFrom = _fromDigitalAccountToOtherAccount
          ? '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}'
          : _selectedToAccount == 'Margin Account'
              ? getMarketBalanceCoin(asset)
              : '${asset.selectedP2pAssets['normal']}';
      _availableBalanceTo = _fromDigitalAccountToOtherAccount
          ? _selectedToAccount == 'Margin Account'
              ? getMarketBalanceCoin(asset)
              : '${asset.selectedP2pAssets['normal']}'
          : '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}';
    });
    // getP2pBalance();
    // getMarginlBalance();
  }

  void selectP2pCoin(account) {
    var asset = Provider.of<Asset>(context, listen: false);
    asset.setSelectedP2pAssets(account);
    asset.setDefaultCoin(account['coinSymbol']);
    asset.setDefaultMarginCoin(account['coinSymbol']);
    setState(() {
      // _selectedP2pAssets = account;
      // _defaultCoin = account['coinSymbol'];
      // _availableBalanceFrom = _fromDigitalAccountToOtherAccount
      //     ? '${asset.accountBalance['allCoinMap'][account['coinSymbol']]['normal_balance']}'
      //     : '${asset.selectedP2pAssets['normal']}';
      _availableBalanceFrom = _fromDigitalAccountToOtherAccount
          ? '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}'
          : '${asset.selectedP2pAssets['normal']}';
      _availableBalanceTo = _fromDigitalAccountToOtherAccount
          ? '${asset.selectedP2pAssets['normal']}'
          : '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}';
    });
  }

  String getMarketBalanceCoin(asset) {
    return asset.selectedMarginAssets.isEmpty
        ? '0'
        : asset.defaultMarginCoin == asset.selectedMarginAssets['coin']
            ? '${asset.selectedMarginAssets['values']['baseTotalBalance']}'
            : '${asset.selectedMarginAssets['values']['quoteTotalBalance']}';
  }

  Future<void> transferringAsset() async {
    setState(() {
      _processTransfer = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    if (_selectedToAccount == 'P2P Account') {
      Map formData = {
        "amount": _amountController.text,
        "coinSymbol": asset.defaultCoin,
        "fromAccount": _fromDigitalAccountToOtherAccount ? "1" : "2",
        "toAccount": _fromDigitalAccountToOtherAccount ? "2" : "1",
      };

      await asset.makeOtcTransfer(context, auth, formData);
      // getP2pBalance();
      getDigitalBalance();
    } else {
      Map formData = {
        "amount": _amountController.text,
        "coinSymbol": asset.defaultMarginCoin,
        "fromAccount": _fromDigitalAccountToOtherAccount ? "1" : "2",
        "symbol": asset.selectedMarginAssets['values']['symbol'],
        "toAccount": _fromDigitalAccountToOtherAccount ? "2" : "1",
      };

      await asset.makeMarginTransfer(context, auth, formData);
      // getMarginlBalance();
      getDigitalBalance();
    }
    setState(() {
      _processTransfer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);
    var languageprovider = Provider.of<LanguageChange>(context, listen: true);

    // print(asset.p2pBalance);
    // print(_availableBalanceTo);

    // print(asset.marginAssets);
    // print(_selectedMarginAssets);
    // print(_selectedP2pAssets);

    // print(asset.accountBalance['allCoinMap']);

    return Scaffold(
      key: _scaffoldKey,
      appBar: hiddenAppBar(),
      drawer: transferDrawer(
        context,
        width,
        height,
        asset.selectedP2pAssets,
        asset.p2pBalance.isNotEmpty ? asset.p2pBalance['allCoinMap'] : [],
        public,
        selectP2pCoin,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            right: 15,
            left: 15,
            bottom: 15,
          ),
          height: height * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Row(
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
                          languageprovider.getlanguage['transfer_detail']['title']??'Transfer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/transactions');
                          },
                          icon: Icon(Icons.history),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          style: BorderStyle.solid,
                          width: 0.3,
                          color: Color(0xff5E6292),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              _fromDigitalAccountToOtherAccount
                                  ? digitalAccounts(context, public, asset)
                                  : otherAccounts(context, public, asset),
                              SizedBox(
                                width: width * 0.72,
                                child: Divider(),
                              ),
                              !_fromDigitalAccountToOtherAccount
                                  ? digitalAccounts(context, public, asset)
                                  : otherAccounts(context, public, asset),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _fromDigitalAccountToOtherAccount =
                                    !_fromDigitalAccountToOtherAccount;
                                _availableBalanceFrom =
                                    _fromDigitalAccountToOtherAccount
                                        ? '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}'
                                        : _selectedToAccount == 'Margin Account'
                                            ? getMarketBalanceCoin(asset)
                                            : '${asset.selectedP2pAssets['normal']}';
                                _availableBalanceTo = _fromDigitalAccountToOtherAccount
                                    ? _selectedToAccount == 'Margin Account'
                                        ? getMarketBalanceCoin(asset)
                                        : '${asset.selectedP2pAssets['normal']}'
                                    : '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}';
                              });
                            },
                            icon: Image.asset(
                              'assets/img/transfer.png',
                              width: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 20,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                           languageprovider.getlanguage['transfer_detail']['avl_from']??'Available From:',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$_availableBalanceFrom ${_selectedToAccount == 'Margin Account' ? getCoinName(asset.defaultMarginCoin) : getCoinName(asset.defaultCoin)}',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                           languageprovider.getlanguage['transfer_detail']['avl_to']??'Available To:',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$_availableBalanceTo ${_selectedToAccount == 'Margin Account' ? getCoinName(asset.defaultMarginCoin) : getCoinName(asset.defaultCoin)}',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _selectedToAccount == 'Margin Account'
                      ? Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Pair',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _selectedToAccount == 'Margin Account'
                                      ? showModalBottomSheet<void>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(
                                              builder: (BuildContext context,
                                                  StateSetter ) {
                                                return selectPair(context,
                                                    public, asset, setState);
                                              },
                                            );
                                          },
                                        )
                                      : _scaffoldKey.currentState!.openDrawer();
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(right: 10),
                                            child: CircleAvatar(
                                              radius: 12,
                                              child: Image.network(
                                                '${public.publicInfoMarket['market']['coinList'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['icon']}',
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(right: 5),
                                            child: Text(
                                              '${asset.selectedMarginAssets['market'] ?? '--'}',
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
                            ],
                          ),
                        )
                      : Container(),
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                    languageprovider.getlanguage['transfer_detail']['coin']??    'Coins',
                        style: TextStyle(
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _selectedToAccount == 'Margin Account'
                          ? showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return selectCoin(
                                        context, public, asset, setState);
                                  },
                                );
                              },
                            )
                          : _scaffoldKey.currentState!.openDrawer();
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
                                    '${public.publicInfoMarket['market']['coinList'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['icon']}',
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(right: 5),
                                child: Text(
                                  _selectedToAccount == 'Margin Account'
                                      ? getCoinName(asset.defaultMarginCoin)
                                      : getCoinName(asset.defaultCoin),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${public.publicInfoMarket['market']['coinList'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['longName']}',
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
                  Divider(
                    height: 70,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                         languageprovider.getlanguage['transfer_detail']['num']??   'The number of tranfers',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                style: BorderStyle.solid,
                                width: 0.3,
                                color: Color(0xff5E6292),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: width * 0.69,
                                  child: TextField(
                                    onChanged: (value) async {
                                      print(value);
                                    },
                                    controller: _amountController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                      ),
                                      hintText:languageprovider.getlanguage['transfer_detail']['placeholder']??
                                          "Please enter the number of transfers",
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 10),
                                      child: GestureDetector(
                                        onTap: () async {
                                          _amountController.text =
                                              _availableBalanceFrom;
                                        },
                                        child: Text(
                                     languageprovider.getlanguage['transfer_detail']['all_btn']??     'ALL',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: linkColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            top: 5,
                            right: 5,
                            left: 5,
                            bottom: 15,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Can be transferred (${_selectedToAccount == 'Margin Account' ? getCoinName(asset.defaultMarginCoin) : getCoinName(asset.defaultCoin)}):',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _availableBalanceFrom,
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            top: 5,
                            right: 5,
                            left: 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                             languageprovider.getlanguage['transfer_detail']['available']??    'Available:',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _availableBalanceFrom,
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: width * 0.9,
                child: ElevatedButton(
                  onPressed: _processTransfer
                      ? null
                      : () {
                          transferringAsset();
                          // snackAlert(context, SnackTypes.warning, 'Coming soon...');
                        },
                  child: _processTransfer
                      ? const CircularProgressIndicator.adaptive()
                      : Text(languageprovider.getlanguage['transfer_detail']['transfer_btn']?? 'Transfer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget digitalAccounts(context, public, asset) {
    return SizedBox(
      width: width * 0.72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(
                    right: _fromDigitalAccountToOtherAccount ? 20 : 36),
                child: Text(_fromDigitalAccountToOtherAccount ? 'From' : 'To'),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  radius: 12,
                  child: Image.network(
                    '${public.publicInfoMarket['market']['coinList'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['icon']}',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 20),
                child: Text('Digital Account'),
              ),
            ],
          ),
          // Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Widget otherAccounts(context, public, asset) {
    return SizedBox(
      width: width * 0.72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(
                    right: !_fromDigitalAccountToOtherAccount ? 20 : 36),
                child: Text(!_fromDigitalAccountToOtherAccount ? 'From' : 'To'),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  radius: 12,
                  child: Image.network(
                    '${public.publicInfoMarket['market']['coinList'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['icon']}',
                  ),
                ),
              ),
              DropdownButton<String>(
                isDense: true,
                value: _selectedToAccount,
                icon: Container(
                  padding: EdgeInsets.only(left: width * 0.191),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
                style: const TextStyle(fontSize: 13),
                underline: Container(
                  height: 0,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedToAccount = newValue!;
                    _availableBalanceFrom = _fromDigitalAccountToOtherAccount
                        ? '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}'
                        : _selectedToAccount == 'Margin Account'
                            ? getMarketBalanceCoin(asset)
                            : '${asset.selectedP2pAssets['normal']}';
                    _availableBalanceTo = _fromDigitalAccountToOtherAccount
                        ? _selectedToAccount == 'Margin Account'
                            ? getMarketBalanceCoin(asset)
                            : '${asset.selectedP2pAssets['normal']}'
                        : '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}';
                  });
                },
                items: _toAccounts.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget selectPair(context, public, assetProvider, setState) {
    width = MediaQuery.of(context).size.width;

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
            itemCount: assetProvider.marginAssets.length,
            itemBuilder: (BuildContext context, int index) {
              var asset = assetProvider.marginAssets[index];

              return ListTile(
                onTap: () {
                  assetProvider.setSelectedMarginAssets(asset);
                  assetProvider.setDefaultMarginCoin(asset['coin']);
                  setState(() {
                    // _selectedMarginAssets = asset;
                    // asset.defaultMarginCoin = asset['coin'];
                    _availableBalanceFrom = _fromDigitalAccountToOtherAccount
                        ? '${assetProvider.accountBalance['allCoinMap'][asset['coin']]['normal_balance']}'
                        : getMarketBalanceCoin(assetProvider);
                    _availableBalanceTo = _fromDigitalAccountToOtherAccount
                        ? getMarketBalanceCoin(assetProvider)
                        : '${assetProvider.accountBalance['allCoinMap'][asset['coin']]['normal_balance']}';
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
                  color: assetProvider.selectedMarginAssets['coin'] ==
                          asset['coin']
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

  Widget selectCoin(context, public, asset, setState) {
    width = MediaQuery.of(context).size.width;

    List _marginCoins = asset.selectedMarginAssets['market'].split('/');

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
            itemCount: _marginCoins.length,
            itemBuilder: (BuildContext context, int index) {
              String marketCoin = _marginCoins[index];

              return ListTile(
                onTap: () {
                  asset.setDefaultMarginCoin(marketCoin);
                  setState(() {
                    // _defaultMarginCoin = marketCoin;
                    _availableBalanceFrom = _fromDigitalAccountToOtherAccount
                        ? '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}'
                        : _selectedToAccount == 'Margin Account'
                            ? getMarketBalanceCoin(asset)
                            : '${asset.selectedP2pAssets['normal']}';
                    _availableBalanceTo = _fromDigitalAccountToOtherAccount
                        ? _selectedToAccount == 'Margin Account'
                            ? getMarketBalanceCoin(asset)
                            : '${asset.selectedP2pAssets['normal']}'
                        : '${asset.accountBalance['allCoinMap'][_selectedToAccount == 'P2P Account' ? asset.defaultCoin : asset.defaultMarginCoin]['normal_balance']}';
                  });
                  Navigator.pop(context);
                },
                leading: CircleAvatar(
                  radius: 15,
                  child: Image.network(
                    '${public.publicInfoMarket['market']['coinList'][marketCoin]['icon']}',
                  ),
                ),
                title: Text(getCoinName(marketCoin)),
                trailing: Icon(
                  Icons.check,
                  color: asset.defaultMarginCoin == marketCoin
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
