import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lyotrade/providers/loan_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
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
      TextEditingController();
  final TextEditingController _textEditingControllereciver =
      TextEditingController();

  List<dynamic> percentageList = [0.5, 0.7, 0.8];

  int _itemPosition = 0;
  @override
  void initState() {
    getCurrencies();
    getloanestimate();
    super.initState();
  }

  Future<void> getCurrencies() async {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);
    await loanProvider.getCurrencies();
  }

  Future<void> getloanestimate() async {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);

    await loanProvider.getloanestimate().whenComplete(() {
      setState(() {
        _textEditingControllereciver.text = loanProvider.reciveramount;
        _textEditingControllesender.text = loanProvider.senderamount;
      });
    });
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
          return LoadingDialog(message: "Checking");
        });

    await loanProvider.getCreateLoan().whenComplete(() {
      if (loanProvider.result == true) {
        loanProvider.getLoanStatus(loanProvider.loanid).whenComplete(() {
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
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.chevron_left),
                        ),
                      ),
                      Text(
                        'Loans',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.only(left: 15),
                      child: Icon(Icons.history),
                    ),
                  )
                ],
              ),
            ),
            const Divider(),
            Container(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 20),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Borrow Against Crypto',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  Consumer<LoanProvider>(
                    builder: (_, provider, __) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: const Text('Your Collateral'),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                style: BorderStyle.solid,
                                width: 0.3,
                                color: const Color(0xff5E6292),
                              ),
                            ),
                            child: ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<dynamic>(
                                        icon: Container(),
                                        isExpanded: true,
                                        isDense: true,
                                        dropdownColor: buttoncolour,
                                        alignment: Alignment.centerRight,
                                        value:
                                            provider.selectedFromCurrencyCoin,
                                        onChanged: (newValue) {
                                          setState(() {
                                            provider
                                                .setSelectedFromCurrencyCoin(
                                                    newValue);
                                            provider.setFromSelectedCurrency(
                                                provider
                                                    .fromCurrencies[newValue]);

                                            provider.from_code = provider
                                                .fromSelectedCurrency['code'];
                                            provider.from_network =
                                                provider.fromSelectedCurrency[
                                                    'network'];
                                          });
                                          provider.getloanestimate();
                                        },
                                        items: provider.fromCurrenciesList
                                            .map((value) {
                                          return DropdownMenuItem<dynamic>(
                                            value: value,
                                            child: Row(
                                              children: [
                                                SvgPicture.network(provider
                                                        .fromCurrencies[value]
                                                    ["logo_url"]),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Text(
                                                    provider.fromCurrencies[
                                                        value]["code"],
                                                    style: TextStyle(
                                                        color: whiteTextColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter amount';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          var direct = 'direct';
                                          provider.exchange = direct;
                                          provider.amount = value;

                                          provider
                                              .getloanestimate()
                                              .whenComplete(() {
                                            setState(() {
                                              _textEditingControllereciver
                                                      .text =
                                                  loanProvider.reciveramount;
                                            });
                                          });
                                        } else {
                                          _textEditingControllereciver.clear();
                                        }
                                      },
                                      controller: _textEditingControllesender,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                        hintText: '0.0000',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 15, bottom: 5),
                            child: const Text('Your Loan'),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                style: BorderStyle.solid,
                                width: 0.3,
                                color: const Color(0xff5E6292),
                              ),
                            ),
                            child: ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<dynamic>(
                                        icon: Container(),
                                        isDense: true,
                                        isExpanded: true,
                                        dropdownColor: buttoncolour,
                                        alignment: Alignment.centerRight,
                                        value: provider.selectedToCurrencyCoin,
                                        onChanged: (newValue) async {
                                          setState(() {
                                            provider.setSelectedToCurrencyCoin(
                                                newValue);
                                            provider.setToSelectedCurrency(
                                                provider
                                                    .toCurrencies[newValue]);
                                            provider.to_code = provider
                                                .toSelectedCurrency['code'];
                                            provider.to_network = provider
                                                .toSelectedCurrency['network'];
                                          });
                                          await provider.getloanestimate();
                                        },
                                        items: provider.toCurrenciesList
                                            .map((value) {
                                          return DropdownMenuItem<dynamic>(
                                            value: value,
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(right: 5),
                                                  child: SvgPicture.network(
                                                    provider.toCurrencies[value]
                                                        ["logo_url"],
                                                  ),
                                                ),
                                                Text(
                                                  value,
                                                  style: TextStyle(
                                                      color: whiteTextColor),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter amount';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          var reverse = 'reverse';
                                          provider.exchange = reverse;
                                          provider.amount = value;
                                          provider
                                              .getloanestimate()
                                              .whenComplete(() {
                                            setState(() {
                                              _textEditingControllesender.text =
                                                  loanProvider.senderamount;
                                            });
                                          });
                                        } else {
                                          _textEditingControllesender.clear();
                                        }
                                      },
                                      controller: _textEditingControllereciver,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                        hintText: '0.0000',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 20),
                        child: const Text('LTV'),
                      ),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: percentageList.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 8,
                                right: 5,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // when tapped.
                                    _itemPosition = i;
                                    loanProvider.ltv_percent =
                                        percentageList[i];
                                    loanProvider
                                        .getloanestimate()
                                        .whenComplete(() {
                                      setState(() {
                                        _textEditingControllereciver.text =
                                            loanProvider.reciveramount;
                                      });
                                    });
                                  });
                                },
                                child: Container(
                                  width: 60,
                                  height: 22,
                                  decoration: BoxDecoration(
                                      color: selectboxcolour,
                                      border: Border.all(
                                          color: _itemPosition == i
                                              ? selecteditembordercolour
                                              : Colors.transparent)),
                                  child: Center(
                                      child: Text(
                                    '${(percentageList[i] * 100).toString()}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: _itemPosition == i
                                          ? linkColor
                                          : whiteTextColor,
                                    ),
                                  )),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            Container(
              height: height * 0.22,
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder(
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
                                Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Row(
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
                                ),
                                Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Monthly Interest',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: seconadarytextcolour,
                                        ),
                                      ),
                                      Text(
                                        '${double.parse('${provider.loanestimate['interest_amounts']['month']}').toStringAsFixed(2)} ${provider.toSelectedCurrency['code']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: whiteTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
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
                                      '${double.parse('${provider.loanestimate['down_limit']}').toStringAsFixed(2)} ${provider.fromSelectedCurrency['code']}/${provider.toSelectedCurrency['code']}',
                                      style: TextStyle(
                                        fontSize: 14,
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
                    },
                  ),
                  LyoButton(
                    onPressed: () {
                      formValidation();
                    },
                    text: 'Get Loan',
                    active: true,
                    activeColor: buttoncolour,
                    activeTextColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
