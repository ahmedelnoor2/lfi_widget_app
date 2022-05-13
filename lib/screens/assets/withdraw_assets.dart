import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/screens/common/header.dart';

import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

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
          auth.userInfo['mobileNumber'].isNotEmpty) {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 5),
                        child: const Icon(
                          Icons.featured_play_list,
                        ),
                      ),
                      const Text(
                        'Tips',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 15,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
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
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Settings'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
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

                  print(_asset);
                  return ListTile(
                    onTap: () {
                      getCoinCosts(asset.allDigAsset.isNotEmpty
                          ? asset.allDigAsset[index]['coin']
                          : asset.digitialAss[index]['coin']);
                      Navigator.pop(context);
                    },
                    // leading: CircleAvatar(
                    //   radius: width * 0.035,
                    //   child: Image.network(
                    //     '${public.publicInfoMarket['market']['coinList'][_asset['coin']]['icon']}',
                    //   ),
                    // ),
                    title: Text('${_asset['coin']}'),
                    trailing: Text('${_asset['values']['total_balance']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
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
                        icon: Icon(Icons.chevron_right),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.account_balance_wallet),
                      title: Text('Main Account'),
                      subtitle: Text('0 $_defaultCoin'),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.currency_exchange),
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
                          child: Text('Wallet Address'),
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
                        decoration: const InputDecoration(
                          // labelText: "Search",
                          hintText: "Please enter withdraw address",
                          suffix: Icon(Icons.qr_code_scanner),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text('Network'),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.help,
                            size: 15,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: width,
                      padding: const EdgeInsets.all(10),
                      child: DropdownButton<String>(
                        isDense: true,
                        // underline: Container(),
                        value: '$_defaultNetwork',
                        // icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        onChanged: (netwrk) async {
                          print(netwrk);
                          // changeCoinType(netwrk);
                        },
                        items: _allNetworks
                            .map<DropdownMenuItem<String>>((netwrk) {
                          return DropdownMenuItem<String>(
                            value: '${netwrk['mainChainName']}',
                            child: Text(
                              '${netwrk['mainChainName']}',
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        onChanged: (value) async {
                          print(value);
                        },
                        controller: _amountController,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: "Amount",
                          hintText: "Min. withdrawaal 0.0008 BTC",
                          helperText: "24h withdrawal limit 0/1 BTC",
                          suffix: TextButton(
                            onPressed: () {},
                            child: Text('Max'),
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
                          Text('Notice:'),
                          Container(
                            padding: EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Withdrawable:',
                                  style: TextStyle(color: secondaryTextColor),
                                ),
                                Text('50000 USDT'),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '24h Withdrwal Limit:',
                                  style: TextStyle(color: secondaryTextColor),
                                ),
                                Text('50000.00/50000.00 USDT'),
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
                  padding: EdgeInsets.only(left: 20),
                  child: Text('Fee: 0.0005 BTC'),
                ),
              ),
            ),
            SizedBox(
              width: width * 0.9,
              child: ElevatedButton(
                onPressed: null,
                child: Text('Withdraw'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
