import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/assets/skeleton/deposit_skull.dart';
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
    getCoinCosts('USDT');
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      appBar: appBar(context, null),
      drawer: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
        ),
        width: width,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: secondaryTextColor,
                      size: 20,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 70),
                    child: const Text('Select Coin'),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: SizedBox(
                height: width * 0.13,
                child: TextField(
                  onChanged: (value) async {
                    await asset.filterSearchResults(value);
                  },
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height * 0.8,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: asset.allDigAsset.isNotEmpty
                    ? asset.allDigAsset.length
                    : asset.digitialAss.length,
                itemBuilder: (context, index) {
                  var _asset = asset.allDigAsset.isNotEmpty
                      ? asset.allDigAsset[index]
                      : asset.digitialAss[index];
                  return ListTile(
                    onTap: () {
                      getCoinCosts(asset.allDigAsset.isNotEmpty
                          ? asset.allDigAsset[index]['coin']
                          : asset.digitialAss[index]['coin']);
                      Navigator.pop(context);
                    },
                    leading: CircleAvatar(
                      radius: width * 0.035,
                      child: Image.network(
                        '${public.publicInfoMarket['market']['coinList'][_asset['coin']]['icon']}',
                      ),
                    ),
                    title: Text('${_asset['coin']}'),
                    trailing: Text('${_asset['values']['total_balance']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Screenshot(
        controller: screenshotController,
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(width * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Deposit $_defaultCoin',
                      style: TextStyle(
                        fontSize: width * 0.05,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _scaffoldKey.currentState!.openDrawer();
                      },
                      child: Row(children: [
                        Text(
                          _defaultCoin,
                          style: TextStyle(
                            fontSize: width * 0.05,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: width * 0.01),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '0.00000',
                      style: TextStyle(fontSize: width * 0.08),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 3, left: 2),
                      child: Text(
                        _defaultCoin,
                        style: TextStyle(
                          fontSize: width * 0.05,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(width * 0.03),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 15),
                      child: Row(
                        children: [
                          Text(
                            'Availalble: ',
                            style: TextStyle(
                              color: secondaryTextColor,
                            ),
                          ),
                          Text(
                            '0.00',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Freeze: ',
                          style: TextStyle(
                            color: secondaryTextColor,
                          ),
                        ),
                        Text(
                          '0.00',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: _loadingAddress
                    ? depositQrSkull(context)
                    : asset.changeAddress['addressQRCode'] != null
                        ? Image.memory(base64Decode(asset
                            .changeAddress['addressQRCode']
                            .split(',')[1]
                            .replaceAll("\n", "")))
                        : const CircularProgressIndicator(),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: width * 0.05,
                  top: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Network',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 10,
                        right: 25,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              print(asset.getCost);
                              return Container(
                                padding: const EdgeInsets.all(20),
                                // height: height * 0.3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            color: secondaryTextColor,
                                            size: 20,
                                          ),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.only(left: 70),
                                          child: const Text('Select Network'),
                                        ),
                                      ],
                                    ),
                                    asset.getCost['mainChainNameTip'] != null
                                        ? Text(
                                            '${asset.getCost['mainChainNameTip'].split('.')[asset.getCost['mainChainNameTip'].split('.').length - 1]}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: secondaryTextColor,
                                            ),
                                          )
                                        : Container(),
                                    Container(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Column(
                                          children: _allNetworks
                                              .map(
                                                (netwrk) => GestureDetector(
                                                  onTap: () {
                                                    changeCoinType(netwrk);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      bottom: 10,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  '${netwrk['mainChainName']}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          18),
                                                                ),
                                                              ],
                                                            ),
                                                            Icon(
                                                              Icons.done,
                                                              size: 18,
                                                              color: netwrk[
                                                                          'mainChainName'] ==
                                                                      _defaultNetwork
                                                                  ? greenBTNBGColor
                                                                  : secondaryTextColor,
                                                            ),
                                                          ],
                                                        ),
                                                        const Divider(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList()),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: width * 0.05,
                  top: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deposit Address',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                    _loadingAddress
                        ? depositAddressSkull(context)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 12),
                                    width: width * 0.75,
                                    child: Text(
                                      '${_defaultNetwork == 'XRP' ? asset.changeAddress['addressStr'].split('_')[0] : asset.changeAddress['addressStr']}',
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: IconButton(
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: _defaultNetwork == 'XRP'
                                                ? asset
                                                    .changeAddress['addressStr']
                                                    .split('_')[0]
                                                : asset.changeAddress[
                                                    'addressStr'],
                                          ),
                                        );
                                        snackAlert(context, SnackTypes.success,
                                            'Copied');
                                      },
                                      icon: const Icon(Icons.copy),
                                    ),
                                  ),
                                ],
                              ),
                              _defaultNetwork == 'XRP'
                                  ? Row(
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          width: width * 0.75,
                                          child: Text(
                                            '${asset.changeAddress['addressStr'].split('_')[1]}',
                                          ),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: IconButton(
                                            onPressed: () {
                                              Clipboard.setData(
                                                ClipboardData(
                                                  text: asset.changeAddress[
                                                          'addressStr']
                                                      .split('_')[1],
                                                ),
                                              );
                                              snackAlert(context,
                                                  SnackTypes.success, 'Copied');
                                            },
                                            icon: const Icon(Icons.copy),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container()
                            ],
                          ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        captureScreen();
                        snackAlert(context, SnackTypes.success,
                            'Address saved to Gallery or Photos.');
                      },
                      child: const Text('Save Address'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        share(
                          '${asset.getCost['withdrawLimitSymbol']} Address',
                          asset.changeAddress['addressStr'],
                        );
                      },
                      child: const Text('Share Address'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
