import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
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
  List _allNetworks = [];
  List _p2pAssets = [];
  List _marginAssets = [];
  Map _selectedMarginAssets = {};
  Map _selectedP2pAssets = {};
  bool _fromDigitalAccountToOtherAccount = true;

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
    await asset.getAccountBalance(auth, "");
    getCoinCosts(_defaultCoin);
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
    getMarginlBalance();
  }

  String getMarketBalanceCoin() {
    return _defaultMarginCoin == _selectedMarginAssets['coin']
        ? '${_selectedMarginAssets['values']['baseTotalBalance']}'
        : '${_selectedMarginAssets['values']['quoteTotalBalance']}';
  }

  @override
  Widget build(BuildContext context) {
    var public = Provider.of<Public>(context, listen: true);

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
                  '3x',
                  style: TextStyle(color: linkColor),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return transferAsset(
                              context,
                              public,
                              setState,
                            );
                          },
                        );
                      },
                    );
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
                  onTap: () {},
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
                  '999.99',
                  style: TextStyle(
                    color: greenIndicator,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget transferAsset(context, public, setState) {
    height = MediaQuery.of(context).size.height;
    var asset = Provider.of<Asset>(context, listen: false);

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
                            : _selectedToAccount == 'Margin Account'
                                ? getMarketBalanceCoin()
                                : '${_selectedP2pAssets['normal']}';
                        _availableBalanceTo = _fromDigitalAccountToOtherAccount
                            ? _selectedToAccount == 'Margin Account'
                                ? getMarketBalanceCoin()
                                : '${_selectedP2pAssets['normal']}'
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
