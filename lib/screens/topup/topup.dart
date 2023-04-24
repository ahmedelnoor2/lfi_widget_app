import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/topup.dart';
import 'package:lyotrade/screens/common/drawer.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/screens/topup/mobile_topup_payment.dart';
import 'package:lyotrade/screens/topup/widget/amount_select_Bottom_sheet.dart';
import 'package:lyotrade/screens/topup/widget/networkbottomsheet.dart';
import 'package:lyotrade/screens/topup/widget/topupCountryDrawer.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class TopUp extends StatefulWidget {
  static const routeName = '/topup';
  const TopUp({Key? key}) : super(key: key);

  @override
  State<TopUp> createState() => _TopUpState();
}

class _TopUpState extends State<TopUp> {
  String _defaultCoin = 'USDTBSC';
  double _selectedPercentage = 0;
  List _allNetworks = [];
  String _defaultNetwork = 'BSC';
  String _coinShowName = 'USDT';
  bool _tagType = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    getDigitalBalance();
    getAcountBalance();
    getAllCountries();
  }

  Future<void> getDigitalBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    if (asset.selectedAsset.isNotEmpty) {
      setState(() {
        _defaultCoin =
            '${public.publicInfoMarket['market']['coinList'][asset.selectedAsset['coin']]['name']}';
      });
    }
    await asset.getAccountBalance(context, auth, _defaultCoin);

    await getCoinCosts(_coinShowName);
    await asset.getChangeAddress(context, auth, _defaultCoin);
  }

  Future<void> getCoinCosts(netwrkType) async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);

    await asset.getChangeAddress(context, auth, _defaultCoin);

    if (public.publicInfoMarket['market']['followCoinList'][netwrkType] !=
        null) {
      setState(() {
        _allNetworks.clear();
      });

      public.publicInfoMarket['market']['followCoinList'][netwrkType]
          .forEach((k, v) {
        if (v['followCoinWithdrawOpen'] == 1) {
          setState(() {
            _allNetworks.add(v);
            _defaultCoin = '${v['name']}';
            _defaultNetwork = '${v['name']}';
            _coinShowName = '${v['showName']}';
          });

          if (v['tagType'] == 0) {
            setState(() {
              _tagType = false;
            });
          } else {
            setState(() {
              _tagType = true;
            });
          }
        }
      });
    } else {
      if (public.publicInfoMarket['market']['coinList'][netwrkType]
              ['tagType'] ==
          0) {
        setState(() {
          _tagType = false;
        });
      } else {
        setState(() {
          _tagType = true;
        });
      }
      setState(() {
        _allNetworks.clear();
        _allNetworks
            .add(public.publicInfoMarket['market']['coinList'][netwrkType]);
        _defaultCoin =
            '${public.publicInfoMarket['market']['coinList'][netwrkType]['name']}';
        _defaultNetwork =
            '${public.publicInfoMarket['market']['coinList'][netwrkType]['name']}';
        _coinShowName =
            '${public.publicInfoMarket['market']['coinList'][netwrkType]['showName']}';
      });
    }
    await asset.getCoinCosts(auth, _defaultCoin);
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

  Future<void> getAllCountries() async {
    var topupProvider = Provider.of<TopupProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await topupProvider.getAllCountries(context, auth, userid);
    await getAllTopUpNetwork();
  }

  Future<void> getAllTopUpNetwork() async {
    var topupProvider = Provider.of<TopupProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await topupProvider.getAllNetWorkprovider(context, auth, userid,
        {"country": topupProvider.toActiveCountry['isoName']}, true);
    topupProvider.settopupamount(
        topupProvider.toActiveNetWorkprovider['price_type']['type'] == 'FIXED'
            ? topupProvider.toActiveNetWorkprovider['price_type']['price'][0]
            : topupProvider.toActiveNetWorkprovider['price_type']['price']
                ['suggestedPrice'][0]);
    await topupProvider.getEstimateRate(context, auth, userid, {
      "currency": "${topupProvider.toActiveCountry['currencyCode']}",
      "payment": topupProvider.topupamount,
    });
  }

  // Get  Accout balance company lyo/
  Future<void> getAcountBalance() async {
    var topupProvider = Provider.of<TopupProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await topupProvider.getaccountBalance(context, auth, userid);
  }

  // Get Estimate Rate//
  Future<void> getEstimateRate() async {
    var topupProvider = Provider.of<TopupProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await topupProvider.getEstimateRate(context, auth, userid, {
      "currency": "${topupProvider.toActiveCountry['currencyCode']}",
      "payment": topupProvider.topupamount,
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    var topupProvider = Provider.of<TopupProvider>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);
    var public = Provider.of<Public>(context, listen: true);
    return Scaffold(
      key: _scaffoldKey,
      drawer: const TopupConfirmDrawer(),
      endDrawer: drawer(
        context,
        width,
        height,
        asset,
        public,
        _searchController,
        getCoinCosts,
        topupProvider.allwallet,
      ),
      appBar: hiddenAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 10, top: 10),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.chevron_left),
                      ),
                    ),
                    Text(
                      'Topup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/topup_transaction');
                    },
                    icon: Icon(Icons.history),
                  ),
                ),
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text('Phone Number')),
                  Container(
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
                        InkWell(
                          onTap: () {
                            _scaffoldKey.currentState!.openDrawer();
                          },
                          child: Container(
                            width: width * 0.25,
                            height: height * 0.07,
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: topupProvider.isCountryLoading
                                      ? CircularProgressIndicator()
                                      : Text(topupProvider.toActiveCountry[
                                                  'callingCodes'] ==
                                              null
                                          ? ''
                                          : topupProvider
                                              .toActiveCountry['callingCodes']
                                                  [0]
                                              .toString()),
                                ),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: width * 0.65,
                                child: TextFormField(
                                  // The validator receives the text that the user has entered.
                                  keyboardType: TextInputType.phone,
                                  autocorrect: false,
                                  controller: _numberController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter phone number';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter phone number',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Text('Network Provider')),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.85,
                                  child: const TopupNetworkBottomSheet());
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      width: width,
                      height: height * 0.07,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          style: BorderStyle.solid,
                          width: 0.3,
                          color: Color(0xff5E6292),
                        ),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          topupProvider.toActiveNetWorkprovider['logo'] == null
                              ? Container()
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: FadeInImage.memoryNetwork(
                                    width: 40,
                                    height: 40,
                                    placeholder: kTransparentImage,
                                    image: topupProvider
                                        .toActiveNetWorkprovider['logo'][0]
                                        .toString(),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          Text(topupProvider
                                  .toActiveNetWorkprovider['operatorName'] ??
                              ''),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Text('Topup Amount')),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.85,
                                  child: const AmountSelectBottomSheet());
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      width: width,
                      height: height * 0.07,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          style: BorderStyle.solid,
                          width: 0.3,
                          color: Color(0xff5E6292),
                        ),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "${(topupProvider.topupamount * topupProvider.toActiveNetWorkprovider['fx']['rate']).toStringAsFixed(2)}"),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated Rate',
                            style: TextStyle(color: secondaryTextColor400),
                          ),
                          topupProvider.isEstimate
                              ? CircularProgressIndicator()
                              : Text('${topupProvider.estimateRate}'
                                      ' ' +
                                  'USDT')
                        ]),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _scaffoldKey.currentState!.openEndDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 20, bottom: 10, left: 16, right: 16),
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
                                '${public.publicInfoMarket['market']['coinList'][_coinShowName]['icon']}',
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 5),
                            child: Text(
                              _coinShowName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '${public.publicInfoMarket['market']['coinList'][_coinShowName]['longName']}',
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
                  height: 60,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 10, left: 16, right: 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wallet Balance',
                      style: TextStyle(color: secondaryTextColor400),
                    ),
                    Row(
                      children: [
                        Text(asset.accountBalance['allCoinMap'] == null
                            ? ''
                            : asset.accountBalance['allCoinMap'][_coinShowName]
                                    ['allBalance']
                                .toString()),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(_coinShowName),
                        )
                      ],
                    )
                  ]),
            ),
            SizedBox(
              height: height * 0.08,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LyoButton(
                onPressed: () {
                  if (topupProvider.accountBalance['balance'] <
                      double.parse(asset.accountBalance['allCoinMap']
                          [_coinShowName]['allBalance'])) {
                    snackAlert(context, SnackTypes.warning,
                        'Please Contact Admin Balance is low ...');
                  } else if (_formKey.currentState!.validate()) {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return SingleChildScrollView(
                              child: Container(
                                  child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                width: width,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    height: 400,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                                child: Text('Confirm Top up')),
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
                                          ],
                                        ),
                                        SizedBox(
                                          height: height * 0.04,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                                "${(topupProvider.topupamount * topupProvider.toActiveNetWorkprovider['fx']['rate']).toStringAsFixed(2)}" +
                                                    " " +
                                                    topupProvider
                                                            .toActiveCountry[
                                                        'currencyCode'])
                                          ],
                                        ),
                                        SizedBox(
                                          height: height * 0.04,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Payment Currency',
                                              style: TextStyle(
                                                  color: secondaryTextColor400),
                                            ),
                                            Text(topupProvider.estimateRate
                                                .toString())
                                          ],
                                        ),
                                        SizedBox(
                                          height: height * 0.03,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Payment Method',
                                              style: TextStyle(
                                                  color: secondaryTextColor400),
                                            ),
                                            Text('Funding wallet')
                                          ],
                                        ),
                                        Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: width * 0.35,
                                              child: LyoButton(
                                                onPressed: () {},
                                                text: 'Cancel',
                                                isLoading: false,
                                                active: true,
                                                activeTextColor: Colors.black,
                                              ),
                                            ),
                                            Container(
                                              width: width * 0.55,
                                              child: LyoButton(
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                      context, '/mobile_topup',
                                                      arguments: MobileTopup(
                                                          number:
                                                              _numberController
                                                                  .text,
                                                          amount: topupProvider
                                                              .estimateRate,
                                                          defaultcoin:
                                                              _defaultCoin,
                                                          topupamount:
                                                              topupProvider
                                                                  .topupamount,
                                                          countrycode: topupProvider
                                                                  .toActiveCountry[
                                                              'isoName'],
                                                          operatorid: topupProvider
                                                                  .toActiveNetWorkprovider[
                                                              'operatorId']));
                                                },
                                                text: 'Confirm',
                                                isLoading: false,
                                                active: true,
                                                activeColor: linkColor,
                                                activeTextColor: Colors.black,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                            );
                          },
                        );
                      },
                    );
                  }
                },
                text: 'Confirm',
                isLoading: false,
                active: true,
                activeColor: linkColor,
                activeTextColor: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
