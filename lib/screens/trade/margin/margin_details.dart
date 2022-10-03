import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class MarginDetails extends StatefulWidget {
  const MarginDetails({Key? key}) : super(key: key);

  @override
  State<MarginDetails> createState() => _MarginDetailsState();
}

class _MarginDetailsState extends State<MarginDetails> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _defaultCoin = 'LYO1';
  List _toAccounts = ['P2P Account', 'Margin Account'];
  String _selectedToAccount = 'Margin Account';
  String _defaultMarginCoin = 'BTC';
  String _defaultMarginPair = 'BTC/USDT';
  List _allNetworks = [];
  List _p2pAssets = [];
  List _marginAssets = [];
  Map _selectedMarginAssets = {};
  bool _fromDigitalAccountToOtherAccount = true;
  double _currentAmountSelection = 0;

  String _availableBalanceFrom = '0.000';
  String _availableBalanceTo = '0.000';

  @override
  void initState() {
    
    super.initState();
    getDigitalBalance();
    getMarginlBalance();
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

    getCoinCosts(_defaultCoin);
  }

  Future<void> getMarginlBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    if (auth.isAuthenticated) {
      await asset.getMarginBalance(auth);
      List _margAssets = [];
      asset.marginBalance['leverMap'].forEach((k, v) async {
        if (k.split('/')[0] == _defaultMarginCoin) {
          setState(() {
            _selectedMarginAssets = {
              'coin': k.split('/')[0],
              'market': k,
              'values': v,
            };
          });
          await asset.getMarginSymbolBalance(
              auth, _selectedMarginAssets['values']['symbol'].toUpperCase());
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
    }
  }

  Future<void> getCoinCosts(netwrkType) async {
    setState(() {
      _defaultCoin = netwrkType;
    });
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
    getMarginlBalance();
  }

  String getMarketBalanceCoin() {
    return _defaultMarginCoin == _selectedMarginAssets['coin']
        ? '${_selectedMarginAssets['values']['baseTotalBalance']}'
        : '${_selectedMarginAssets['values']['quoteTotalBalance']}';
  }

  Future<void> updateDefaultMarginCoin(public) async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    var newDefaultMarginCoin = public.activeMarket['showName'].split('/')[0];
    for (var marginAsset in _marginAssets) {
      if (marginAsset['coin'] == newDefaultMarginCoin) {
        setState(() {
          _defaultMarginCoin = marginAsset['coin'];
          _defaultMarginPair = marginAsset['market'];
          _selectedMarginAssets = marginAsset;
        });
        await asset.getMarginSymbolBalance(
            auth, _selectedMarginAssets['values']['symbol'].toUpperCase());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var public = Provider.of<Public>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);

    if (_defaultMarginPair.split('/')[0] !=
        public.activeMarket['showName'].split('/')[0]) {
      updateDefaultMarginCoin(public);
    }

    String _riskRate = '--';
    if (auth.isAuthenticated) {
      _riskRate = asset.marginSymbolBalance.isEmpty
          ? '--'
          : '${asset.marginSymbolBalance['riskRate']}';
    }

    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 10,
        left: 20,
        right: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: 5),
                child: Text(
                  'Cross',
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  '${public.activeMarket['multiple']}x',
                  style: TextStyle(color: linkColor),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _amountController.clear();
                      _currentAmountSelection = 0;
                    });
                    auth.isAuthenticated
                        ? showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter updateState) {
                                  return transferAsset(
                                    context,
                                    public,
                                    updateState,
                                  );
                                },
                              );
                            },
                          )
                        : Navigator.pushNamed(context, '/authentication');
                  },
                  child: Container(
                    padding:
                        EdgeInsets.only(top: 2, bottom: 2, left: 4, right: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xff292C51),
                      ),
                      color: Color(0xff292C51),
                      borderRadius: BorderRadius.all(
                        Radius.circular(2),
                      ),
                    ),
                    child: Text(
                      'Transfer',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor400,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 5),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _amountController.clear();
                      _currentAmountSelection = 0;
                    });
                    auth.isAuthenticated
                        ? showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return borrowAsset(
                                    context,
                                    public,
                                    setState,
                                  );
                                },
                              );
                            },
                          )
                        : Navigator.pushNamed(context, '/authentication');
                  },
                  child: Container(
                    padding:
                        EdgeInsets.only(top: 2, bottom: 2, left: 4, right: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xff292C51),
                      ),
                      color: Color(0xff292C51),
                      borderRadius: BorderRadius.all(
                        Radius.circular(2),
                      ),
                    ),
                    child: Text(
                      'Borrow',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: 5),
                child: Text(
                  'Risk rate:',
                  style: TextStyle(
                    color: secondaryTextColor,
                  ),
                ),
              ),
              SizedBox(
                child: Text(
                  _riskRate,
                  style: TextStyle(
                    color: (_riskRate == '--' || _riskRate == '0')
                        ? secondaryTextColor
                        : (double.parse(_riskRate) > 0)
                            ? greenIndicator
                            : redIndicator,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> borrowMarginWallet() async {
    var asset = Provider.of<Asset>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);

    Navigator.pop(context);
    await asset.borrowMarginWallet(context, auth, {
      'amount': _amountController.text,
      'coin': _defaultMarginCoin,
      'symbol': _selectedMarginAssets['values']['symbol'].toUpperCase(),
    });

    await asset.getMarginSymbolBalance(
        auth, _selectedMarginAssets['values']['symbol'].toUpperCase());
  }

  Widget borrowAsset(context, public, setState) {
    height = MediaQuery.of(context).size.height;
    var asset = Provider.of<Asset>(context, listen: true);

    List _marginCoins = _defaultMarginPair.isNotEmpty
        ? _defaultMarginPair.split('/')
        : ['BTC', 'USDT'];

    return Container(
      padding: EdgeInsets.all(10),
      height: height * 0.65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Borrow',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  size: 20,
                ),
              )
            ],
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                width: 0.3,
                color: Color(0xff5E6292),
              ),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              value: _defaultMarginPair,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              underline: Container(
                height: 0,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _defaultMarginPair = newValue!;
                  _defaultMarginCoin = newValue.split('/')[0];
                });
              },
              items: _marginAssets.map<DropdownMenuItem<String>>(
                (marginAsset) {
                  List _marginPairCoins = marginAsset['market'].split('/');
                  return DropdownMenuItem<String>(
                      value: marginAsset['market'],
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                child: CircleAvatar(
                                  radius: 12,
                                  child: Image.network(
                                    '${public.publicInfoMarket['market']['coinList'][_marginPairCoins[0]]['icon']}',
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 15),
                                child: CircleAvatar(
                                  radius: 12,
                                  child: Image.network(
                                    '${public.publicInfoMarket['market']['coinList'][_marginPairCoins[1]]['icon']}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 5),
                            child: Text(marginAsset['market']),
                          ),
                          Text(
                            '${public.publicInfoMarket['market']['coinList'][_marginPairCoins[0]]['longName']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ));
                },
              ).toList(),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              bottom: 10,
              top: 10,
            ),
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
          Container(
            width: width,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                width: 0.3,
                color: Color(0xff5E6292),
              ),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              value: _defaultMarginCoin,
              icon: Container(
                // padding: EdgeInsets.only(left: width * 0.24),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              underline: Container(
                height: 0,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _defaultMarginCoin = newValue!;
                });
              },
              items: _marginCoins.map<DropdownMenuItem<String>>(
                (value) {
                  return DropdownMenuItem<String>(
                    value: value,
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
                                  '${public.publicInfoMarket['market']['coinList'][value]['icon']}',
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 5),
                              child: Text(value),
                            ),
                            Text(
                              '${public.publicInfoMarket['market']['coinList'][value]['longName']}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text(
                    'The number of tranfers',
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
                            onChanged: (value) {
                              setState(() {
                                _currentAmountSelection = value.isEmpty
                                    ? 0
                                    : (double.parse(value) /
                                                    double.parse(
                                                        '${asset.marginSymbolBalance['baseCanBorrow']}')) *
                                                100 ==
                                            double.infinity
                                        ? 0
                                        : (double.parse(value) /
                                                double.parse(
                                                    '${asset.marginSymbolBalance['baseCanBorrow']}')) *
                                            100;
                              });
                            },
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
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
                              hintText: "Please enter the number of transfers",
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    _currentAmountSelection = 100;
                                    _amountController
                                        .text = _defaultMarginCoin ==
                                            asset
                                                .marginSymbolBalance['baseCoin']
                                        ? '${double.parse('${asset.marginSymbolBalance['baseCanBorrow']}')}'
                                        : '${double.parse('${asset.marginSymbolBalance['quoteCanBorrow']}')}';
                                  });
                                },
                                child: Text(
                                  'ALL',
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
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _currentAmountSelection = 25;
                                _amountController.text = _defaultMarginCoin ==
                                        asset.marginSymbolBalance['baseCoin']
                                    ? '${double.parse('${asset.marginSymbolBalance['baseCanBorrow']}') * 0.25}'
                                    : '${double.parse('${asset.marginSymbolBalance['quoteCanBorrow']}') * 0.25}';
                              });
                            },
                            child: Container(
                              width: width * 0.22,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _currentAmountSelection >= 25
                                      ? linkColor
                                      : Color(0xff292C51),
                                ),
                                color: Color(0xff292C51),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '25%',
                                  style: TextStyle(
                                    color: _currentAmountSelection >= 25
                                        ? linkColor
                                        : secondaryTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _currentAmountSelection = 50;
                                _amountController.text = _defaultMarginCoin ==
                                        asset.marginSymbolBalance['baseCoin']
                                    ? '${double.parse('${asset.marginSymbolBalance['baseCanBorrow']}') * 0.50}'
                                    : '${double.parse('${asset.marginSymbolBalance['quoteCanBorrow']}') * 0.50}';
                              });
                            },
                            child: Container(
                              width: width * 0.22,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _currentAmountSelection >= 50
                                      ? linkColor
                                      : Color(0xff292C51),
                                ),
                                color: Color(0xff292C51),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '50%',
                                  style: TextStyle(
                                    color: _currentAmountSelection >= 50
                                        ? linkColor
                                        : secondaryTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _currentAmountSelection = 75;
                                _amountController.text = _defaultMarginCoin ==
                                        asset.marginSymbolBalance['baseCoin']
                                    ? '${double.parse('${asset.marginSymbolBalance['baseCanBorrow']}') * 0.75}'
                                    : '${double.parse('${asset.marginSymbolBalance['quoteCanBorrow']}') * 0.75}';
                              });
                            },
                            child: Container(
                              width: width * 0.22,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _currentAmountSelection >= 75
                                      ? linkColor
                                      : Color(0xff292C51),
                                ),
                                color: Color(0xff292C51),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '75%',
                                  style: TextStyle(
                                    color: _currentAmountSelection >= 75
                                        ? linkColor
                                        : secondaryTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _currentAmountSelection = 100;
                                _amountController.text = _defaultMarginCoin ==
                                        asset.marginSymbolBalance['baseCoin']
                                    ? '${double.parse('${asset.marginSymbolBalance['baseCanBorrow']}') * 1}'
                                    : '${double.parse('${asset.marginSymbolBalance['quoteCanBorrow']}') * 1}';
                              });
                            },
                            child: Container(
                              width: width * 0.22,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _currentAmountSelection >= 100
                                      ? linkColor
                                      : Color(0xff292C51),
                                ),
                                color: Color(0xff292C51),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '100%',
                                  style: TextStyle(
                                    color: _currentAmountSelection >= 100
                                        ? linkColor
                                        : secondaryTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                        'Interest rate:',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${double.parse('${asset.marginSymbolBalance['rate']}') * 100}%',
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
                    bottom: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lent:',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _defaultMarginCoin ==
                                asset.marginSymbolBalance['baseCoin']
                            ? '${double.parse('${asset.marginSymbolBalance['baseTotalBorrow']}')}'
                            : '${double.parse('${asset.marginSymbolBalance['quoteTotalBorrow']}')}',
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
                    right: 5,
                    left: 5,
                    bottom: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Maximum amount:',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _defaultMarginCoin ==
                                asset.marginSymbolBalance['baseCoin']
                            ? '${double.parse('${asset.marginSymbolBalance['baseCanBorrow']}')}'
                            : '${double.parse('${asset.marginSymbolBalance['quoteCanBorrow']}')}',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 15),
                  width: width,
                  child: ElevatedButton(
                    onPressed: () {
                      borrowMarginWallet();
                    },
                    child: Text('Borrow'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> transferringAsset() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var trading = Provider.of<Trading>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    Map formData = {
      "amount": _amountController.text,
      "coinSymbol": _defaultMarginCoin,
      "fromAccount": _fromDigitalAccountToOtherAccount ? "1" : "2",
      "symbol": _selectedMarginAssets['values']['symbol'],
      "toAccount": _fromDigitalAccountToOtherAccount ? "2" : "1",
    };

    Navigator.pop(context);
    await asset.makeMarginTransfer(context, auth, formData);
    getDigitalBalance();
    getMarginlBalance();
  }

  Widget transferAsset(context, public, setState) {
    height = MediaQuery.of(context).size.height;
    var asset = Provider.of<Asset>(context, listen: false);

    List _marginCoins = _selectedMarginAssets.isNotEmpty
        ? _selectedMarginAssets['market'].split('/')
        : ['BTC', 'USDT'];

    return Container(
      padding: EdgeInsets.all(10),
      height: height * 0.65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transfer of funds',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  size: 20,
                ),
              )
            ],
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
                          ? digitalAccounts(context, public)
                          : otherAccounts(context, public),
                      SizedBox(
                        width: width * 0.72,
                        child: Divider(),
                      ),
                      !_fromDigitalAccountToOtherAccount
                          ? digitalAccounts(context, public)
                          : otherAccounts(context, public),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _fromDigitalAccountToOtherAccount =
                            !_fromDigitalAccountToOtherAccount;
                        _availableBalanceFrom = _fromDigitalAccountToOtherAccount
                            ? '${asset.accountBalance['allCoinMap'][_defaultCoin]['normal_balance']}'
                            : getMarketBalanceCoin();
                        _availableBalanceTo = _fromDigitalAccountToOtherAccount
                            ? getMarketBalanceCoin()
                            : '${asset.accountBalance['allCoinMap'][_defaultCoin]['normal_balance']}';
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
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                width: 0.3,
                color: Color(0xff5E6292),
              ),
            ),
            child: SizedBox(
              width: width * 0.9,
              child: DropdownButton<String>(
                isExpanded: true,
                isDense: true,
                value: _defaultMarginCoin,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                underline: Container(
                  height: 0,
                ),
                onChanged: (String? newValue) {
                  print('Before: $_defaultMarginCoin');
                  setState(() {
                    _defaultMarginCoin = newValue!;
                  });
                  print('After: $_defaultMarginCoin');
                },
                items: _marginCoins.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 10),
                            child: CircleAvatar(
                              radius: 12,
                              child: Image.network(
                                '${public.publicInfoMarket['market']['coinList'][value]['icon']}',
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 5),
                            child: Text(value),
                          ),
                          Text(
                            '${public.publicInfoMarket['market']['coinList'][value]['longName']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ));
                }).toList(),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text(
                    'The number of tranfers',
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
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              signed: true,
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: TextStyle(
                                fontSize: 14,
                              ),
                              hintText: "Please enter the number of transfers",
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _amountController.text =
                                        _fromDigitalAccountToOtherAccount
                                            ? '${asset.accountBalance['allCoinMap'][_defaultMarginCoin]['normal_balance']}'
                                            : _defaultMarginCoin ==
                                                    asset.marginBalance[
                                                                'leverMap']
                                                            [_defaultMarginPair]
                                                        ['baseCoin']
                                                ? '${asset.marginBalance['leverMap'][_defaultMarginPair]['baseNormalBalance']}'
                                                : '${asset.marginBalance['leverMap'][_defaultMarginPair]['quoteNormalBalance']}';
                                  });
                                },
                                child: Text(
                                  'ALL',
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
                        'Can be transferred ($_defaultMarginCoin):',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _fromDigitalAccountToOtherAccount
                            ? '${asset.accountBalance['allCoinMap'][_defaultMarginCoin]['normal_balance']}'
                            : _defaultMarginCoin ==
                                    asset.marginBalance['leverMap']
                                        [_defaultMarginPair]['baseCoin']
                                ? '${asset.marginBalance['leverMap'][_defaultMarginPair]['baseNormalBalance']}'
                                : '${asset.marginBalance['leverMap'][_defaultMarginPair]['quoteNormalBalance']}',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 15),
                  width: width,
                  child: ElevatedButton(
                    onPressed: () {
                      transferringAsset();
                      // showAlert(
                      //   context,
                      //   Container(),
                      //   'Alert',
                      //   [
                      //     Text('Coming soon...'),
                      //   ],
                      //   'Ok',
                      // );
                    },
                    child: Text('Transfer'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget digitalAccounts(context, public) {
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
                    _selectedToAccount == 'Margin Account'
                        ? '${public.publicInfoMarket['market']['coinList'][_defaultMarginCoin]['icon']}'
                        : '${public.publicInfoMarket['market']['coinList'][_defaultCoin]['icon']}',
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

  Widget otherAccounts(context, public) {
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
                    _selectedToAccount == 'Margin Account'
                        ? '${public.publicInfoMarket['market']['coinList'][_defaultMarginCoin]['icon']}'
                        : '${public.publicInfoMarket['market']['coinList'][_defaultCoin]['icon']}',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 20),
                child: Text('Leveraged account'),
              ),
            ],
          ),
          // Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}
