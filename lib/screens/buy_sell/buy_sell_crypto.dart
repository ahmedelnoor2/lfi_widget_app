import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/buy_sell/common/crypto_coin_drawer.dart';
import 'package:lyotrade/screens/buy_sell/common/fiat_coin_drawer.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_svg/flutter_svg.dart';

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

  bool _loadingCoins = false;
  String _defaultNetwork = '';
  String _currentAddress = '';

  @override
  void initState() {
    getCurrencies();
    super.initState();
  }

  @override
  void dispose() async {
    _fiatController.dispose();
    _cryptoController.dispose();
    super.dispose();
  }

  // void _launchUrl(_url) async {
  //   final Uri url = Uri.parse(_url);
  //   if (!await launchUrl(url)) throw 'Could not launch $url';
  // }

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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      style: const TextStyle(fontSize: 22),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.zero,
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
                                      builder: (BuildContext context) {
                                        return StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter setState) {
                                            return Scaffold(
                                              resizeToAvoidBottomInset: false,
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
                                        padding: EdgeInsets.only(right: 10),
                                        child: CircleAvatar(
                                          radius: 14,
                                          child: payments.selectedFiatCurrency
                                                  .isNotEmpty
                                              ? SvgPicture.network(
                                                  '$changeNowApi${payments.selectedFiatCurrency['icon']['url']}',
                                                  width: 50,
                                                )
                                              : Container(),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(right: 10),
                                        child: payments
                                                .selectedFiatCurrency.isNotEmpty
                                            ? Text(
                                                '${payments.selectedFiatCurrency['ticker'].toUpperCase()}',
                                                style: TextStyle(fontSize: 16),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          child: CircularProgressIndicator
                                              .adaptive(strokeWidth: 2),
                                          height: 25,
                                          width: 25,
                                        )
                                      : Text(
                                          '${payments.estimateRate.isNotEmpty ? double.parse(payments.estimateRate['value']).toStringAsFixed(4) : 0.00}',
                                          style: TextStyle(fontSize: 22),
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
                                      builder: (BuildContext context) {
                                        return StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter setState) {
                                            return Scaffold(
                                              resizeToAvoidBottomInset: false,
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
                                        padding: EdgeInsets.only(right: 10),
                                        child: CircleAvatar(
                                          radius: 14,
                                          child: payments.selectedCryptoCurrency
                                                  .isNotEmpty
                                              ? SvgPicture.network(
                                                  '$changeNowApi${payments.selectedCryptoCurrency['icon']['url']}',
                                                  width: 50,
                                                )
                                              : Container(),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(right: 10),
                                        child: payments.selectedCryptoCurrency
                                                .isNotEmpty
                                            ? Text(
                                                '${payments.selectedCryptoCurrency['current_ticker'].toUpperCase()}',
                                                style: TextStyle(fontSize: 16),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                '1 ${payments.selectedCryptoCurrency['current_ticker'].toUpperCase()} ~ ${(double.parse(_fiatController.text) / double.parse(payments.estimateRate['value'])).toStringAsFixed(4)} ${payments.selectedFiatCurrency['ticker'].toUpperCase()}'),
                      ],
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _loadingCoins
                    ? null
                    : () {
                        processBuy();
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
                                  strokeWidth: 2),
                              height: 25,
                              width: 25,
                            )
                          : Text(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget selectFiatCoin(context, setState) {
    return FiatCoinDrawer(
      fiatController: _fiatController,
    );
  }

  Widget selectCryptoCoin(context, setState) {
    return CryptoCoinDrawer(
      fiatController: _fiatController,
      getDigitalBalance: getDigitalBalance,
    );
  }
}
