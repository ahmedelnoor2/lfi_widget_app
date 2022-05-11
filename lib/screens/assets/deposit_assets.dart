import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
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

  String _defaultNetwork = 'ERC20';
  final List _allNetworks = ['ERC20', 'Omni', 'TRC20', 'BSC'];

  @override
  void initState() {
    getCoinCosts();
    super.initState();
  }

  Future<void> getCoinCosts() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    await asset.getCoinCosts(auth, 'EUSDT');
    await asset.getChangeAddress(auth, 'EUSDT');
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
        print('saved');
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var asset = Provider.of<Asset>(context, listen: true);

    return Scaffold(
      appBar: appBar(context, null),
      body: Screenshot(
        controller: screenshotController,
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(width * 0.05),
                child: Text(
                  'Deposit ${asset.getCost['withdrawLimitSymbol']}',
                  style: TextStyle(
                    fontSize: width * 0.05,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: asset.changeAddress['addressQRCode'] != null
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
                      style: TextStyle(color: secondaryTextColor, fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10, right: 25),
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
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
                                    Text(
                                      '${asset.getCost['mainChainNameTip'].split('.')[asset.getCost['mainChainNameTip'].split('.').length - 2]}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Column(
                                          children: _allNetworks
                                              .map(
                                                (netwrk) => GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _defaultNetwork = netwrk;
                                                    });
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
                                                                  '$netwrk',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          18),
                                                                ),
                                                              ],
                                                            ),
                                                            Icon(
                                                              Icons.done,
                                                              size: 18,
                                                              color: netwrk ==
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 12),
                          width: width * 0.75,
                          child: Text(
                            '${asset.changeAddress['addressStr']}',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10),
                          child: IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: asset.changeAddress['addressStr'],
                                ),
                              );
                              snackAlert(context, SnackTypes.success, 'Copied');
                            },
                            icon: const Icon(Icons.copy),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        captureScreen();
                        snackAlert(
                            context, SnackTypes.success, 'Address saved');
                      },
                      child: const Text('Save Address'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        share('${asset.getCost['withdrawLimitSymbol']} Address',
                            asset.changeAddress['addressStr']);
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
