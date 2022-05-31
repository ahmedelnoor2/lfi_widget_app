import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/assets/common/networks.dart';
import 'package:lyotrade/screens/assets/skeleton/deposit_skull.dart';
import 'package:lyotrade/screens/common/drawer.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

import 'package:screenshot/screenshot.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class DepositAssets extends StatefulWidget {
  static const routeName = '/deposit_assets';
  const DepositAssets({Key? key}) : super(key: key);

  @override
  State<DepositAssets> createState() => _DepositAssetsState();
}

class _DepositAssetsState extends State<DepositAssets> {
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loadingAddress = false;
  String _defaultNetwork = 'ERC20';
  String _defaultCoin = 'USDT';
  List _allNetworks = [];
  // List _digAssets = [];

  @override
  void initState() {
    getDigitalBalance();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getDigitalBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getAccountBalance(auth, "");
    getCoinCosts('USDT');
  }

  Future<void> getCoinCosts(netwrkType) async {
    setState(() {
      _loadingAddress = true;
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

    await asset.getCoinCosts(auth, _defaultNetwork);
    await asset.getChangeAddress(auth, _defaultNetwork);

    List _digitialAss = [];
    asset.accountBalance['allCoinMap'].forEach((k, v) {
      if (v['depositOpen'] == 1) {
        _digitialAss.add({
          'coin': k,
          'values': v,
        });
      }
    });

    setState(() {
      _loadingAddress = false;
    });
    asset.setDigAssets(_digitialAss);
  }

  Future<void> share(title, text) async {
    await FlutterShare.share(
      title: '$title',
      text: '$text',
    );
  }

  Future<void> captureScreen() async {
    screenshotController.capture().then((image) async {
      final String dir = (await getApplicationDocumentsDirectory()).path;
      final String fullPath = '$dir/${DateTime.now().millisecond}.png';
      File capturedFile = File(fullPath);
      await capturedFile.writeAsBytes(image!);

      GallerySaver.saveImage(capturedFile.path).then((path) {
        // print('saved');
      });
    }).catchError((onError) {
      // print(onError);
    });
  }

  Future<void> changeCoinType(netwrk) async {
    setState(() {
      _loadingAddress = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    setState(() {
      _defaultNetwork = netwrk['mainChainName'];
    });
    await asset.getCoinCosts(auth, netwrk['showName']);
    await asset.getChangeAddress(auth, netwrk['showName']);
    setState(() {
      _loadingAddress = false;
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            right: 15,
            left: 15,
            bottom: 15,
          ),
          child: Screenshot(
            controller: screenshotController,
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              'Deposit',
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
                          )),
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
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Deposit Address',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                style: BorderStyle.solid,
                                width: 0.3,
                                color: Color(0xff5E6292),
                              ),
                            ),
                            width: 134,
                            height: 134,
                            child: _loadingAddress
                                ? depositQrSkull(context)
                                : asset.changeAddress['addressQRCode'] != null
                                    ? Image.memory(
                                        base64Decode(
                                          asset.changeAddress['addressQRCode']
                                              .split(',')[1]
                                              .replaceAll("\n", ""),
                                        ),
                                      )
                                    : const CircularProgressIndicator
                                        .adaptive(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: Text('Wallet Address:'),
                  ),
                  Container(
                    width: width,
                    height: height * 0.058,
                    padding: EdgeInsets.only(
                      top: 5,
                      bottom: 5,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          style: BorderStyle.solid,
                          width: 0.3,
                          color: Color(0xff5E6292),
                        ),
                      ),
                      child: _loadingAddress
                          ? depositAddressSkull(context)
                          : Row(
                              children: [
                                SizedBox(
                                  width: width * 0.8,
                                  child: Text(
                                    '${_defaultNetwork == 'XRP' ? asset.changeAddress['addressStr'].split('_')[0] : asset.changeAddress['addressStr']}',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: _defaultNetwork == 'XRP'
                                            ? asset.changeAddress['addressStr']
                                                .split('_')[0]
                                            : asset.changeAddress['addressStr'],
                                      ),
                                    );
                                    snackAlert(
                                        context, SnackTypes.success, 'Copied');
                                  },
                                  child: Image.asset(
                                    'assets/img/copy.png',
                                    width: 18,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  _defaultNetwork == 'XRP'
                      ? Container(
                          width: width,
                          height: height * 0.058,
                          padding: EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                style: BorderStyle.solid,
                                width: 0.3,
                                color: Color(0xff5E6292),
                              ),
                            ),
                            child: _loadingAddress
                                ? depositAddressSkull(context)
                                : Row(
                                    children: [
                                      SizedBox(
                                        width: width * 0.8,
                                        child: Text(
                                          '${_defaultNetwork == 'XRP' ? asset.changeAddress['addressStr'].split('_')[1] : asset.changeAddress['addressStr']}',
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text: _defaultNetwork == 'XRP'
                                                  ? asset.changeAddress[
                                                          'addressStr']
                                                      .split('_')[1]
                                                  : asset.changeAddress[
                                                      'addressStr'],
                                            ),
                                          );
                                          snackAlert(context,
                                              SnackTypes.success, 'Copied');
                                        },
                                        child: Image.asset(
                                          'assets/img/copy.png',
                                          width: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        )
                      : Container(),
                  Container(
                    padding: EdgeInsets.only(
                      top: 20,
                      bottom: 10,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          padding: EdgeInsets.only(bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      // padding: const EdgeInsets.all(40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width * 0.44,
                            child: ElevatedButton(
                              onPressed: () {
                                captureScreen();
                                snackAlert(context, SnackTypes.success,
                                    'Address saved to Gallery or Photos.');
                              },
                              child: const Text('Save Address'),
                            ),
                          ),
                          SizedBox(
                            width: width * 0.44,
                            child: ElevatedButton(
                              onPressed: () {
                                share(
                                  '${asset.getCost['withdrawLimitSymbol']} Address',
                                  asset.changeAddress['addressStr'],
                                );
                              },
                              child: const Text('Share Address'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
