import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/loan_provider.dart';
import 'package:lyotrade/providers/public.dart';
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
  final TextEditingController _textEditingControllerhistory =
      TextEditingController();

  List<dynamic> percentageList = [0.5, 0.7, 0.8];

  int _itemPosition = 0;
  @override
  void initState() {
    getCurrencies();
    getloanestimate();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingControllesender.dispose();
    _textEditingControllereciver.dispose();
    _textEditingControllerhistory.dispose();
  }

  Future<void> getUserAddress(coin, network) async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);

    if (public.publicInfoMarket.isNotEmpty) {
      public.publicInfoMarket['market']['followCoinList'][coin]
          .forEach((key, value) async {
        if (value['tokenBase'] == network) {
          await asset.getChangeAddress(context, auth, key);
        }
      });
    }
    await asset.getChangeAddress(context, auth, coin);
  }

  Future<void> getCurrencies() async {
    var public = Provider.of<Public>(context, listen: false);
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);
    await loanProvider.getCurrencies(public);
    getUserAddress(loanProvider.toSelectedCurrency['code'],
        loanProvider.toSelectedCurrency['network']);
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
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var loanProvider = Provider.of<LoanProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: hiddenAppBar(),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return checkLoanHistory(context, setState);
                              },
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.history),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Consumer<LoanProvider>(
                        builder: (_, provider, __) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Text(
                                  'Your Collateral',
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    style: BorderStyle.solid,
                                    width: 0.3,
                                    color: Color(0xff5E6292),
                                  ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<dynamic>(
                                          icon: Container(),
                                          isDense: true,
                                          dropdownColor: buttoncolour,
                                          alignment: Alignment.centerLeft,
                                          value:
                                              provider.selectedFromCurrencyCoin,
                                          onChanged: (newValue) {
                                            setState(() {
                                              provider
                                                  .setSelectedFromCurrencyCoin(
                                                      newValue);
                                              provider.setFromSelectedCurrency(
                                                  provider.fromCurrencies[
                                                      newValue]);

                                              provider.from_code = provider
                                                  .fromSelectedCurrency['code'];
                                              provider.from_network =
                                                  provider.fromSelectedCurrency[
                                                      'network'];

                                              provider.getloanestimate();
                                            });
                                          },
                                          items:
                                              provider.fromCurrenciesList.map(
                                            (value) {
                                              return DropdownMenuItem<dynamic>(
                                                value: value,
                                                child: Row(
                                                  children: [
                                                    SvgPicture.network(
                                                      provider.fromCurrencies[
                                                          value]["logo_url"],
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: Text(
                                                          provider.fromCurrencies[
                                                              value]["code"],
                                                          style: TextStyle(
                                                              color:
                                                                  whiteTextColor)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ).toList(),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
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
                                            setState(() {
                                              _textEditingControllereciver
                                                  .clear();
                                            });
                                          }
                                        },
                                        controller: _textEditingControllesender,
                                        textAlign: TextAlign.right,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          hintStyle: TextStyle(
                                            fontSize: 18,
                                          ),
                                          hintText: "0.000",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 20, bottom: 5),
                                child: Text(
                                  'Your Loan',
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    style: BorderStyle.solid,
                                    width: 0.3,
                                    color: Color(0xff5E6292),
                                  ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<dynamic>(
                                          icon: Container(),
                                          isDense: true,
                                          dropdownColor: buttoncolour,
                                          alignment: Alignment.centerLeft,
                                          value:
                                              provider.selectedToCurrencyCoin,
                                          onChanged: (newValue) {
                                            setState(() {
                                              provider
                                                  .setSelectedToCurrencyCoin(
                                                      newValue);
                                              provider.setToSelectedCurrency(
                                                  provider
                                                      .toCurrencies[newValue]);
                                              getUserAddress(
                                                provider
                                                    .toSelectedCurrency['code'],
                                                provider.toSelectedCurrency[
                                                    'network'],
                                              );
                                              provider.to_code = provider
                                                  .toSelectedCurrency['code'];
                                              provider.to_network =
                                                  provider.toSelectedCurrency[
                                                      'network'];

                                              provider.getloanestimate();
                                            });
                                          },
                                          items: provider.toCurrenciesList.map(
                                            (value) {
                                              return DropdownMenuItem<dynamic>(
                                                value: value,
                                                child: Row(
                                                  children: [
                                                    SvgPicture.network(
                                                      provider.toCurrencies[
                                                          value]["logo_url"],
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: Text(value,
                                                          style: TextStyle(
                                                              color:
                                                                  whiteTextColor)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ).toList(),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        onChanged: (value) {
                                          // if (value.isNotEmpty) {
                                          //   var reverse = 'reverse';
                                          //   provider.exchange = reverse;
                                          //   provider.amount = value;
                                          //   provider
                                          //       .getloanestimate()
                                          //       .whenComplete(() {
                                          //     setState(() {
                                          //       _textEditingControllesender
                                          //               .text =
                                          //           loanProvider.senderamount;
                                          //     });
                                          //   });
                                          // } else {
                                          //   setState(() {
                                          //     _textEditingControllesender
                                          //         .clear();
                                          //   });
                                          // }
                                        },
                                        keyboardType: TextInputType.number,
                                        controller:
                                            _textEditingControllereciver,
                                        textAlign: TextAlign.right,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          hintStyle: TextStyle(
                                            fontSize: 18,
                                          ),
                                          hintText: "0.000",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Text(
                                'LTV: ',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            SizedBox(
                              height: 35,
                              width: width * 0.65,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: percentageList.length,
                                itemBuilder: (context, i) {
                                  return Container(
                                    padding: const EdgeInsets.only(
                                      right: 8,
                                      top: 5,
                                      bottom: 5,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _itemPosition = i;
                                          loanProvider.ltv_percent =
                                              percentageList[i];
                                          loanProvider
                                              .getloanestimate()
                                              .whenComplete(() {
                                            setState(() {
                                              _textEditingControllereciver
                                                      .text =
                                                  loanProvider.reciveramount;
                                            });
                                          });
                                        });
                                      },
                                      child: Container(
                                        width: 70,
                                        height: 22,
                                        decoration: BoxDecoration(
                                            color: selectboxcolour,
                                            border: Border.all(
                                                color: _itemPosition == i
                                                    ? selecteditembordercolour
                                                    : Colors.transparent)),
                                        child: Center(
                                          child: Text(
                                            '${(double.parse('${percentageList[i]}') * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              color: _itemPosition == i
                                                  ? selecteditembordercolour
                                                  : whiteTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
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
                                Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Loan Term',
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                      Text('Unlimited'),
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
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                      Text(
                                        '${double.parse('${provider.loanestimate['interest_amounts']['month']}').toStringAsFixed(2)} ${provider.toSelectedCurrency['code']}',
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
                                        'Liquidation Price',
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                      Text(
                                        '${double.parse('${provider.loanestimate['down_limit']}').toStringAsFixed(2)} ${provider.toSelectedCurrency['code']}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(bottom: 20),
              child: LyoButton(
                onPressed: () {
                  formValidation();
                },
                text: 'Get Loan',
                active: true,
                isLoading: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget checkLoanHistory(context, setState) {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);

    return Container(
      padding: EdgeInsets.all(10),
      height: height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Get history on your email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
              )
            ],
          ),
          Divider(),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 5),
                child: Text('Enter your Email:'),
              ),
              Container(
                  child: TextField(
                controller: _textEditingControllerhistory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'example@domain.com',
                ),
                onChanged: (text) {
                  setState(() {
                    //  fullName = text;
                    //you can access nameController in its scope to get
                    // the value of text entered as shown below
                    //fullName = nameController.text;
                  });
                },
              )),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            child: LyoButton(
              onPressed: () {
                if (_textEditingControllerhistory.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "Please insert email",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else {
                  loanProvider
                      .getLoanHistory(_textEditingControllerhistory.text.trim())
                      .whenComplete(() =>
                          loanProvider.myloanhistory['status'] == 200
                              ? Fluttertoast.showToast(
                                  msg: "Check your Email",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: buttoncolour,
                                  textColor: Colors.white,
                                  fontSize: 16.0)
                              : null);

                  Navigator.of(context).pop();
                }
              },
              text: 'Submit',
              active: true,
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }
}
