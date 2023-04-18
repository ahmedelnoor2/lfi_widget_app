import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/drawer.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/dashboard/gift_card/country_drawer.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class TopUp extends StatefulWidget {
  static const routeNmame = '/topup';
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
  int? _selectedAmount;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    getDigitalBalance();
  }

  Future<void> getDigitalBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    // if (widget.isEqualMinMax == false) {
    //   var cardrate = widget.data['price']['fixed']['max'].toString();
    //   var _payment = double.parse(cardrate);
    //   _amountcontroller.text = cardrate.toString();
    //   var userid = await auth.userInfo['id'];
    //   await giftcardprovider.getEstimateRate(context, auth, userid, {
    //     "currency": "${giftcardprovider.toActiveCountry['currency']['code']}",
    //     "payment": _payment,
    //     "productID": widget.data['BillerID']
    //   });
    // } else if (widget.data['price_type'] == "list") {
    //   var cardrate = widget.data['price']['list'][0].toString();
    //   _selectedAmount = int.parse(cardrate);
    //   var _payment = double.parse(cardrate);
    //   var userid = await auth.userInfo['id'];

    //   await giftcardprovider.getEstimateRate(context, auth, userid, {
    //     "currency": "${giftcardprovider.toActiveCountry['currency']['code']}",
    //     "payment": _payment,
    //     "productID": widget.data['BillerID']
    //   });
    // }

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
  Widget build(BuildContext context) {
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);
    var public = Provider.of<Public>(context, listen: true);
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CountryDrawer(),
      endDrawer: drawer(
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
                      //     Navigator.pushNamed(context, '/gift_transaction_detail');
                    },
                    icon: Icon(Icons.history),
                  ),
                ),
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                            width: width * 0.30,
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.image),
                                Text('+91'),
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
                                width: width * 0.60,
                                child: TextFormField(
                                  // The validator receives the text that the user has entered.
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
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
                  Container(
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
                        Text('Reloadly'),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Text('Top Up Amount')),
                  Container(
                    width: width,
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
                          padding: EdgeInsets.only(left: width * 0.191),
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
                        },
                        items: [
                          2,
                          10,
                          15,
                          20,
                          23,
                          45,
                          6,
                          43,
                          23,
                          1,
                          12,
                          324,
                        ].map<DropdownMenuItem<int>>((value) {
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
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated Rate',
                            style: TextStyle(color: secondaryTextColor400),
                          ),
                          giftcardprovider.isEstimate
                              ? CircularProgressIndicator()
                              : Text('${giftcardprovider.estimateRate['rate']}'
                                      ' ' +
                                  '_coinShowName')
                        ]),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _scaffoldKey.currentState!.openEndDrawer();
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
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
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
              height: height * 0.15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LyoButton(
                onPressed: () {},
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
