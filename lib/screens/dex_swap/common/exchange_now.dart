import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/dex_provider.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

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
  String _defaultNetwork = 'TRC20';
  String _defaultCoin = 'USDT';
  List _allNetworks = [];

  @override
  void initState() {
    // setState(() {
    //   _fromAmountController.text = '1';
    // });
    getCoinAddress(_defaultCoin);
    super.initState();
  }

  @override
  void dispose() async {
    _fromAmountController.dispose();
    _toAddressController.dispose();
    super.dispose();
  }

  Future<void> getCoinAddress(netwrkType) async {
    var dexProvider = Provider.of<DexProvider>(context, listen: false);
    print(dexProvider.fromActiveCurrency);
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
    await asset.getChangeAddress(context, auth, _defaultNetwork);

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

  Future<void> changeCoinType(netwrk) async {
    print(netwrk);
    setState(() {
      _loadingAddress = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    setState(() {
      _defaultNetwork = netwrk['mainChainName'];
    });
    await asset.getChangeAddress(context, auth, netwrk['showName']);
    setState(() {
      _loadingAddress = false;
    });
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
    var dexProvider = Provider.of<DexProvider>(context, listen: false);
    HapticFeedback.selectionClick();
    dexProvider.swapFromAndTo();
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
  }

  @override
  Widget build(BuildContext context) {
    var dexProvider = Provider.of<DexProvider>(context, listen: true);

    return dexProvider.processPayment.isNotEmpty
        ? sendingWidget(context, dexProvider)
        : Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 20),
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
                                      'from',
                                      dexProvider,
                                      setState,
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
                                child: dexProvider.fromActiveCurrency.isNotEmpty
                                    ? SvgPicture.network(
                                        '${dexProvider.fromActiveCurrency['image']}',
                                        width: 35,
                                      )
                                    : Container(),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Text(
                                          dexProvider
                                                  .fromActiveCurrency.isNotEmpty
                                              ? dexProvider
                                                  .fromActiveCurrency['ticker']
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
                                    dexProvider.fromActiveCurrency.isNotEmpty
                                        ? dexProvider.fromActiveCurrency['name']
                                        : '--',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: width * 0.4,
                          child: TextFormField(
                            textAlign: TextAlign.end,
                            controller: _fromAmountController,
                            onChanged: (value) async {
                              if (value.isNotEmpty) {
                                if (double.parse(value) > 0) {
                                  estimateRates();
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
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Min amount required: ${_loadingExchnageRate ? '--' : dexProvider.minimumValue['minAmount']} ${dexProvider.fromActiveCurrency.isNotEmpty ? dexProvider.fromActiveCurrency['ticker'].toUpperCase() : '--'}',
                    style: TextStyle(color: warningColor),
                  ),
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
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return selectCoins(
                              context,
                              'to',
                              dexProvider,
                              setState,
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
                              child: dexProvider.toActiveCurrency.isNotEmpty
                                  ? SvgPicture.network(
                                      '${dexProvider.toActiveCurrency['image']}',
                                      width: 35,
                                    )
                                  : Container(),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text(
                                        dexProvider.toActiveCurrency.isNotEmpty
                                            ? dexProvider
                                                .toActiveCurrency['ticker']
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
                                      ? dexProvider.toActiveCurrency['name']
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
                              ? getEstimateNumber(
                                  dexProvider.estimateValue['estimatedAmount'])
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
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                      Row(
                        children: [
                          Text(
                            '1 ${dexProvider.fromActiveCurrency.isNotEmpty ? dexProvider.fromActiveCurrency['ticker'].toUpperCase() : '--'} ~ ${dexProvider.estimateValue.isNotEmpty ? getEstimateNumber(dexProvider.estimateValue['estimatedAmount']) : '--'} ${dexProvider.toActiveCurrency.isNotEmpty ? dexProvider.toActiveCurrency['ticker'].toUpperCase() : '--'}',
                            style: TextStyle(color: linkColor),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: (_loadingExchnageRate ||
                          _fromAmountController.text.isEmpty)
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
                      bottom: 30,
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
              ],
            ),
          );
  }

  Widget selectCoins(context, type, dexProvider, setState) {
    var allCurrencies = dexProvider.allCurrencies;

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
                  return (currency['ticker'] ==
                              dexProvider.fromActiveCurrency['ticker'] ||
                          currency['ticker'] ==
                              dexProvider.toActiveCurrency['ticker'])
                      ? Container()
                      : ListTile(
                          onTap: () {
                            if (type == 'from') {
                              dexProvider.setFromActiveCurrency(currency);
                              estimateRates();
                            } else {
                              dexProvider.setToActiveCurrency(currency);
                            }
                            Navigator.pop(context);
                          },
                          leading: CircleAvatar(
                            radius: 12,
                            child: SvgPicture.network(
                              '${currency['image']}',
                              width: 50,
                              placeholderBuilder: (BuildContext context) =>
                                  const CircularProgressIndicator.adaptive(),
                            ),
                          ),
                          title: Text('${currency['ticker'].toUpperCase()}'),
                        );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget swapCoins(context, setState) {
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
              // Container(
              //   padding: EdgeInsets.only(bottom: 10),
              //   height: 45,
              //   child: ListView.builder(
              //       scrollDirection: Axis.horizontal,
              //       itemCount: _allNetworks.length,
              //       itemBuilder: (BuildContext context, int index) {
              //         var network = _allNetworks[index];
              //         return GestureDetector(
              //           onTap: () {
              //             setState(() {
              //               _defaultNetwork = network['mainChainName'];
              //             });
              //             changeCoinType(network);
              //           },
              //           child: Container(
              //             padding: EdgeInsets.only(right: 10),
              //             child: Container(
              //               decoration: BoxDecoration(
              //                 color:
              //                     (network['mainChainName'] == _defaultNetwork)
              //                         ? Color(0xff01FEF5)
              //                         : Color(0xff5E6292),
              //                 borderRadius: BorderRadius.circular(5),
              //               ),
              //               child: Container(
              //                 width: 62,
              //                 child: Align(
              //                   alignment: Alignment.center,
              //                   child: Text(
              //                     "${network['mainChainName']}",
              //                     style: TextStyle(
              //                       color: Colors.black,
              //                       fontWeight: FontWeight.w600,
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //         );
              //       }),
              // ),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
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
                                ClipboardData? data = await Clipboard.getData(
                                    Clipboard.kTextPlain);
                                _toAddressController.text = '${data!.text}';
                                dexProvider.validateAddress(context, auth, {
                                  'currency':
                                      dexProvider.toActiveCurrency['ticker'],
                                  'address': data.text,
                                });
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              dexProvider.verifyAddress.isNotEmpty
                  ? !dexProvider.verifyAddress['result']
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${dexProvider.verifyAddress['message']}',
                            style: TextStyle(color: errorColor),
                          ),
                        )
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
                      onChanged: (bool? value) {
                        setState(() {
                          _acceptTermsAndConditions = value!;
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'Sending',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('Waiting'),
          ),
          Row(
            children: [
              dexProvider.fromActiveCurrency.isNotEmpty
                  ? SvgPicture.network(
                      '${dexProvider.fromActiveCurrency['image']}',
                      width: 35,
                    )
                  : Container(),
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
          ),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Text('Address'),
          ),
          Container(
            padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                width: 0.3,
                color: Color(0xff5E6292),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: width * 0.8,
                  child: Text(
                    '${dexProvider.processPayment['payinAddress']}',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: dexProvider.processPayment['payinAddress'],
                      ),
                    );
                    snackAlert(context, SnackTypes.success, 'Copied');
                  },
                  child: Image.asset(
                    'assets/img/copy.png',
                    width: 18,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 150,
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.only(top: 2, bottom: 2, right: 2, left: 2),
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
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Icon(
                Icons.keyboard_double_arrow_down,
                size: 30,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('Receive'),
          ),
          Row(
            children: [
              dexProvider.toActiveCurrency.isNotEmpty
                  ? SvgPicture.network(
                      '${dexProvider.toActiveCurrency['image']}',
                      width: 35,
                    )
                  : Container(),
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  '${dexProvider.processPayment['amount']} ${dexProvider.toActiveCurrency['ticker']}'
                      .toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Text('Address'),
          ),
          Container(
            padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                width: 0.3,
                color: Color(0xff5E6292),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: width * 0.8,
                  child: Text(
                    '${dexProvider.processPayment['payoutAddress']}',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: dexProvider.processPayment['payoutAddress'],
                      ),
                    );
                    snackAlert(context, SnackTypes.success, 'Copied');
                  },
                  child: Image.asset(
                    'assets/img/copy.png',
                    width: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
