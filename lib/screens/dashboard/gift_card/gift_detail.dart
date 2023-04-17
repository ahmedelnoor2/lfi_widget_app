import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/drawer.dart';

import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/dashboard/gift_card/buycard.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Coins.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class GiftDetail extends StatefulWidget {
  static const routeName = '/gift_detail';
  GiftDetail({Key? key, this.data, this.isEqualMinMax}) : super(key: key);
  final data;
  final isEqualMinMax;
  @override
  State<GiftDetail> createState() => _GiftDetailState();
}

class _GiftDetailState extends State<GiftDetail> {
  String _defaultCoin = 'USDTBSC';
  double _selectedPercentage = 0;
  List _allNetworks = [];
  String _defaultNetwork = 'BSC';
  String _coinShowName = 'USDT';

  double estprice = 0.0;
  int? _selectedAmount;

  final TextEditingController _searchController = TextEditingController();
  bool _tagType = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final _amountcontroller = TextEditingController();
  @override
  void initState() {
    super.initState();
    getDigitalBalance();
  }

  // Get Estimate Rate//
  Future<void> getEstimateRate(productID, payment, currency) async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];
    await giftcardprovider.getEstimateRate(context, auth, userid,
        {"currency": "$currency", "payment": payment, "productID": productID});
    return;
  }

  Future<void> getDigitalBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    if (widget.isEqualMinMax == false) {
      var cardrate = widget.data['price']['fixed']['max'].toString();
      var _payment = double.parse(cardrate);
      _amountcontroller.text = cardrate.toString();
      var userid = await auth.userInfo['id'];
      await giftcardprovider.getEstimateRate(context, auth, userid, {
        "currency": "${giftcardprovider.toActiveCountry['currency']['code']}",
        "payment": _payment,
        "productID": widget.data['BillerID']
      });
    } else if (widget.data['price_type'] == "list") {
      var cardrate = widget.data['price']['list'][0].toString();
      _selectedAmount = int.parse(cardrate);
      var _payment = double.parse(cardrate);
      var userid = await auth.userInfo['id'];

      await giftcardprovider.getEstimateRate(context, auth, userid, {
        "currency": "${giftcardprovider.toActiveCountry['currency']['code']}",
        "payment": _payment,
        "productID": widget.data['BillerID']
      });
    }

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

    // await asset.getChangeAddress(context, auth, _defaultCoin);

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

  @override
  void dispose() {
    // TODO: implement dispose
    _amountcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);
    var public = Provider.of<Public>(context, listen: true);
    print(widget.data);
