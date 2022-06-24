import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/assets/skeleton/assets_skull.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Coins.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';

class MarginAssets extends StatefulWidget {
  static const routeName = '/margin_assets';
  const MarginAssets({
    Key? key,
  }) : super(key: key);

  @override
  State<MarginAssets> createState() => _MarginAssetsState();
}

class _MarginAssetsState extends State<MarginAssets> {
  List _marginAssets = [];
  List _smallBalancesMarginAssets = [];
  String _totalBalanceSymbol = 'BTC';
  bool _hideSmallBalances = false;

  final TextEditingController _amountController = TextEditingController();

  String _defaultCoin = 'LYO1';
  String _selectedToAccount = 'Margin Account';
  String _defaultMarginCoin = 'BTC';
  String _defaultMarginPair = 'BTC/USDT';
  List _allNetworks = [];
  List _p2pAssets = [];
  Map _selectedMarginAssets = {};
  bool _fromDigitalAccountToOtherAccount = true;

  String _availableBalanceFrom = '0.000';
  String _availableBalanceTo = '0.000';

  @override
  void initState() {
    getDigitalBalance();
    super.initState();
  }

  Future<void> getDigitalBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    await asset.getMarginBalance(auth);
    List _margAssets = [];
    asset.marginBalance['leverMap'].forEach((k, v) {
      _margAssets.add({
        'coin': k.split('/')[0],
        'market': k,
        'values': v,
      });
    });
    setState(() {
      _marginAssets = _margAssets;
      _totalBalanceSymbol = asset.marginBalance['totalBalanceSymbol'];
    });
  }

  Future<void> getHideSmallBalances() async {
    if (_hideSmallBalances) {
      var asset = Provider.of<Asset>(context, listen: false);
      List _smallBalancesMarAssets = [];

      asset.marginBalance['leverMap'].forEach((k, v) {
        if (double.parse('${v['symbolNetAssetBalance']}') > 0.00) {
          _smallBalancesMarAssets.add({
            'coin': k.split('/')[0],
            'market': k,
            'values': v,
          });
        }
      });
      setState(() {
        _smallBalancesMarginAssets = _smallBalancesMarAssets;
      });
    }
  }

  void toggleHideBalances() {
    var asset = Provider.of<Asset>(context, listen: false);
    asset.toggleHideBalances(!asset.hideBalances);
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);

    bool _hideBalances = asset.hideBalances;
    String _hideBalanceString = asset.hideBalanceString;

    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.chevron_left)),
                      ),
                      Text(
                        'Margin Account',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 15),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, '/margin_transactions');
                          },
                          child: Icon(Icons.history),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          toggleHideBalances();
                        },
                        child: _hideBalances
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                SizedBox(
                  height: height * 0.18,
                  child: Card(
                    color: Colors.transparent,
                    // elevation: 20,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(0.8, 1),
                          colors: <Color>[
                            Color(0xff3F4374),
                            Color(0xff292C51),
                          ],
                          tileMode: TileMode.mirror,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Valuations',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      '${_hideBalances ? _hideBalanceString : asset.marginBalance['totalBalance'] ?? '0.000000'} $_totalBalanceSymbol',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    '≈${_hideBalances ? _hideBalanceString : getNumberFormat(
                                        context,
                                        public.rate[public.activeCurrency['fiat_symbol']
                                                        .toUpperCase()][
                                                    asset.accountBalance[
                                                            _totalBalanceSymbol] ??
                                                        'BTC'] !=
                                                null
                                            ? double.parse(asset.marginBalance['totalbalance'] ?? '0') *
                                                public.rate[public.activeCurrency[
                                                            'fiat_symbol']
                                                        .toUpperCase()]
                                                    [_totalBalanceSymbol]
                                            : 0,
                                      )}',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Text(
                          //       'Yesterday\'s PNL',
                          //       style: TextStyle(
                          //         fontSize: 10,
                          //       ),
                          //     ),
                          //     Row(
                          //       children: [
                          //         Text(
                          //           '\$4.20',
                          //           style: TextStyle(
                          //             fontWeight: FontWeight.bold,
                          //             color: greenlightchartColor,
                          //           ),
                          //         ),
                          //         Text(
                          //           '/0.15%',
                          //           style: TextStyle(
                          //             color: greenlightchartColor,
                          //           ),
                          //         ),
                          //       ],
                          //     )
                          //   ],
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.177,
                  child: Container(
                    padding: EdgeInsets.only(top: 50, right: 12),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Image.asset(
                        'assets/img/asset_background.png',
                        // height: 200,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            Container(
              padding: EdgeInsets.only(
                left: 5,
                right: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Text('Fund list'),
                      ),
                      Container(
                        width: 20,
                        padding: EdgeInsets.only(right: 10),
                        child: Transform.scale(
                          scale: 0.8,
                          child: Checkbox(
                            value: _hideSmallBalances,
                            splashRadius: 20,
                            onChanged: (val) {
                              setState(() {
                                _hideSmallBalances = !_hideSmallBalances;
                              });
                              getHideSmallBalances();
                            },
                          ),
                        ),
                      ),
                      Text('Hide Small Balance'),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.search,
                      size: 18,
                    ),
                  )
                ],
              ),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.only(
                bottom: 5,
                left: 5,
                right: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.33,
                    child: Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.27,
                    child: Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.12,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Freeze',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      width: width * 0.19,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Lent',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(
              height: height * 0.48,
              child: _marginAssets.isEmpty
                  ? assetsSkull(context)
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _hideSmallBalances
                          ? _smallBalancesMarginAssets.length
                          : _marginAssets.length,
                      itemBuilder: (BuildContext context, int index) {
                        var asset = _hideSmallBalances
                            ? _smallBalancesMarginAssets[index]
                            : _marginAssets[index];
                        return Container(
                          padding: EdgeInsets.only(
                            bottom: 10,
                            left: 5,
                            right: 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: width * 0.33,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 8),
                                      child: CircleAvatar(
                                        radius: 15,
                                        child: Image.network(
                                          '${public.publicInfoMarket['market']['coinList'][asset['values']['baseCoin']]['icon']}',
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${getCoinName(asset['values']['name'])}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'LYO Credit',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: width * 0.27,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${_hideBalances ? _hideBalanceString : asset['values']['baseExNormalBalance'].toStringAsFixed(4)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${_hideBalances ? _hideBalanceString : asset['values']['quoteEXNormalBalance'].toStringAsFixed(4)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.12,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _hideBalances
                                            ? _hideBalanceString
                                            : double.parse(
                                                    '${asset['values']['baseLockBalance']}')
                                                .toStringAsFixed(4),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _hideBalances
                                            ? _hideBalanceString
                                            : '${double.parse('${asset['values']['quoteLockBalance']}').toStringAsFixed(4)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.19,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _hideBalances
                                            ? _hideBalanceString
                                            : double.parse(
                                                    '${asset['values']['baseTotalBalance']}')
                                                .toStringAsFixed(4),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _hideBalances
                                            ? _hideBalanceString
                                            : double.parse(
                                                    '${asset['values']['quoteTotalBalance']}')
                                                .toStringAsFixed(4),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Divider(),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.28,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/transfer_assets');
                      },
                      child: Text('Transfer'),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.28,
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return borrowAsset(
                                  context,
                                  public,
                                  setState,
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Text('Loans'),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.28,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/trade');
                      },
                      child: Text('Trade'),
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

  Widget borrowAsset(context, public, setState) {
    height = MediaQuery.of(context).size.height;
    var asset = Provider.of<Asset>(context, listen: false);

    List _marginCoins = _defaultMarginPair.split('/');

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
                'Loans',
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
                            onChanged: (value) async {
                              print(value);
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
                                  _amountController.text =
                                      asset.accountBalance['allCoinMap']
                                          [_defaultCoin]['normal_balance'];
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
                              print('Select preceision');
                            },
                            child: Container(
                              width: width * 0.22,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xff292C51),
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
                                    color: secondaryTextColor,
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
                              print('Select preceision');
                            },
                            child: Container(
                              width: width * 0.22,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xff292C51),
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
                                    color: secondaryTextColor,
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
                              print('Select preceision');
                            },
                            child: Container(
                              width: width * 0.22,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xff292C51),
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
                                    color: secondaryTextColor,
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
                              print('Select preceision');
                            },
                            child: Container(
                              width: width * 0.22,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xff292C51),
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
                                    color: secondaryTextColor,
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
                        '${(double.parse('${asset.marginBalance['leverMap'][_defaultMarginPair]['rate']}') * 100).toStringAsFixed(2)}%',
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
                  padding: EdgeInsets.only(bottom: 15),
                  width: width,
                  child: ElevatedButton(
                    onPressed: () {
                      showAlert(
                        context,
                        Container(),
                        'Alert',
                        [
                          Text('Coming soon...'),
                        ],
                        'Ok',
                      );
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
}
