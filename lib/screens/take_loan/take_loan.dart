import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lyotrade/providers/loan_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

import '../common/widget/error_dialog.dart';
import '../common/widget/loading_dialog.dart';

class TakeLoan extends StatefulWidget {
  static const routeName = '/crypto_loan';

  const TakeLoan({Key? key}) : super(key: key);

  @override
  State<TakeLoan> createState() => _TakeLoanState();
}

class _TakeLoanState extends State<TakeLoan> {
  final TextEditingController _textEditingControllesender =
      TextEditingController(text: '1');
  final TextEditingController _textEditingControllereciver =
      TextEditingController();

  // final List<Map> _myJson = [
  //   {"id": '1', "image": "assets/img/currency.png", "name": "Lyo"},
  //   {"id": '2', "image": "assets/img/currency.png", "name": "USD"},
  // ];

  // final List<Map> _myJsonlist = [
  //   {"id": '1', "detail": "Unlimited", "name": "Long Term"},
  //   {"id": '2', "detail": "140.01 USDT", "name": "Monthly Interest"},
  //   {"id": '3', "detail": "11627.56 BTC/USDT", "name": "Liquidation Price"},
  // ];
  List<dynamic> percentageList = [0.5, 0.7, 0.8];

  int _itemPosition = 0;
  @override
  void initState() {
    getCurrencies();

    super.initState();
  }

