import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lyotrade/providers/loan_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class TakeLoan extends StatefulWidget {
  static const routeName = '/crypto_loan';

  const TakeLoan({Key? key}) : super(key: key);

  @override
  State<TakeLoan> createState() => _TakeLoanState();
}

class _TakeLoanState extends State<TakeLoan> {
  var _selected;
  var _currselected;
  final List<Map> _myJson = [
    {"id": '1', "image": "assets/img/currency.png", "name": "Lyo"},
    {"id": '2', "image": "assets/img/currency.png", "name": "USD"},
  ];

  final List<Map> _myJsonlist = [
    {"id": '1', "detail": "Unlimited", "name": "Long Term"},
    {"id": '2', "detail": "140.01 USDT", "name": "Monthly Interest"},
    {"id": '3', "detail": "11627.56 BTC/USDT", "name": "Liquidation Price"},
  ];
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
    await loanProvider.getloanestimate();
  }

  @override
  Widget build(BuildContext context) {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);
    print(loanProvider.getloanestimate());
    return Scaffold(
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
                      padding: EdgeInsets.only(right: 20),
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
                  onPressed: () {},
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
                  Center(
                      child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: FutureBuilder(
                              future: getCurrencies(),
                              builder: (context, snapshot) {
                                return DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    dropdownColor: buttoncolour,
                                    alignment: Alignment.centerRight,
                                    isDense: true,
                                    hint: new Text("Select ",
                                        style:
                                            TextStyle(color: textFieldBGColor)),
                                    value: _currselected,
                                    onChanged: loanProvider.issenderenable
                                        ? (String? newValue) {
                                            setState(() {
                                              _currselected = newValue!;
                                            });
                                          }
                                        : null,
                                    items:
                                        loanProvider.sendercurrences.map((map) {
                                      return new DropdownMenuItem<String>(
                                        value: map["network"],
                                        child: Container(
                                          // margin: EdgeInsets.only(left: 200),
                                          child: Row(
                                            children: <Widget>[
                                              Image.asset(
                                                'assets/img/currency.png',
                                                width: 25,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                child: Text(map["network"],
                                                    style: TextStyle(
                                                        color: whiteTextColor)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ));
                              }),
                        ),
                      ],
                    ),
                  )),
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
                  Center(
                      child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: FutureBuilder(
                              future: getCurrencies(),
                              builder: (context, snapshot) {
                                return DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    dropdownColor: buttoncolour,
                                    alignment: Alignment.centerRight,
                                    isDense: true,
                                    hint: new Text("Select ",
                                        style:
                                            TextStyle(color: textFieldBGColor)),
                                    value: _selected,
                                    onChanged: loanProvider.isreciverenable
                                        ? (String? newValue) {
                                            setState(() {
                                              _selected = newValue!;
                                            });

                                            // print(_selected);
                                          }
                                        : null,
                                    items: loanProvider.recivercurrencies
                                        .map((map) {
                                      return new DropdownMenuItem<String>(
                                        value: map["network"],
                                        child: Container(
                                          // margin: EdgeInsets.only(left: 200),
                                          child: Row(
                                            children: <Widget>[
                                              Image.asset(
                                                'assets/img/currency.png',
                                                width: 25,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                child: Text(map["network"],
                                                    style: TextStyle(
                                                        color: whiteTextColor)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ));
                              }),
                        ),
                      ],
                    ),
                  )),
                  SizedBox(
                    height: 10,
                  ),
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
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: FutureBuilder(
                  future: loanProvider.getloanestimate(),
                  builder: (context, snapshot) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              loanProvider.loanestimate['interest_amounts']
                                          ['month'] ?? '',
                                     
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              loanProvider.loanestimate['down_limit'] ?? '',
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
                  }),
            ),
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
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
