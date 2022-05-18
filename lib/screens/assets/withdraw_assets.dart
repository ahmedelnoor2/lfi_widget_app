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
    getCoinCosts(_defaultCoin);
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
    controller!.resumeCamera();
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
    await asset.getChangeAddress(auth, _defaultCoin);

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
    await asset.getChangeAddress(auth, netwrk['showName']);
  }

  Future<void> checkUserAuthMethods() async {
    var auth = Provider.of<Auth>(context, listen: false);

    if (auth.userInfo.isNotEmpty) {
      if (auth.userInfo['googleStatus'] != 0 ||
          auth.userInfo['mobileNumber'].isEmpty) {
        return showAlert(
          context,
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
      appBar: appBar(context, null),
      drawer: drawer(
        context,
        width,
        height,
        asset,
        public,
        _searchController,
        getCoinCosts,
      ),
      body: _openQrScanner
          ? QrScanner(
              addressController: addressController,
              toggleOpenQrScanner: toggleOpenQrScanner,
            )
          : SingleChildScrollView(
              child: SizedBox(
                child: Column(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () {
                              _scaffoldKey.currentState!.openDrawer();
                            },
                            leading: CircleAvatar(
                              radius: 15,
                              child: Image.network(
                                '${public.publicInfoMarket['market']['coinList'][_defaultCoin]['icon']}',
                              ),
                            ),
                            title: Text(_defaultCoin),
                            trailing: IconButton(
                              onPressed: () {
                                _scaffoldKey.currentState!.openDrawer();
                              },
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.account_balance_wallet),
                            title: const Text('Main Account'),
                            subtitle: Text(
                              '${asset.accountBalance['allCoinMap'][_defaultCoin]['normal_balance']} $_defaultCoin',
                            ),
                            trailing: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.currency_exchange),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 15),
                                child: const Text('Wallet Address'),
                              ),
                              TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Address Book',
                                    style: TextStyle(fontSize: 12),
                                  ))
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: TextField(
                              onChanged: (value) async {
                                print(value);
                              },
                              controller: _addressController,
                              decoration: InputDecoration(
                                // labelText: "Search",
                                hintText: "Please enter withdraw address",
                                suffix: SizedBox(
                                  width: 112,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          ClipboardData? data =
                                              await Clipboard.getData(
                                                  Clipboard.kTextPlain);
                                          _addressController.text =
                                              '${data!.text}';
                                        },
                                        icon: const Icon(Icons.content_paste),
                                        color: secondaryTextColor,
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            _openQrScanner = true;
                                          });
                                          await controller?.resumeCamera();
                                        },
                                        icon: const Icon(Icons.qr_code_scanner),
                                        color: secondaryTextColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 15),
                                child: const Text('Network'),
                              ),
                              IconButton(
                                onPressed: () {
                                  asset.getCost['mainChainNameTip'].isNotEmpty
                                      ? showDialog<void>(
                                          context: context,
                                          barrierDismissible:
                                              false, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Text('Tips:'),
                                                        Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: IconButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            icon: const Icon(
                                                              Icons.close,
                                                              size: 15,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      '${asset.getCost['mainChainNameTip']}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : null;
                                },
                                icon: const Icon(
                                  Icons.help,
                                  size: 15,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                              top: 10,
                              right: 15,
                              left: 15,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return networks(
                                      context,
                                      asset,
                                      _allNetworks,
                                      _defaultNetwork,
                                      changeCoinType,
                                    );
                                  },
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _defaultNetwork,
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
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
                                isDense: true,
                                labelText: "Amount",
                                hintText:
                                    "Min. withdrawal ${asset.getCost['withdraw_min']} ${asset.getCost['withdrawLimitSymbol']}",
                                helperText:
                                    "Fee: ${asset.getCost['defaultFee']}",
                                suffix: TextButton(
                                  onPressed: () {
                                    _amountController.text =
                                        asset.accountBalance['allCoinMap']
                                            [_defaultCoin]['normal_balance'];
                                  },
                                  child: const Text('MAX'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(13),
                            width: width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tips'),
                                Container(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Withdrawable:',
                                        style: TextStyle(
                                            color: secondaryTextColor),
                                      ),
                                      Text(
                                          '${asset.getCost['can_withdraw_amount']} $_defaultCoin'),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '24h Withdrwal Limit:',
                                        style: TextStyle(
                                            color: secondaryTextColor),
                                      ),
                                      Text(
                                        '${double.parse(asset.getCost['left_withdraw_daily_amount'] ?? '0.00').toStringAsFixed(2)}/${double.parse(asset.getCost['total_withdraw_daily_max_limit'] ?? '0.00').toStringAsFixed(2)} ${asset.getCost['withdrawLimitSymbol']}',
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 15),
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
                                            style:
                                                TextStyle(color: orangeBGColor),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${asset.getCost['withdraw_max']} ${asset.getCost['withdrawLimitSymbol']}',
                                        style: TextStyle(color: orangeBGColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        height: height * 0.15,
        color: Colors.grey[800],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: const Text('Fee: 0.0005 BTC'),
                ),
              ),
            ),
            SizedBox(
              width: width * 0.9,
              child: const ElevatedButton(
                onPressed: null,
                child: Text('Withdraw'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      _addressController.text = '${scanData.code}';
      setState(() {
        _openQrScanner = false;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    // print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      snackAlert(context, SnackTypes.errors, 'No permissions');
    }
  }
}