  Future<void> getCurrencies() async {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);
    await loanProvider.getCurrencies();
  }

  Future<void> getloanestimate() async {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);

    await loanProvider.getloanestimate();
  }

  formValidation() {
    if (_textEditingControllereciver.text.isEmpty &&
        _textEditingControllesender.text.isEmpty) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please write sender/reciver.",
            );
          });
    } else {
      loancreateNow();
    }
  }

  loancreateNow() async {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);
    showDialog(
        context: context,
        builder: (c) {
          return LoadingDialog(
            message: "Checking"
          );
        });

    await loanProvider.getCreateLoan().whenComplete(() {
      if (loanProvider.result == true) {
        loanProvider
            .getLoanStatus(loanProvider.loanid)
            .whenComplete(() {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/confirm_loan');
            });
            
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message: 'Some Thing went Wrong!',
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: hiddenAppBar(),
      body: Container(
        padding: EdgeInsets.all(10),
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
                      'Borrow Against Crypto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    print(loanProvider.yourloan);
                  },
                  icon: Icon(Icons.history),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: new Container(
                          child: new Text(
                            'Borrow Against Crypto',
                            overflow: TextOverflow.ellipsis,
                            style: new TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'Yantramanav',
                              color: whiteTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Consumer<LoanProvider>(builder: (_, provider, __) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: new Container(
                                child: new Text(
                                  'Your Collateral',
                                  overflow: TextOverflow.ellipsis,
                                  style: new TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Yantramanav',
                                    color: whiteTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                    child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _textEditingControllesender,
                                  onChanged: (s) {
                                    provider.amount = int.parse(s);
                                    print(provider.amount);
                                    provider.getloanestimate();
                                  },
                                  decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 15,
                                        bottom: 11,
                                        top: 11,
                                        right: 15),
                                  ),
                                )),
                                Expanded(
                                    child: DropdownButtonHideUnderline(
                                  child: DropdownButton<dynamic>(
                                    dropdownColor: buttoncolour,
                                    alignment: Alignment.centerRight,
                                    value: provider.selectedFromCurrencyCoin,
                                    onChanged: (newValue) {
                                      setState(() {
                                        provider.setSelectedFromCurrencyCoin(
                                            newValue);
                                        provider.setFromSelectedCurrency(
                                            provider.fromCurrencies[newValue]);

                                        provider.from_code = provider
                                            .fromSelectedCurrency['code'];
                                        provider.from_network = provider
                                            .fromSelectedCurrency['network'];
                                        print(provider.from_code);
                                        print(provider.to_code);
                                        provider.getloanestimate();
                                      });
                                    },
                                    items: provider.fromCurrenciesList
                                        .map((value) {
                                      return DropdownMenuItem<dynamic>(
                                        value: value,
                                        child: Container(
                                          // margin: EdgeInsets.only(left: 200),
                                          child: Row(
                                            children: [
                                              SvgPicture.network(
                                                  provider.fromCurrencies[value]
                                                      ["logo_url"]),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                child: Text(
                                                    provider.fromCurrencies[
                                                        value]["code"],
                                                    style: TextStyle(
                                                        color: whiteTextColor)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: new Container(
                                child: new Text(
                                  'Your Loan',
                                  overflow: TextOverflow.ellipsis,
                                  style: new TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Yantramanav',
                                    color: whiteTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                    child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  //controller: _textEditingControllereciver,
                                  onChanged: (s) {
                                    var reverse = 'reverse';
                                    provider.exchange = reverse;

                                    provider.amount = provider.yourloan.toInt();
                                    print(provider.amount);
                                    provider.getloanestimate();
                                  },
                                  initialValue:
                                      loanProvider.yourloan.toString(),
                                  decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 15,
                                        bottom: 11,
                                        top: 11,
                                        right: 15),
                                  ),
                                )),
                                Expanded(
                                    child: DropdownButtonHideUnderline(
                                  child: DropdownButton<dynamic>(
                                    dropdownColor: buttoncolour,
                                    alignment: Alignment.centerRight,
                                    value: provider.selectedToCurrencyCoin,
                                    onChanged: (newValue) {
                                      setState(() {
                                        provider.setSelectedToCurrencyCoin(
                                            newValue);
                                        provider.setToSelectedCurrency(
                                            provider.toCurrencies[newValue]);
                                        provider.to_code =
                                            provider.toSelectedCurrency['code'];
                                        provider.to_network = provider
                                            .toSelectedCurrency['network'];

                                        provider.getloanestimate();
                                      });
                                    },
                                    items:
                                        provider.toCurrenciesList.map((value) {
                                      return DropdownMenuItem<dynamic>(
                                        value: value,
                                        child: Container(
                                          // margin: EdgeInsets.only(left: 200),
                                          child: Row(
                                            children: [
                                              SvgPicture.network(
                                                  provider.toCurrencies[value]
                                                      ["logo_url"]),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                child: Text(value,
                                                    style: TextStyle(
                                                        color: whiteTextColor)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  }),
                  Row(
                    children: [
                      new Container(
                        child: new Text(
                          'LTV',
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Yantramanav',
                            color: whiteTextColor,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: 40,
                          width: 300,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: percentageList.length,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // when tapped.
                                      _itemPosition = i;
                                      loanProvider.ltv_percent =
                                          percentageList[i];
                                      loanProvider.getloanestimate();
                                    });
                                  },
                                  child: Container(
                                    width: 55,
                                    height: 22,
                                    decoration: BoxDecoration(
                                        color: selectboxcolour,
                                        border: Border.all(
                                            color: _itemPosition == i
                                                ? selecteditembordercolour
                                                : Colors.transparent)),
                                    child: Center(
                                        child: Text(
                                      percentageList[i].toString(),
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Yantramanav',
                                        color: _itemPosition == i
                                            ? selecteditembordercolour
                                            : whiteTextColor,
                                      ),
                                    )),
                                  ),
                                ),
                              );
                            },
                          ))
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 0.1,
            ),
            Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 8, bottom: 8),
                child: FutureBuilder(
                    future: loanProvider.getloanestimate(),
                    builder: (context, dataSnapshot) {
                      if (dataSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if (dataSnapshot.error != null) {
                          return Center(
                            child: Text('An error occured'),
                          );
                        } else {
                          return Consumer<LoanProvider>(
                              builder: (context, provider, __) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Loan Term',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Yantramanav',
                                        color: seconadarytextcolour,
                                      ),
                                    ),
                                    Text(
                                      'Unlimited',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Yantramanav',
                                        color: whiteTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Monthly Interest',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Yantramanav',
                                        color: seconadarytextcolour,
                                      ),
                                    ),
                                    Text(
                                      provider.loanestimate['interest_amounts']
                                              ['month']
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Yantramanav',
                                        color: whiteTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Liquidation Price',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Yantramanav',
                                        color: seconadarytextcolour,
                                      ),
                                    ),
                                    Text(
                                      provider.loanestimate['down_limit']
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Yantramanav',
                                        color: whiteTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          });
                        }
                      }
                    })),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: FlatButton(
                  child: Text(
                    'Get Loan',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Yantramanav',
                      color: whiteTextColor,
                    ),
                  ),
                  color: buttoncolour,
                  onPressed: () async {
                    formValidation();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
