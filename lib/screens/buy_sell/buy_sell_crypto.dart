import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/buy_sell/common/crypto_coin_drawer.dart';
import 'package:lyotrade/screens/buy_sell/common/fiat_coin_drawer.dart';
import 'package:lyotrade/screens/buy_sell/common/onramper_crypto_coins.dart';
import 'package:lyotrade/screens/buy_sell/common/onramper_fiat_coins.dart';
import 'package:lyotrade/screens/buy_sell/common/selectPaymentMethod.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:webviewx/webviewx.dart';

import 'common/selectOnrampProvider.dart';

class BuySellCrypto extends StatefulWidget {
  static const routeName = '/buy_sell_crypto';
  const BuySellCrypto({Key? key}) : super(key: key);

  @override
  State<BuySellCrypto> createState() => _BuySellCryptoState();
}

class _BuySellCryptoState extends State<BuySellCrypto> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fiatController = TextEditingController();
  final TextEditingController _cryptoController = TextEditingController();

  final TextEditingController _fiatOnrampController = TextEditingController();
  final TextEditingController _cryptoOnrampController = TextEditingController();

  Map<dynamic, TextEditingController> _textControllers = {};

  bool _loadingCoins = false;
  String _defaultNetwork = '';
  String _currentAddress = '';
  String _providerType = 'guardarian';

  String _defaultOnrampNetwork = 'BTC';
  String _currentOnrampAddress = '';
  bool _selectorFalse = false;

  @override
  void initState() {
    getCurrencies();
    getOnRamperDetails();
    super.initState();
  }

  @override
  void dispose() async {
    _fiatController.dispose();
    _cryptoController.dispose();
    _fiatOnrampController.dispose();
    _cryptoOnrampController.dispose();
    super.dispose();
  }

  Future<void> getOnRamperDetails() async {
    var payments = Provider.of<Payments>(context, listen: false);
    await payments.getOnRamperDetails(context);
    if (payments.onRamperDetails.isNotEmpty) {
      setState(() {
        _fiatOnrampController.text =
            '${payments.onRamperDetails['defaultAmounts'][payments.selectedOnrampFiatCurrency['code']]}';
      });
      getEstimateRate(payments.onRamperDetails['defaultAmounts']
          [payments.selectedOnrampFiatCurrency['code']]);
    }
  }

  Future<void> getEstimateRate(amount) async {
    var asset = Provider.of<Asset>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var payments = Provider.of<Payments>(context, listen: false);

    await payments.getOnrampEstimateRate(context, {
      "fromCurrency": payments.selectedOnrampFiatCurrency['code'],
      "toCurrency": payments.selectedOnrampCryptoCurrency['code'],
      "paymentMethod": payments.defaultOnrampGateway['paymentMethods'][0],
      "amount": amount
    });

    if (payments.estimateOnrampRate.isEmpty) {
      setState(() {
        _fiatOnrampController.clear();
        _cryptoOnrampController.clear();
      });
    }
  }

  Future<void> callOnrampForm() async {
    print(_textControllers);
  }

  Future<void> getDigitalBalance() async {
    setState(() {
      _loadingCoins = true;
    });

    var payments = Provider.of<Payments>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    if (public.publicInfoMarket['market']['followCoinList']
            [payments.selectedCryptoCurrency['current_ticker'].toUpperCase()] !=
        null) {
      public.publicInfoMarket['market']['followCoinList']
              [payments.selectedCryptoCurrency['current_ticker'].toUpperCase()]
          .forEach((key, _network) {
        if (_network['tokenBase'] ==
            payments.selectedCryptoCurrency['network'].toUpperCase()) {
          _defaultNetwork = _network['showName'];
        }
      });
    } else {
      if (public.publicInfoMarket['market']['coinList'][payments
              .selectedCryptoCurrency['current_ticker']
              .toUpperCase()]['tokenBase'] ==
          payments.selectedCryptoCurrency['network'].toUpperCase()) {
        _defaultNetwork = public.publicInfoMarket['market']['coinList'][
                payments.selectedCryptoCurrency['current_ticker'].toUpperCase()]
            ['showName'];
      }

      if (payments.selectedCryptoCurrency['current_ticker'] == 'sol') {
        if ('${public.publicInfoMarket['market']['coinList']['${payments.selectedCryptoCurrency['current_ticker'].toUpperCase()}1']['tokenBase']}' ==
            '${payments.selectedCryptoCurrency['network'].toUpperCase()}1') {
          _defaultNetwork =
              '${public.publicInfoMarket['market']['coinList']['${payments.selectedCryptoCurrency['current_ticker'].toUpperCase()}1']['showName']}';
        }
      }
    }

    // Map _availableCoinLists = {};
    // if (asset.accountBalance.isNotEmpty) {
    //   asset.accountBalance['allCoinMap'].forEach((key, value) {
    //     if (value['depositOpen'] == 1) {
    //       if (public.publicInfoMarket['market']['followCoinList'][
    //               public.publicInfoMarket['market']['coinList'][key]['name']] !=
    //           null) {
    //         public.publicInfoMarket['market']['followCoinList']
    //                 [public.publicInfoMarket['market']['coinList'][key]['name']]
    //             .forEach((networkKey, network) {
    //           _availableCoinLists[networkKey] = {
    //             "coin": key,
    //             "mainChainName": network['mainChainName'],
    //             "network": network['name']
    //           };
    //         });
    //       } else {
    //         _availableCoinLists[public.publicInfoMarket['market']['coinList']
    //             [key]['name']] = {
    //           "coin": key,
    //           "mainChainName": public.publicInfoMarket['market']['coinList']
    //               [key]['mainChainName'],
    //           "network": public.publicInfoMarket['market']['coinList'][key]
    //               ['name']
    //         };
    //       }
    //     }
    //   });
    // }

    // print(_availableCoinLists.length);

    // if (public.publicInfoMarket['market']['followCoinList']
    //         [payments.selectedCryptoCurrency['current_ticker'].toUpperCase()] !=
    //     null) {
    //   public.publicInfoMarket['market']['followCoinList']
    //           [payments.selectedCryptoCurrency['current_ticker'].toUpperCase()]
    //       .forEach((k, v) {
    //     if (payments.selectedCryptoCurrency['network'].toUpperCase() ==
    //         v['tokenBase']) {
    //       setState(() {
    //         _defaultNetwork = '${v['name']}';
    //       });
    //     }
    //   });
    // }

    if (_defaultNetwork.isNotEmpty) {
      await asset.getChangeAddress(context, auth, _defaultNetwork);
      if (asset.changeAddress['addressStr'] != null) {
        setState(() {
          _currentAddress = asset.changeAddress['addressStr'];
        });
      }
    }

    setState(() {
      _loadingCoins = false;
    });
  }

  Future<void> estimateCrypto(payments) async {
    var auth = Provider.of<Auth>(context, listen: false);
    await payments.getEstimateRate(context, auth, {
      'from_currency': payments.selectedFiatCurrency['ticker'],
      'from_amount': _fiatController.text,
      'to_currency': payments.selectedCryptoCurrency['current_ticker'],
      'to_network': payments.selectedCryptoCurrency['network'],
      'to_amount': _cryptoController.text,
    });
    getDigitalBalance();
    return;
  }

  Future<void> getCurrencies() async {
    setState(() {
      _fiatController.text = '1500';
      _cryptoController.text = '1';
      _loadingCoins = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var payments = Provider.of<Payments>(context, listen: false);

    await payments.getFiatCurrencies(context, auth);
    await payments.getCryptoCurrencies(context, auth);
    await estimateCrypto(payments);
    if (payments.estimateRate.isNotEmpty) {
      setState(() {
        _cryptoController.text = payments.estimateRate['value'];
      });
    } else {
      setState(() {
        _cryptoController.text = '0';
      });
    }
    getDigitalBalance();
    setState(() {
      _loadingCoins = false;
    });
  }

  Future<void> processBuy() async {
    setState(() {
      _loadingCoins = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var payments = Provider.of<Payments>(context, listen: false);

    await payments.createTransaction(context, auth, {
      'from_currency': payments.selectedFiatCurrency['ticker'],
      'from_amount': _fiatController.text,
      'to_currency': payments.selectedCryptoCurrency['current_ticker'],
      'to_network': payments.selectedCryptoCurrency['network'],
      'to_amount': payments.estimateRate['value'],
      'payout_address': _currentAddress,
      'deposit_type': 'SEPA_2',
      'payout_type': 'CRYPTO_THROUGH_CN',
    });

    setState(() {
      _loadingCoins = false;
    });
    if (payments.changenowTransaction.isNotEmpty) {
      if (payments.changenowTransaction['redirect_url'] != null) {
        // _launchUrl(payments.changenowTransaction['redirect_url']);
        Navigator.pushNamed(context, '/process_payment');
      }
    }
  }

  Future<void> processOnrampOrder() async {
    var payments = Provider.of<Payments>(context, listen: false);

    if (payments.estimateOnrampRate['nextStep']['type'] == 'iframe') {
      _launchUrl(payments.estimateOnrampRate['nextStep']['url']);
    }

    if ((payments.estimateOnrampRate['nextStep']['type'] == 'form') ||
        (payments.estimateOnrampRate['nextStep']['type'] == 'wait')) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: hiddenAppBarWithDefaultHeight(),
                body: onrampFormSheet(
                  context,
                  setState,
                  payments.estimateOnrampRate['nextStep'],
                ),
              );
            },
          );
        },
      );
    }
  }

  void _launchUrl(_url) async {
    final Uri url = Uri.parse(_url);
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

  void changeOnrampCrpto() async {
    var payments = Provider.of<Payments>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    setState(() {
      _loadingCoins = true;
    });

    if (public.publicInfoMarket['market']['followCoinList']
            [payments.selectedOnrampCryptoCurrency['code'].toUpperCase()] !=
        null) {
      public.publicInfoMarket['market']['followCoinList']
              [payments.selectedOnrampCryptoCurrency['code'].toUpperCase()]
          .forEach((key, _network) {
        try {
          if (_network['mainChainName'] ==
              ((payments.selectedOnrampCryptoCurrency['id'].split('_').length >
                      1)
                  ? (payments.selectedOnrampCryptoCurrency['id']
                      .split('_')[1]
                      .toUpperCase())
                  : payments.selectedOnrampCryptoCurrency['id']
                      .toUpperCase())) {
            setState(() {
              _defaultOnrampNetwork = _network['showName'];
            });
          } else {
            setState(() {
              _defaultOnrampNetwork = '';
            });
          }
        } catch (e) {
          try {
            if (_network['mainChainName'] ==
                (payments.selectedOnrampCryptoCurrency['network']
                        .replaceAll("-", ""))
                    .toUpperCase()) {
              setState(() {
                _defaultOnrampNetwork = _network['showName'];
              });
            }
          } catch (e) {
            setState(() {
              _defaultOnrampNetwork = '';
            });
          }
        }
      });
    } else {
      try {
        if (public.publicInfoMarket['market']['coinList'][
                    payments.selectedOnrampCryptoCurrency['code'].toUpperCase()]
                ['mainChainName'] ==
            (payments.selectedOnrampCryptoCurrency['network']
                    .replaceAll("-", ""))
                .toUpperCase()) {
          setState(() {
            _defaultOnrampNetwork = public.publicInfoMarket['market']
                        ['coinList'][
                    payments.selectedOnrampCryptoCurrency['code'].toUpperCase()]
                ['showName'];
          });
        } else {
          setState(() {
            _defaultOnrampNetwork = '';
          });
        }

        if (payments.selectedOnrampCryptoCurrency['id'] == 'SOL') {
          if ('${public.publicInfoMarket['market']['coinList']['${payments.selectedOnrampCryptoCurrency['id'].toUpperCase()}1']['mainChainName']}' ==
              '${payments.selectedOnrampCryptoCurrency['id'].toUpperCase()}1') {
            setState(() {
              _defaultOnrampNetwork =
                  '${public.publicInfoMarket['market']['coinList']['${payments.selectedOnrampCryptoCurrency['id'].toUpperCase()}1']['showName']}';
            });
          } else {
            setState(() {
              _defaultOnrampNetwork = '';
            });
          }
        }
      } catch (e) {
        setState(() {
          _defaultOnrampNetwork = '';
        });
      }
    }

    if (_defaultOnrampNetwork.isNotEmpty) {
      await asset.getChangeAddress(context, auth, _defaultOnrampNetwork);

      print(asset.changeAddress);

      if (asset.changeAddress['addressStr'] != null) {
        setState(() {
          _currentOnrampAddress = asset.changeAddress['addressStr'];
        });
      }
    } else {
      setState(() {
        _currentOnrampAddress = '';
      });
    }
    print(_currentOnrampAddress);

    setState(() {
      _loadingCoins = false;
    });
  }

  void toggleProvider(value) async {
    setState(() {
      _providerType = value;
      _loadingCoins = true;
    });

    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    if (_providerType == 'guardarian') {
      if (_defaultNetwork.isNotEmpty) {
        await asset.getChangeAddress(context, auth, _defaultNetwork);
        if (asset.changeAddress['addressStr'] != null) {
          setState(() {
            _currentAddress = asset.changeAddress['addressStr'];
          });
        }
      }
    } else {
      if (_defaultOnrampNetwork.isNotEmpty) {
        await asset.getChangeAddress(context, auth, _defaultOnrampNetwork);

        if (asset.changeAddress['addressStr'] != null) {
          setState(() {
            _currentOnrampAddress = asset.changeAddress['addressStr'];
          });
        }
      } else {
        await asset.getChangeAddress(context, auth, _defaultOnrampNetwork);

        if (asset.changeAddress['addressStr'] != null) {
          setState(() {
            _currentOnrampAddress = asset.changeAddress['addressStr'];
          });
        }
      }
    }
    setState(() {
      _loadingCoins = false;
    });
  }

  Future<void> processOnrampBuy(formDetails) async {
    var data = {};
    var payments = Provider.of<Payments>(context, listen: false);
    for (var key in _textControllers.keys) {
      data[key] = _textControllers[key]!.text;
    }

    await payments.callOnrampForm(context, {
      'url': payments.estimateOnrampRate['nextStep']['url'],
      'data': jsonEncode(data)
    });

    if (payments.formCallResponse.isNotEmpty) {
      if (payments.formCallResponse['type'] == 'form') {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: hiddenAppBarWithDefaultHeight(),
                  body: onrampFormSheet(
                    context,
                    setState,
                    payments.formCallResponse['nextStep'],
                  ),
                );
              },
            );
          },
        );
      } else {
        _launchUrl(payments.formCallResponse['url']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var payments = Provider.of<Payments>(context, listen: true);

    return WillPopScope(
      onWillPop: () {
        return onAndroidBackPress(context);
      },
      child: Scaffold(
        appBar: hiddenAppBar(),
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              
              Column(
                children: [
                  Row(
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
                            'Buy Crypto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, '/buy_sell_transactions');
                        },
                        icon: Icon(Icons.history),
                      )
                    ],
                  ),
                  Divider(),
                  _selectorFalse
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  toggleProvider('guardarian');
                                },
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      style: BorderStyle.solid,
                                      width: 1,
                                      color: _providerType == 'guardarian'
                                          ? linkColor
                                          : secondaryTextColor,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: Radio(
                                          activeColor: linkColor,
                                          value: 'guardarian',
                                          groupValue: _providerType,
                                          onChanged: (value) {
                                            setState(() {
                                              _providerType = value as String;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text(
                                                'GUARDARIAN',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: _providerType ==
                                                          'guardarian'
                                                      ? Colors.white
                                                      : secondaryTextColor,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                '1% Fee',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: secondaryTextColor,
                                                ),
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
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  toggleProvider('onramper');
                                },
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      style: BorderStyle.solid,
                                      width: 1,
                                      color: _providerType == 'onramper'
                                          ? linkColor
                                          : secondaryTextColor,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: Radio(
                                          activeColor: linkColor,
                                          value: 'onramper',
                                          groupValue: _providerType,
                                          onChanged: (value) {
                                            setState(() {
                                              _providerType = value as String;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text(
                                                'Onramper',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: _providerType ==
                                                          'onramper'
                                                      ? Colors.white
                                                      : secondaryTextColor,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                '1% Fee',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: secondaryTextColor,
                                                ),
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
                          ],
                        ),
                  _providerType == 'guardarian'
                      ? Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(0xff292C51),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    style: BorderStyle.solid,
                                    width: 0.3,
                                    color: Color(0xff5E6292),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'From',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * 0.5,
                                              child: TextFormField(
                                                onChanged: (value) {
                                                  if (value.isNotEmpty) {
                                                    estimateCrypto(payments);
                                                  }
                                                },
                                                controller: _fiatController,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                  decimal: true,
                                                ),
                                                style: const TextStyle(
                                                    fontSize: 22),
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  isDense: true,
                                                  border: UnderlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  hintStyle: TextStyle(
                                                    fontSize: 22,
                                                  ),
                                                  hintText: "0.00",
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: width * 0.30,
                                          child: InkWell(
                                            onTap: () {
                                              showModalBottomSheet<void>(
                                                context: context,
                                                isScrollControlled: true,
                                                builder:
                                                    (BuildContext context) {
                                                  return StatefulBuilder(
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter setState) {
                                                      return Scaffold(
                                                        resizeToAvoidBottomInset:
                                                            false,
                                                        appBar:
                                                            hiddenAppBarWithDefaultHeight(),
                                                        body: selectFiatCoin(
                                                          context,
                                                          setState,
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      right: 10),
                                                  child: CircleAvatar(
                                                    radius: 14,
                                                    child: payments
                                                            .selectedFiatCurrency
                                                            .isNotEmpty
                                                        ? SvgPicture.network(
                                                            '$changeNowApi${payments.selectedFiatCurrency['icon']['url']}',
                                                            width: 50,
                                                          )
                                                        : payments
                                                                .selectedOnrampFiatCurrency
                                                                .isNotEmpty
                                                            ? Image.memory(
                                                                base64Decode(
                                                                  payments
                                                                      .onRamperDetails[
                                                                          'icons']
                                                                          [
                                                                          payments
                                                                              .selectedOnrampFiatCurrency['code']]
                                                                          [
                                                                          'icon']
                                                                      .split(',')[
                                                                          1]
                                                                      .replaceAll(
                                                                          "\n",
                                                                          ""),
                                                                ),
                                                              )
                                                            : Container(),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    right: 10,
                                                  ),
                                                  child: payments
                                                          .selectedFiatCurrency
                                                          .isNotEmpty
                                                      ? Text(
                                                          '${payments.selectedFiatCurrency['ticker'].toUpperCase()}',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        )
                                                      : Container(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'To',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                            payments.estimateLoader
                                                ? SizedBox(
                                                    child:
                                                        CircularProgressIndicator
                                                            .adaptive(
                                                      strokeWidth: 2,
                                                    ),
                                                    height: 25,
                                                    width: 25,
                                                  )
                                                : Text(
                                                    '${payments.estimateRate.isNotEmpty ? double.parse('${payments.estimateRate['value'] ?? 0.00}').toStringAsFixed(4) : 0.00}',
                                                    style:
                                                        TextStyle(fontSize: 22),
                                                  ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: width * 0.30,
                                          child: InkWell(
                                            onTap: () {
                                              showModalBottomSheet<void>(
                                                context: context,
                                                isScrollControlled: true,
                                                builder:
                                                    (BuildContext context) {
                                                  return StatefulBuilder(
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter setState) {
                                                      return Scaffold(
                                                        resizeToAvoidBottomInset:
                                                            false,
                                                        appBar:
                                                            hiddenAppBarWithDefaultHeight(),
                                                        body: selectCryptoCoin(
                                                          context,
                                                          setState,
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      right: 10),
                                                  child: CircleAvatar(
                                                    radius: 14,
                                                    child: payments
                                                            .selectedCryptoCurrency
                                                            .isNotEmpty
                                                        ? SvgPicture.network(
                                                            '$changeNowApi${payments.selectedCryptoCurrency['icon']['url']}',
                                                            width: 50,
                                                          )
                                                        : Container(),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    right: 10,
                                                  ),
                                                  child: payments
                                                          .selectedCryptoCurrency
                                                          .isNotEmpty
                                                      ? Text(
                                                          '${payments.selectedCryptoCurrency['current_ticker'].toUpperCase()}',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        )
                                                      : Container(),
                                                ),
                                              ],
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
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Estimated rate',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  payments.estimateRate.isEmpty
                                      ? Container()
                                      : Text(
                                          '1 ${payments.selectedCryptoCurrency['current_ticker'] != null ? payments.selectedCryptoCurrency['current_ticker'].toUpperCase() : ''} ~ ${(double.parse(_fiatController.text) / double.parse('${payments.estimateRate['value'] ?? 0.00}')).toStringAsFixed(4)} ${payments.selectedFiatCurrency['ticker'].toUpperCase()}'),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(0xff292C51),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    style: BorderStyle.solid,
                                    width: 0.3,
                                    color: Color(0xff5E6292),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'From',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * 0.5,
                                              child: TextFormField(
                                                onChanged: (value) {
                                                  if (value.isNotEmpty) {
                                                    if (double.parse(value) >=
                                                        100) {
                                                      getEstimateRate(value);
                                                    } else {}
                                                  }
                                                },
                                                controller:
                                                    _fiatOnrampController,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                  decimal: true,
                                                ),
                                                style: const TextStyle(
                                                    fontSize: 22),
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  isDense: true,
                                                  border: UnderlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  hintStyle: TextStyle(
                                                    fontSize: 22,
                                                  ),
                                                  hintText: "0.00",
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: width * 0.30,
                                          child: InkWell(
                                            onTap: () {
                                              showModalBottomSheet<void>(
                                                context: context,
                                                isScrollControlled: true,
                                                builder:
                                                    (BuildContext context) {
                                                  return StatefulBuilder(
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter setState) {
                                                      return Scaffold(
                                                        resizeToAvoidBottomInset:
                                                            false,
                                                        appBar:
                                                            hiddenAppBarWithDefaultHeight(),
                                                        body: selectFiatCoin(
                                                          context,
                                                          setState,
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      right: 10),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    radius: 14,
                                                    child: payments
                                                            .selectedOnrampFiatCurrency
                                                            .isNotEmpty
                                                        ? Image.memory(
                                                            base64Decode(
                                                              payments
                                                                  .onRamperDetails[
                                                                      'icons'][
                                                                      payments.selectedOnrampFiatCurrency[
                                                                          'code']]
                                                                      ['icon']
                                                                  .split(',')[1]
                                                                  .replaceAll(
                                                                      "\n", ""),
                                                            ),
                                                          )
                                                        : Container(),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      right: 10),
                                                  child: payments
                                                          .selectedOnrampFiatCurrency
                                                          .isNotEmpty
                                                      ? Text(
                                                          '${payments.selectedOnrampFiatCurrency['code'].toUpperCase()}',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        )
                                                      : Container(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'To',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                            payments.estimateLoader
                                                ? SizedBox(
                                                    child:
                                                        CircularProgressIndicator
                                                            .adaptive(
                                                                strokeWidth: 2),
                                                    height: 25,
                                                    width: 25,
                                                  )
                                                : Text(
                                                    '${payments.estimateOnrampRate.isNotEmpty ? double.parse('${payments.estimateOnrampRate['receivedCrypto']}').toStringAsFixed(4) : 0.00}',
                                                    style:
                                                        TextStyle(fontSize: 22),
                                                  ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: width * 0.30,
                                          child: InkWell(
                                            onTap: () {
                                              showModalBottomSheet<void>(
                                                context: context,
                                                isScrollControlled: true,
                                                builder:
                                                    (BuildContext context) {
                                                  return StatefulBuilder(
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter setState) {
                                                      return Scaffold(
                                                        resizeToAvoidBottomInset:
                                                            false,
                                                        appBar:
                                                            hiddenAppBarWithDefaultHeight(),
                                                        body: selectCryptoCoin(
                                                          context,
                                                          setState,
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    right: 10,
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 14,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    child: payments
                                                            .selectedOnrampCryptoCurrency
                                                            .isNotEmpty
                                                        ? Image.memory(
                                                            base64Decode(
                                                              payments
                                                                  .onRamperDetails[
                                                                      'icons'][
                                                                      payments.selectedOnrampCryptoCurrency[
                                                                          'code']]
                                                                      ['icon']
                                                                  .split(',')[1]
                                                                  .replaceAll(
                                                                      "\n", ""),
                                                            ),
                                                          )
                                                        : Container(),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    right: 10,
                                                  ),
                                                  child: payments
                                                          .selectedOnrampCryptoCurrency
                                                          .isNotEmpty
                                                      ? Text(
                                                          '${payments.selectedOnrampCryptoCurrency['code'].toUpperCase()}',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        )
                                                      : Container(),
                                                ),
                                              ],
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
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Estimated rate',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  payments.estimateOnrampRate.isEmpty
                                      ? Container()
                                      : Text(
                                          '${_fiatOnrampController.text} ${payments.selectedCryptoCurrency['current_ticker'].toUpperCase()} ~ ${(double.parse('${payments.estimateOnrampRate['receivedCrypto']}')).toStringAsFixed(4)} ${payments.selectedOnrampCryptoCurrency['code'].toUpperCase()}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
              _providerType == 'onramper'
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {});
                              showModalBottomSheet(
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      topRight: Radius.circular(5)),
                                ),
                                context: context,
                                builder: (context) {
                                  return OnRampServiceProvider(
                                      payments.onrampGateways);
                                },
                              );
                            },
                            child: Card(
                              child: Container(
                                width: width,
                                padding: EdgeInsets.all(height * 0.02),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    style: BorderStyle.solid,
                                    width: 0.1,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      payments.onRampIdentifier.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: linkColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * .02,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {});
                              showModalBottomSheet(
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      topRight: Radius.circular(5)),
                                ),
                                context: context,
                                builder: (context) {
                                  return PayementMethod(
                                      payments.paymentMethods);
                                },
                              );
                            },
                            child: Card(
                              child: Container(
                                width: width,
                                padding: EdgeInsets.all(height * 0.02),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    style: BorderStyle.solid,
                                    width: 0.1,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      payments.selectedpaymentmethod.toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: linkColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              InkWell(
                onTap: _loadingCoins
                    ? null
                    : () {
                        if (_providerType == 'guardarian') {
                          processBuy();
                        } else {
                          if (_fiatOnrampController.text.isNotEmpty) {
                            if (double.parse(_fiatOnrampController.text) > 50) {
                              processOnrampOrder();
                            } else {
                              snackAlert(context, SnackTypes.errors,
                                  'Price is lower then required amount');
                            }
                          }
                        }
                      },
                child: Container(
                  width: width,
                  padding: EdgeInsets.only(
                    top: 10,
                    right: 10,
                    left: 10,
                    bottom: 30,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // color: Color(0xff5E6292),
                      color: (_loadingCoins || payments.estimateLoader)
                          ? Color(0xff292C51)
                          : Color(0xff5E6292),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        // style: BorderStyle.solid,
                        width: 0,
                        // color: Color(0xff5E6292),
                        color: _loadingCoins
                            ? Colors.transparent
                            : Color(0xff5E6292),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: (_loadingCoins || payments.estimateLoader)
                          ? SizedBox(
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                              height: 25,
                              width: 25,
                            )
                          : InkWell(
                              child: Text(
                                'Buy',
                                style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      (_loadingCoins || payments.estimateLoader)
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
        ),
      ),
    );
  }

  Widget onrampFormSheet(context, setState, formDetails) {
    var formDatas = formDetails['data'] ?? formDetails['extraData'];

    return Scaffold(
      appBar: hiddenAppBar(),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${formDetails['eventLabel'] ?? 'Process payment'}',
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
              ),
              Divider(),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: formDatas.isNotEmpty
                            ? formDatas.map<Widget>((formData) {
                                setState(() {
                                  _textControllers[formData['name']] =
                                      TextEditingController();
                                  if (formData['name'] ==
                                      'cryptocurrencyAddress') {
                                    _textControllers[formData['name']]!.text =
                                        _currentOnrampAddress;
                                  }
                                });

                                return Container(
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      style: BorderStyle.solid,
                                      width: 0.3,
                                      color: Color(0xff5E6292),
                                    ),
                                  ),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter ${formData['humanName']}';
                                      }
                                      return null;
                                    },
                                    keyboardType: formData['name'] == 'email'
                                        ? TextInputType.emailAddress
                                        : TextInputType.text,
                                    controller:
                                        _textControllers[formData['name']],
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
                                          'Enter ${formData['humanName'] ?? formData['name']}',
                                    ),
                                  ),
                                );
                              }).toList()
                            : [],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: LyoButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            print('process');
                          
                            processOnrampBuy(formDetails);
                          } else {
                            print('notvalidating');
                          }
                        },
                        text: 'Continue',
                        active: true,
                        isLoading: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget selectFiatCoin(context, setState) {
    return (_providerType == 'onramper')
        ? OnramperFiatCoins()
        : FiatCoinDrawer(
            fiatController: _fiatController,
          );
  }

  Widget selectCryptoCoin(context, setState) {
    return (_providerType == 'onramper')
        ? OnramperCryptoCoins(
            changeOnrampCrpto: changeOnrampCrpto,
          )
        : CryptoCoinDrawer(
            fiatController: _fiatController,
            getDigitalBalance: getDigitalBalance,
          );
  }
}