//print(giftcardprovider.toActiveCountry);
    return Scaffold(
      key: _scaffoldKey,
      drawer: drawer(
        context,
        width,
        height,
        asset,
        public,
        _searchController,
        getCoinCosts,
        giftcardprovider.allwallet,
      ),
      appBar: hiddenAppBar(),
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/giftbg.png"),
                fit: BoxFit.cover,
              ),
            ),
            height: height * 0.20,
            child: Column(
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
                          'Gift Detail',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  child: Column(
                    children: [
                      Text(
                        widget.data['name'] ?? '',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text('Receive a reward of up to x times your entry fee!'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.topCenter,
            fit: StackFit.loose,
            children: <Widget>[
              Container(
                height: height * 0.75,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color(0xff25284A),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            child: Row(children: [
                              Text(
                                'Buy',
                              ),
                            ]),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _scaffoldKey.currentState!.openDrawer();
                            setState(() {
                              // estimateprice = 0.0;
                              // _amountcontroller.clear();
                            });
                          },
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

                        (widget.data['price_type'] == "list")
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 20),
                                    child: Container(
                                      child: Row(children: [
                                        Text(
                                          'Select Amount' +
                                              ' ' +
                                              '(${giftcardprovider.toActiveCountry['currency']['code']})',
                                        ),
                                      ]),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        style: BorderStyle.solid,
                                        width: 0.3,
                                        color: Color(0xff5E6292),
                                      ),
                                    ),
                                    child: DropdownButton<int>(
                                        isDense: true,
                                        value: _selectedAmount,
                                        icon: Container(
                                          padding: EdgeInsets.only(
                                              left: width * 0.191),
                                          child: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: const TextStyle(fontSize: 13),
                                        underline: Container(
                                          height: 0,
                                        ),
                                        onChanged: (int? newValue) {
                                          setState(() {
                                            _selectedAmount = newValue;
                                          });
                                          getEstimateRate(
                                              widget.data['BillerID'],
                                              _selectedAmount,
                                              giftcardprovider.toActiveCountry[
                                                  'currency']['code']);
                                        },
                                        items: widget.data['price']['list']
                                            .map<DropdownMenuItem<int>>(
                                                (value) {
                                          return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(
                                              value.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        }).toList()),
                                  ),
                                ],
                              )
                            : Container(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, bottom: 20),
                                      child: Container(
                                        child: Row(children: [
                                          Text(
                                            'Amount' +
                                                ' ' +
                                                '(${giftcardprovider.toActiveCountry['currency']['code']})',
                                          ),
                                        ]),
                                      ),
                                    ),
                                    Form(
                                      key: _formKey,
                                      child: TextFormField(
                                        controller: _amountcontroller,
                                        enabled: widget.isEqualMinMax,
                                        validator: (value) {
                                          if (widget.data['price_type'] ==
                                              "range") {
                                            var min = widget.data['price']
                                                ['range']['min'];

                                            var max = widget.data['price']
                                                ['range']['max'];

                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter Amount';
                                            } else if (double.parse(
                                                    value.toString()) <
                                                min) {
                                              return 'Minimum Amount:$min';
                                            } else if (double.parse(
                                                    value.toString()) >
                                                max) {
                                              return 'Max Amount:$max';
                                            } else if (double.parse(value) <
                                                asset.getCost['withdraw_min']) {
                                              return 'Minimum withdrawal amount is ${asset.getCost['withdraw_min']}';
                                            }
                                            return null;
                                          }
                                        },
                                        onChanged: ((value) async {
                                          if (value.isNotEmpty) {
                                            await getEstimateRate(
                                                widget.data['BillerID'],
                                                _amountcontroller.text,
                                                giftcardprovider
                                                        .toActiveCountry[
                                                    'currency']['code']);
                                          }
                                        }),
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 0.5,
                                                  color:
                                                      secondaryTextColor400), //<-- SEE HERE
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: secondaryTextColor400,
                                                  width: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            hintText: 'Amount',
                                            // errorText: _errorText,
                                            suffixText: giftcardprovider
                                                .toActiveCountry['currency']
                                                    ['code']
                                                .toString()),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Wallet Balance',
                                  style:
                                      TextStyle(color: secondaryTextColor400),
                                ),
                                Row(
                                  children: [
                                    Text(asset.accountBalance['allCoinMap'] ==
                                            null
                                        ? ''
                                        : asset.accountBalance['allCoinMap']
                                                [_coinShowName]['allBalance']
                                            .toString()),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(_coinShowName),
                                    )
                                  ],
                                )
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Estimated Rate',
                                  style:
                                      TextStyle(color: secondaryTextColor400),
                                ),
                                giftcardprovider.isEstimate
                                    ? CircularProgressIndicator()
                                    : Text(
                                        '${giftcardprovider.estimateRate['rate']}'
                                                ' ' +
                                            _coinShowName)
                              ]),
                        ),
                        priceType(widget.data),

                        ///price type widget //
                        LyoButton(
                          onPressed: (() async {
                            print(_selectedAmount);
                            if (widget.data['price_type'] == "list") {
                              Navigator.pushNamed(context, '/buy_card',
                                  arguments: BuyCard(
                                      amount: _selectedAmount.toString(),
                                      totalprice:
                                          giftcardprovider.estimateRate['rate'],
                                      defaultcoin: _defaultCoin,
                                      ShowName: _coinShowName,
                                      productID:
                                          widget.data['BillerID'].toString()));
                            } else if (_formKey.currentState!.validate()) {
                              print(giftcardprovider
                                  .estimateRate['rate'].runtimeType);
                              Navigator.pushNamed(context, '/buy_card',
                                  arguments: BuyCard(
                                      amount: _amountcontroller.text,
                                      totalprice:
                                          giftcardprovider.estimateRate['rate'],
                                      defaultcoin: _defaultCoin,
                                      ShowName: _coinShowName,
                                      productID:
                                          widget.data['BillerID'].toString()));
                            }
                          }),
                          text: 'Continue',
                          active: true,
                          isLoading: giftcardprovider.dotransactionloading,
                          activeColor: linkColor,
                          activeTextColor: Colors.black,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: -50,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          giftcardprovider.toActiveCatalog['card_image']
                              .toString(),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: 120,
                    width: 200,
                  ))
            ],
          )
        ],
      ),
    );
  }

  Widget priceType(Map data) {
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);

    if (data['price_type'] == "range") {
      return Container(
        padding: EdgeInsets.only(bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                'Min price: ${giftcardprovider.toActiveCountry['currency']['code'] != 'AED' ? data['price']['range']['min'] * giftcardprovider.toActiveCountry['rate']['rate'] : data['price']['range']['min']} ${giftcardprovider.toActiveCountry['currency']['code']}'),
            Text(
                'Max price: ${giftcardprovider.toActiveCountry['currency']['code'] != 'AED' ? data['price']['range']['max'] * giftcardprovider.toActiveCountry['rate']['rate'] : data['price']['range']['max']} ${giftcardprovider.toActiveCountry['currency']['code']}'),
          ],
        ),
      );
    } else if (data['price_type'] == "fixed") {
      return Container(
        padding: EdgeInsets.only(bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                'Min price: ${giftcardprovider.toActiveCountry['currency']['code'] != 'AED' ? data['price']['fixed']['min'] * giftcardprovider.toActiveCountry['rate']['rate'] : data['price']['fixed']['min']} ${giftcardprovider.toActiveCountry['currency']['code']}'),
            Text(
                'Max price: ${giftcardprovider.toActiveCountry['currency']['code'] != 'AED' ? data['price']['fixed']['max'] * giftcardprovider.toActiveCountry['rate']['rate'] : data['price']['fixed']['max']} ${giftcardprovider.toActiveCountry['currency']['code']}'),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
