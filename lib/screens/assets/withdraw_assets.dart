import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/screens/assets/common/networks.dart';
import 'package:lyotrade/screens/assets/common/qr_scanner.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/drawer.dart';
import 'package:lyotrade/screens/common/header.dart';

import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';

class WithdrawAssets extends StatefulWidget {
  static const routeName = '/withdraw_assets';
  const WithdrawAssets({Key? key}) : super(key: key);

  @override
  State<WithdrawAssets> createState() => _WithdrawAssetsState();
}

class _WithdrawAssetsState extends State<WithdrawAssets> {
  final _formVeriKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _openQrScanner = false;
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  String _defaultNetwork = 'ERC20';
  String _defaultCoin = 'USDT';
  List _allNetworks = [];

  @override
  void initState() {
    getDigitalBalance();
    Future.delayed(const Duration(seconds: 0), () async {
      checkUserAuthMethods();
    });
    super.initState();
  }

  @override
  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    if (controller != null) {
      controller!.resumeCamera();
    }
  }

  Future<void> getDigitalBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getAccountBalance(context, auth, "");
    getCoinCosts(_defaultCoin);
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
    // await asset.getChangeAddress(context, auth, _defaultCoin);

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

  Future<void> changeCoinType(netwrk) async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    setState(() {
      _defaultNetwork = netwrk['mainChainName'];
    });

    await asset.getCoinCosts(auth, netwrk['showName']);
    // await asset.getChangeAddress(context, auth, netwrk['showName']);
  }

  Future<void> checkUserAuthMethods() async {
    var auth = Provider.of<Auth>(context, listen: false);

    if (auth.userInfo.isNotEmpty) {
      if (auth.userInfo['googleStatus'] != 0 ||
          auth.userInfo['mobileNumber'].isEmpty) {
        return showAlert(
          context,
          Icon(
            Icons.featured_play_list,
          ),
          'Tips',
          const <Widget>[
            Text(
              'For the security of your account, please open at least one verification method',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            ListTile(
              title: Text(
                'Connect Google verification',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              trailing: Icon(
                Icons.check,
                size: 15,
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Connect mobile phone verification',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              trailing: Icon(
                Icons.check,
                size: 15,
              ),
            ),
            Divider(),
          ],
          'Settings',
        );
      }
    }
  }

  void addressController(text) {
    _addressController.text = text;
  }

  void toggleOpenQrScanner() {
    setState(() {
      _openQrScanner = !_openQrScanner;
    });
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
      body: Form(
        key: _formVeriKey,
        child: _openQrScanner
            ? QrScanner(
                addressController: addressController,
                toggleOpenQrScanner: toggleOpenQrScanner,
              )
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                    right: 15,
                    left: 15,
                    bottom: 15,
                  ),
                  child: Column(
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
                                  'Withdraw',
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
                        padding: EdgeInsets.only(top: 20, bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 5),
                              child: Text('Chain name'),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.help_outline,
                                size: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 5),
                              child: Text('Fee:'),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 5),
                              child: Text(
                                '${asset.getCost['defaultFee']}',
                                style: TextStyle(
                                  color: linkColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 5),
                              child: Text(_defaultCoin),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 10),
                        height: 45,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _allNetworks.length,
                            itemBuilder: (BuildContext context, int index) {
                              var network = _allNetworks[index];
                              return GestureDetector(
                                onTap: () {
                                  changeCoinType(network);
                                },
                                child: Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: (network['mainChainName'] ==
                                              _defaultNetwork)
                                          ? Color(0xff01FEF5)
                                          : Color(0xff5E6292),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Container(
                                      width: 62,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${network['mainChainName']}",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Wallet Address'),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Address List',
                                style: TextStyle(
                                  color: linkColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5, bottom: 10),
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
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter wallet address';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) async {
                                    print(value);
                                  },
                                  controller: _addressController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                    ),
                                    hintText: "Scan or paste the address",
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 10),
                                    child: GestureDetector(
                                      onTap: () async {
                                        print('paste');
                                        ClipboardData? data =
                                            await Clipboard.getData(
                                                Clipboard.kTextPlain);
                                        _addressController.text =
                                            '${data!.text}';
                                      },
                                      child: Text(
                                        'Paste',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: linkColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        _openQrScanner = true;
                                      });
                                      await controller?.resumeCamera();
                                    },
                                    child: Icon(
                                      Icons.qr_code_scanner,
                                      color: linkColor,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Amount'),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5, bottom: 10),
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
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter amount';
                                    }
                                    return null;
                                  },
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
                                    hintText:
                                        "Min. withdrawal ${asset.getCost['withdraw_min']} ${asset.getCost['withdrawLimitSymbol']}",
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 10),
                                    child: GestureDetector(
                                      onTap: () async {
                                        _amountController.text = asset
                                                .accountBalance['allCoinMap']
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
                          top: 20,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Balances',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${asset.accountBalance['allCoinMap'] != null ? asset.accountBalance['allCoinMap'][_defaultCoin]['total_balance'] : '--'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Available',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${asset.accountBalance['allCoinMap'] != null ? asset.accountBalance['allCoinMap'][_defaultCoin]['normal_balance'] : '--'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Freeze',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${asset.accountBalance['allCoinMap'] != null ? asset.accountBalance['allCoinMap'][_defaultCoin]['lock_balance'] : '--'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      Container(
                        padding: EdgeInsets.only(
                          top: 5,
                          bottom: 10,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 15),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Tips',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Withdrawable',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    '${asset.getCost['can_withdraw_amount']} $_defaultCoin',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '24h Withdrawal Limit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    '${double.parse(asset.getCost['left_withdraw_daily_amount'] ?? '0.00').toStringAsFixed(2)}/${double.parse(asset.getCost['total_withdraw_daily_max_limit'] ?? '0.00').toStringAsFixed(2)} ${asset.getCost['withdrawLimitSymbol']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Icon(
                                          Icons.warning,
                                          size: 15,
                                          color: orangeBGColor,
                                        ),
                                      ),
                                      Text(
                                        'Max Limit:',
                                        style: TextStyle(color: orangeBGColor),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${asset.getCost['withdraw_max']} ${asset.getCost['withdrawLimitSymbol']}',
                                    style: TextStyle(
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
                ),
              ),
      ),
      bottomNavigationBar: Container(
        height: height * 0.1,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 15),
              width: width * 0.9,
              child: ElevatedButton(
                onPressed: () {
                  if (_formVeriKey.currentState!.validate()) {}
                },
                child: Text('Withdraw'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
