import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/dex_provider.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/screens/dex_swap/common/dexBottimSheet.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class ExchangeNow extends StatefulWidget {
  const ExchangeNow({Key? key}) : super(key: key);

  @override
  State<ExchangeNow> createState() => _ExchangeNowState();
}

class _ExchangeNowState extends State<ExchangeNow> {
  final TextEditingController _fromAmountController = TextEditingController();
  final TextEditingController _toAddressController = TextEditingController();

  bool _loadingExchnageRate = false;
  bool _acceptTermsAndConditions = false;
  bool _processSwap = false;
  bool _loadingAddress = false;
  String _defaultNetwork = 'TUSDT';
  String _defaultCoin = 'USDT';
  List _allNetworks = [];
  List _allAvailableCurrency = [];
  Map _getAddressCoins = {};
  bool _processSelectCoin = false;
  bool _minimumvalue = false;
  Timer? _timer = null;

  @override
  void initState() {
    // setState(() {
    //   _fromAmountController.text = '1';
    // });
    getDigitalBalance();

    super.initState();
  }

  @override
  void dispose() async {
    _fromAmountController.dispose();
    _toAddressController.dispose();

    _timer!.cancel();

    super.dispose();
  }

  Future<void> getDigitalBalance() async {
    setState(() {
      _loadingAddress = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getAccountBalance(context, auth, "");
    getCoinAddress(_defaultCoin);
    estimateRates();
  }

  Future<void> getCoinAddress(netwrkType) async {
    var dexProvider = Provider.of<DexProvider>(context, listen: false);

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
          // _defaultNetwork = k;
        });
      });
    } else {
      setState(() {
        _allNetworks.clear();
        _allNetworks
            .add(public.publicInfoMarket['market']['coinList'][netwrkType]);
        _defaultCoin = netwrkType;
        _defaultNetwork =
            '${public.publicInfoMarket['market']['coinList'][netwrkType]['name']}';
      });
    }

    await asset.getChangeAddress(context, auth, _defaultNetwork);
    setState(() {
      _toAddressController.text = asset.changeAddress['addressStr'];
    });

    dexProvider.validateAddress(context, auth, {
      'currency': dexProvider.toActiveCurrency['ticker'],
      'address': asset.changeAddress['addressStr'],
    });

    List _digitialAss = [];
    asset.accountBalance['allCoinMap'].forEach((k, v) {
      if (v['withdrawOpen'] == 1) {
        var aCoin = public.publicInfoMarket['market']['followCoinList'][k];
        if (aCoin != null) {
          aCoin.forEach((aKey, aVal) {
            // print('${aVal['mainChainSymbol']}${aVal['mainChainName']}'.toLowerCase());
            if (aVal['mainChainSymbol'] == aVal['mainChainName']) {
              _allAvailableCurrency
                  .add('${aVal['mainChainSymbol']}'.toLowerCase());
              _getAddressCoins['${aVal['mainChainSymbol']}'.toLowerCase()] =
                  aKey;
            } else {
              _allAvailableCurrency.add(
                  '${aVal['mainChainSymbol']}${aVal['mainChainName']}'
                      .toLowerCase());
              _getAddressCoins[
                  '${aVal['mainChainSymbol']}${aVal['mainChainName']}'
                      .toLowerCase()] = aKey;
            }
          });
        } else {
          _allAvailableCurrency.add(k.toLowerCase());
          _getAddressCoins[k.toLowerCase()] = k;
        }
        // setState(() {
        //   _allAvailableCurrency.add(k);
        // });
      }
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

  Future<void> estimateRates() async {
    setState(() {
      _loadingExchnageRate = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var dexProvider = Provider.of<DexProvider>(context, listen: false);
    await dexProvider.estimateExchangeValue(
      context,
      auth,
      _fromAmountController.text,
      dexProvider.fromActiveCurrency['ticker'],
      dexProvider.toActiveCurrency['ticker'],
    );

    await dexProvider.estimateMinimumValue(
      context,
      auth,
      dexProvider.fromActiveCurrency['ticker'],
      dexProvider.toActiveCurrency['ticker'],
    );
    setState(() {
      _loadingExchnageRate = false;
    });
  }

  Future<void> togglePairs() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    var dexProvider = Provider.of<DexProvider>(context, listen: false);
    HapticFeedback.selectionClick();
    await dexProvider.swapFromAndTo();
    setState(() {
      _defaultNetwork =
          _getAddressCoins[dexProvider.toActiveCurrency['ticker']];
    });
    await asset.getChangeAddress(context, auth,
        _getAddressCoins[dexProvider.toActiveCurrency['ticker']]);
    setState(() {
      _toAddressController.text = asset.changeAddress['addressStr'];
    });
    dexProvider.validateAddress(context, auth, {
      'currency': dexProvider.toActiveCurrency['ticker'],
      'address': asset.changeAddress['addressStr'],
    });

    estimateRates();
  }

  String getEstimateNumber(value) {
    if (('$value'.split('.')[1].length >= 5) ||
        ('$value'.split('.')[0].length >= 5)) {
      return double.parse('$value').toStringAsFixed(4);
    } else {
      return double.parse('$value').toStringAsFixed(3);
    }
  }

  Future<void> processTransaction() async {
    setState(() {
      _processSwap = true;
    });
    var dexProvider = Provider.of<DexProvider>(context, listen: false);
    var postData = {
      "address": _toAddressController.text,
      "amount": _fromAmountController.text,
      "extraId": "",
      "from": dexProvider.fromActiveCurrency['ticker'],
      "refundAddress": "",
      "to": dexProvider.toActiveCurrency['ticker'],
    };

    await dexProvider.processSwapPayment(context, postData);
    Navigator.pop(context);
    setState(() {
      _toAddressController.clear();
      _acceptTermsAndConditions = false;
      _processSwap = false;
    });
    paymentStatusFetch();
  }

  paymentStatusFetch() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      paymentStatus();
    });
  }

  Future<void> paymentStatus() async {
    var dexProvider = Provider.of<DexProvider>(context, listen: false);

    await dexProvider.swapPaymentStatus(
        context, dexProvider.processPayment['id']);
  }

  Future<void> changeCoinType(netwrk) async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    var dexProvider = Provider.of<DexProvider>(context, listen: false);
    await asset.getCoinCosts(auth, netwrk);
    // await asset.getChangeAddress(context, auth, netwrk['showName']);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    var dexProvider = Provider.of<DexProvider>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

    return dexProvider.processPayment.isNotEmpty
        ? sendingWidget(context, dexProvider)
        : SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        width: width,
                        padding: EdgeInsets.only(
                            top: 15, bottom: 15, right: 15, left: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            width: 0.3,
                            color: Color(0xff5E6292),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: InkWell(
                                onTap: () {
                                  showModalBottomSheet<void>(
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return selectCoins(
                                            context,
                                            'from',
                                            dexProvider,
                                            setState,
                                            auth,
                                            asset,
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: EdgeInsets.only(right: 10),
                                        child: dexProvider
                                                .fromActiveCurrency.isNotEmpty
                                            ? SvgPicture.network(
                                                '${dexProvider.fromActiveCurrency['image']}',
                                                width: 35,
                                              )
                                            : Container(),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                                child: Text(
                                                  dexProvider.fromActiveCurrency
                                                          .isNotEmpty
                                                      ? dexProvider
                                                          .fromActiveCurrency[
                                                              'ticker']
                                                          .toUpperCase()
                                                      : '--',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Icon(Icons.keyboard_arrow_down),
                                            ],
                                          ),
                                          Text(
                                            dexProvider.fromActiveCurrency
                                                    .isNotEmpty
                                                ? dexProvider
                                                    .fromActiveCurrency['name']
                                                : '--',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              // width: width * 0.4,
                              child: TextFormField(
                                textAlign: TextAlign.end,
                                controller: _fromAmountController,
                                onChanged: (value) async {
                                  if (value.isNotEmpty) {
                                    if (double.parse(value) > 0 &&
                                        (double.parse(value) >=
                                            double.parse(_loadingExchnageRate
                                                ? '0'
                                                : '${dexProvider.minimumValue['minAmount']}'))) {
                                      estimateRates();
                                    }
                                    if (double.parse(value) <
                                        dexProvider.minimumValue['minAmount']) {
                                      setState(() {
                                        _minimumvalue = true;
                                      });
                                    } else {
                                      setState(() {
                                        _minimumvalue = false;
                                      });
                                    }
                                  }
                                },
                                style: const TextStyle(fontSize: 20),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                  ),
                                  hintText: "From Amount",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _minimumvalue
                            ? Text(
                                'Min amount required: ${_loadingExchnageRate ? '--' : dexProvider.minimumValue['minAmount']} ${dexProvider.fromActiveCurrency.isNotEmpty ? dexProvider.fromActiveCurrency['ticker'].toUpperCase() : '--'}',
                                style: TextStyle(color: warningColor),
                              )
                            : Container(),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: IconButton(
                          onPressed: () async {
                            togglePairs();
                          },
                          icon: Image.asset(
                            'assets/img/transfer.png',
                            width: 32,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet<void>(
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return selectCoins(
                                    context,
                                    'to',
                                    dexProvider,
                                    setState,
                                    auth,
                                    asset,
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 15, bottom: 15, right: 15, left: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
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
                                    child:
                                        dexProvider.toActiveCurrency.isNotEmpty
                                            ? SvgPicture.network(
                                                '${dexProvider.toActiveCurrency['image']}',
                                                width: 35,
                                              )
                                            : Container(),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(right: 10),
                                            child: Text(
                                              dexProvider.toActiveCurrency
                                                      .isNotEmpty
                                                  ? dexProvider
                                                      .toActiveCurrency[
                                                          'ticker']
                                                      .toUpperCase()
                                                  : '--',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.keyboard_arrow_down),
                                        ],
                                      ),
                                      Text(
                                        dexProvider.toActiveCurrency.isNotEmpty
                                            ? dexProvider
                                                .toActiveCurrency['name']
                                            : '--',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Text(
                                dexProvider.estimateValue.isNotEmpty
                                    ? getEstimateNumber(dexProvider
                                        .estimateValue['estimatedAmount'])
                                    : '0.00',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Icon(
                                        Icons.info,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Exchange rate (expected)',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '1 ${dexProvider.fromActiveCurrency.isNotEmpty ? dexProvider.fromActiveCurrency['ticker'].toUpperCase() : '--'} ~ ${dexProvider.estimateValue.isNotEmpty ? getEstimateNumber(dexProvider.estimateValue['estimatedAmount']) : '--'} ${dexProvider.toActiveCurrency.isNotEmpty ? dexProvider.toActiveCurrency['ticker'].toUpperCase() : '--'}',
                                style: TextStyle(color: linkColor),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.visible,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: InkWell(
                    onTap: (_loadingExchnageRate ||
                            _fromAmountController.text.isEmpty ||
                            _minimumvalue == true)
                        ? null
                        : () {
                            showModalBottomSheet<void>(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return swapCoins(
                                      context,
                                      setState,
                                      asset,
                                    );
                                  },
                                );
                              },
                            );
                          },
                    child: Container(
                      width: width,
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 50,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          // color: Color(0xff5E6292),
                          color: (_loadingExchnageRate ||
                                  _fromAmountController.text.isEmpty)
                              ? Color(0xff292C51)
                              : Color(0xff5E6292),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            // style: BorderStyle.solid,
                            width: 0,
                            // color: Color(0xff5E6292),
                            color: (_loadingExchnageRate ||
                                    _fromAmountController.text.isEmpty)
                                ? Colors.transparent
                                : Color(0xff5E6292),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: (_loadingExchnageRate)
                              ? SizedBox(
                                  child: CircularProgressIndicator.adaptive(
                                      strokeWidth: 2),
                                  height: 25,
                                  width: 25,
                                )
                              : Text(
                                  'SWAP Now',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: (_loadingExchnageRate)
                                        ? secondaryTextColor
                                        : Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget selectCoins(context, type, dexProvider, setState, auth, asset) {
    var allCurrencies = dexProvider.allCurrencies;

    return Scaffold(
      appBar: hiddenAppBarWithDefaultHeight(),
      body: _processSelectCoin
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  right: 15,
                  left: 15,
                  bottom: 15,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                                padding: EdgeInsets.only(right: 10),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.chevron_left),
                                ),
                              ),
                              Text(
                                'Select Coin',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                    Column(
                      children: allCurrencies.map<Widget>((currency) {
                        return ((currency['ticker'] ==
                                        dexProvider
                                            .fromActiveCurrency['ticker'] ||
                                    currency['ticker'] ==
                                        dexProvider
                                            .toActiveCurrency['ticker']) ||
                                (!_allAvailableCurrency
                                    .contains(currency['ticker'])))
                            ? Container()
                            : ListTile(
                                onTap: () async {
                                  setState(() {
                                    _processSelectCoin = true;
                                  });
                                  if (type == 'from') {
                                    dexProvider.setFromActiveCurrency(currency);
                                    estimateRates();
                                  } else {
                                    dexProvider.setToActiveCurrency(currency);
                                    setState(() {
                                      _defaultNetwork = _getAddressCoins[
                                          dexProvider
                                              .toActiveCurrency['ticker']];
                                    });
                                    await asset.getChangeAddress(
                                        context,
                                        auth,
                                        _getAddressCoins[dexProvider
                                            .toActiveCurrency['ticker']]);
                                    dexProvider.validateAddress(context, auth, {
                                      'currency': dexProvider
                                          .toActiveCurrency['ticker'],
                                      'address':
                                          asset.changeAddress['addressStr'],
                                    });
                                  }
                                  setState(() {
                                    _toAddressController.text =
                                        asset.changeAddress['addressStr'];
                                  });
                                  setState(() {
                                    _processSelectCoin = false;
                                  });
                                  Navigator.pop(context);
                                },
                                leading: CircleAvatar(
                                  radius: 12,
                                  child: SvgPicture.network(
                                    '${currency['image']}',
                                    width: 50,
                                    placeholderBuilder:
                                        (BuildContext context) =>
                                            const CircularProgressIndicator
                                                .adaptive(),
                                  ),
                                ),
                                title:
                                    Text('${currency['ticker'].toUpperCase()}'),
                              );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget swapCoins(context, setState, asset) {
    var auth = Provider.of<Auth>(context, listen: false);
    var dexProvider = Provider.of<DexProvider>(context, listen: true);

    return Scaffold(
      appBar: hiddenAppBarWithDefaultHeight(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            right: 15,
            left: 15,
            bottom: 15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                          padding: EdgeInsets.only(right: 10),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.chevron_left),
                          ),
                        ),
                        Text(
                          'Swap Coins',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              ),
              Text(
                'Please be carefule not to provide a smart contract as your ${dexProvider.toActiveCurrency['ticker'].toUpperCase()}',
                style: TextStyle(
                  fontSize: 14,
                  color: warningColor,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20),
                width: width,
                child: Text(
                    'Enter the recipient\'s address (${dexProvider.toActiveCurrency['ticker'].toUpperCase()})'),
              ),
              Container(
                padding: EdgeInsets.only(top: 15, bottom: 15),
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
                          // enabled: false,
                          validator: (value) {
                            if (value == null) {
                              return 'Please enter wallet address';
                            } else if (value.isEmpty) {
                              return 'Please enter wallet address';
                            }
                            return null;
                          },
                          onChanged: (value) async {
                            if (value.isNotEmpty) {
                              dexProvider.validateAddress(context, auth, {
                                'currency':
                                    dexProvider.toActiveCurrency['ticker'],
                                'address': value,
                              });
                            }
                          },
                          controller: _toAddressController,
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
                                Clipboard.setData(
                                  ClipboardData(
                                    text: _toAddressController.text,
                                  ),
                                );
                                snackAlert(
                                    context, SnackTypes.success, 'Copied');
                              },
                              child: Text(
                                'Copy',
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
              dexProvider.verifyAddress != null
                  ? dexProvider.verifyAddress.isNotEmpty
                      ? dexProvider.verifyAddress['result'] != null
                          ? !dexProvider.verifyAddress['result']
                              ? Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${dexProvider.verifyAddress['message']}',
                                    style: TextStyle(color: errorColor),
                                  ),
                                )
                              : Container()
                          : Container()
                      : Container()
                  : Container(),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: _acceptTermsAndConditions,
                      onChanged: (newValue) {
                        print(newValue);
                        setState(() {
                          _acceptTermsAndConditions =
                              !_acceptTermsAndConditions;
                        });
                      },
                    ),
                    SizedBox(
                      width: width * 0.8,
                      child: Wrap(
                        children: [
                          Text(
                            'I have read and agree to Terms of Use and Privacy Policy',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.access_time,
                      size: 15,
                      color: linkColor,
                    ),
                  ),
                  Text(
                    'Estimated Time',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 15),
                    child: Text(
                      '10-60 minutes',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: (!_acceptTermsAndConditions ||
                        _toAddressController.text.isEmpty ||
                        !dexProvider.verifyAddress['result'] ||
                        _processSwap)
                    ? null
                    : () {
                        processTransaction();
                      },
                child: Container(
                  width: width,
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 30,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // color: Color(0xff5E6292),
                      color: (!_acceptTermsAndConditions ||
                              _toAddressController.text.isEmpty ||
                              !dexProvider.verifyAddress['result'])
                          ? Color(0xff292C51)
                          : Color(0xff5E6292),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        // style: BorderStyle.solid,
                        width: 0,
                        // color: Color(0xff5E6292),
                        color: (!_acceptTermsAndConditions ||
                                _toAddressController.text.isEmpty ||
                                !dexProvider.verifyAddress['result'])
                            ? Colors.transparent
                            : Color(0xff5E6292),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: (_processSwap)
                          ? SizedBox(
                              child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2),
                              height: 25,
                              width: 25,
                            )
                          : Text(
                              'Process',
                              style: TextStyle(
                                fontSize: 20,
                                color: (!_acceptTermsAndConditions ||
                                        _toAddressController.text.isEmpty ||
                                        !dexProvider.verifyAddress['result'])
                                    ? secondaryTextColor
                                    : Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sendingWidget(context, dexProvider) {
    // print(dexProvider.toActiveCurrency);
    var dexProvider = Provider.of<DexProvider>(context, listen: false);
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              left: 10,
            ),
            padding: EdgeInsets.only(bottom: 10),
            child: Text(dexProvider.paymentStatus['status']==null?'':dexProvider.paymentStatus['status'].toUpperCase()),
          ),
          Container(
            margin: EdgeInsets.only(left: 8, right: 16, bottom: 15),
            child: Stack(
              children: [
                Container(
                  width: size.width,
                  height: 16,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.5),
                      color: Colors.white),
                  child: Container(),
                ),
                Container(
                  padding: EdgeInsets.only(top: 0.5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: Container(
                      width: dexProvider.paymentStatus['status'] == 'confirming'
                          ? size.width * 0.3
                          : dexProvider.paymentStatus['status'] == 'exchanging'
                              ? size.width * 0.75
                              : dexProvider.paymentStatus['status'] == 'sending'
                                  ? size.width * 1.0
                                  : size.width * 0.3,
                      height: 15,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.green.shade500,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Card(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      dexProvider.fromActiveCurrency.isNotEmpty
                          ? Row(
                              children: [
                                SvgPicture.network(
                                  '${dexProvider.fromActiveCurrency['image']}',
                                  width: 35,
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    '${_fromAmountController.text} ${dexProvider.fromActiveCurrency['ticker']}'
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: OutlinedButton(
                          onPressed: () async {
                            await changeCoinType(
                                dexProvider.fromActiveCurrency['ticker']);
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return FractionallySizedBox(
                                      heightFactor: 0.9,
                                      child: dexBottimSheet(
                                          _fromAmountController.text,
                                          dexProvider
                                              .processPayment['payinAddress'],
                                          dexProvider
                                              .fromActiveCurrency['ticker']),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Text('Send'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 150,
                      margin: EdgeInsets.only(top: 10),
                      padding:
                          EdgeInsets.only(top: 2, bottom: 2, right: 2, left: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: 0.3,
                          color: Color(0xff5E6292),
                        ),
                      ),
                      child: Image.network(
                        'https://chart.googleapis.com/chart?chs=200x200&cht=qr&chl=${dexProvider.processPayment['payinAddress']}&choe=UTF-8',
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 0.3,
                        color: Color(0xff5E6292),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: dexProvider.processPayment['payinAddress'],
                          ),
                        );
                        snackAlert(context, SnackTypes.success, 'Copied');
                      },
                      child: Row(
                        children: [
                          Container(
                            width: width * 0.70,
                            child: Text(
                              '${dexProvider.processPayment['payinAddress']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 8),
                            child: Image.asset(
                              'assets/img/copy.png',
                              width: 18,
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
          Align(
            alignment: Alignment.center,
            child: RotatedBox(
              quarterTurns: 1,
              child: Container(
                //padding: EdgeInsets.only(top: 20, bottom: 20),
                child: Image.asset(
                  "assets/img/transfer.gif",
                  width: 70.0,
                ),
              ),
            ),
          ),
          Card(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                    child: Text(
                      'Receive',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Divider(),
                  Container(
                    child: dexProvider.toActiveCurrency.isNotEmpty
                        ? SvgPicture.network(
                            '${dexProvider.toActiveCurrency['image']}',
                            width: 40,
                          )
                        : Container(),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      '${dexProvider.processPayment['amount']}'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5, bottom: 10),
                    child: Text(
                      '${dexProvider.toActiveCurrency['name']} (${dexProvider.toActiveCurrency['ticker']})'
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: 15, bottom: 15, right: 15, left: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 0.3,
                        color: Color(0xff5E6292),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: dexProvider.processPayment['payoutAddress'],
                          ),
                        );
                        snackAlert(context, SnackTypes.success, 'Copied');
                      },
                      child: Row(
                        children: [
                          Container(
                            width: width * 0.70,
                            child: Text(
                              '${dexProvider.processPayment['payoutAddress']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            child: Container(
                              padding: EdgeInsets.only(left: 8),
                              child: Image.asset(
                                'assets/img/copy.png',
                                width: 18,
                              ),
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
        ],
      ),
    );
  }
}
