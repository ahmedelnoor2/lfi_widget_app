import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/future_market.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class FutureTradeForm extends StatefulWidget {
  const FutureTradeForm({
    Key? key,
    this.scaffoldKey,
    this.lastPrice,
  }) : super(key: key);
  final scaffoldKey;
  final lastPrice;

  @override
  State<FutureTradeForm> createState() => _FutureTradeFormState();
}

class _FutureTradeFormState extends State<FutureTradeForm> {
  final _formTradeKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _amountField = TextEditingController();
  final TextEditingController _priceField = TextEditingController();
  final TextEditingController _totalField = TextEditingController();

  var _timer;

  Color _tabIndicatorColor = greenIndicator;
  int _orderType = 1;
  double _amount = 0;
  double _price = 0;
  double _total = 0;
  String _availableBalance = '0.000000';
  bool _isBuy = true;
  bool _fromDigitalAccountToFutureAccount = true;
  String _defaultCoin = 'BTC';
  String _defaultTransferCoin = 'USDT';
  double _availableBalanceFrom = 0.00;
  double _availableBalanceTo = 0.00;

  @override
  void initState() {
    setAvailalbePrice();
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountField.dispose();
    _priceField.dispose();
    _totalField.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  Future<void> setAvailalbePrice() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);

    if (auth.isAuthenticated) {
      setState(() {
        _availableBalance = '${getFutureBalanceCoin(futureMarket)}';
      });
    }
  }

  Future<void> getAvailalbePrice() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);

    if (auth.isAuthenticated) {
      var asset = Provider.of<Asset>(context, listen: false);
      // getOpenPositions
      await futureMarket.getOpenPositions(context, auth);
      await asset.getAccountBalance(
        context,
        auth,
        "${futureMarket.activeMarket['symbol'].split('-')[0]},${futureMarket.activeMarket['symbol'].split('-')[1]}",
      );
      setAvailalbePrice();
    }
  }

  void updateLastPrice() {
    _priceField.text = widget.lastPrice;
    setState(() {
      _price = double.parse(widget.lastPrice);
    });
    calculateTotal('price');
  }

  void calculateTotal(field) {
    if (field == 'amount') {
      if (_amountField.text.isNotEmpty) {
        try {
          setState(() {
            _amount = double.parse(_amountField.text);
            _total = double.parse(_amountField.text) * _price;
          });
          _totalField.text = '${double.parse(_amountField.text) * _price}';
        } catch (e) {
          //
        }
      } else {
        _totalField.clear();
      }
    }
    if (field == 'price') {
      if (_priceField.text.isNotEmpty) {
        setState(() {
          _price = double.parse(_priceField.text);
          _total = double.parse(_priceField.text) * _amount;
        });
        _totalField.text = '${double.parse(_priceField.text) * _amount}';
      } else {
        setState(() {
          _price = 0.00;
        });
        _totalField.clear();
      }
    }
    if (field == 'total') {
      if (_totalField.text.isNotEmpty) {
        try {
          setState(() {
            _total = double.parse(_totalField.text);
            _amount = double.parse(_totalField.text) / _price;
          });
          _amountField.text = '${double.parse(_totalField.text) / _price}';
        } catch (e) {
          //
        }
      } else {
        _amountField.clear();
      }
    }
  }

  // Future<void> setPriceField() async {
  //   var futureMarket = Provider.of<FutureMarket>(context, listen: false);
  //   _priceField.text = futureMarket.amountField;
  //   _timer = Timer(Duration(milliseconds: 400), () async {
  //     await futureMarket.amountFieldDisable();
  //   });
  //   calculateTotal('price');
  // }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var futureMarket = Provider.of<FutureMarket>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

    return Form(
      key: _formTradeKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: width * 0.27,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: _isBuy ? Color(0xff26A160) : Color(0xff292C51),
                    textStyle: TextStyle(),
                  ),
                  onPressed: () {
                    setState(() {
                      _isBuy = true;
                    });
                    // setAvailalbePrice();
                  },
                  child: Text(
                    'Buy',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.27,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: _isBuy ? Color(0xff292C51) : Color(0xffD84646),
                    textStyle: TextStyle(),
                  ),
                  onPressed: () {
                    setState(() {
                      _isBuy = false;
                    });
                    // setAvailalbePrice();
                  },
                  child: Text(
                    'Sell',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          PopupMenuButton(
            child: Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xff292C51),
                ),
                color: Color(0xff292C51),
                borderRadius: BorderRadius.all(
                  Radius.circular(2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _orderType == 1 ? 'Limit Order' : 'Market Order',
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(
                    Icons.expand_more,
                    color: secondaryTextColor,
                  ),
                ],
              ),
            ),
            onSelected: (value) {
              setState(() {
                _orderType = value as int;
              });
            },
            itemBuilder: (ctx) => [
              _buildPopupMenuItem('Limit Order', 1),
              _buildPopupMenuItem('Market Order', 2),
            ],
          ),
          (_orderType == 2)
              ? Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff292C51),
                    ),
                    color: Color(0xff292C51),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Market Price',
                      style: TextStyle(
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                )
              : Container(),
          (_orderType == 2)
              ? Container()
              : Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff292C51),
                    ),
                    color: Color(0xff292C51),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.remove,
                        color: Color(0xff5E6292),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          onChanged: (value) {
                            calculateTotal('price');
                          },
                          onTap: () {
                            if (_priceField.text.isEmpty) {
                              updateLastPrice();
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              widget.scaffoldKey!.currentState
                                  .hideCurrentSnackBar();
                              snackAlert(context, SnackTypes.errors,
                                  'Price is required');
                              return '';
                            }
                            return null;
                          },
                          controller: _priceField,
                          style: TextStyle(fontSize: 16),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            errorStyle: TextStyle(height: 0),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: TextStyle(
                              fontSize: 16,
                            ),
                            hintText:
                                "Price (${futureMarket.activeMarket['quote']})",
                          ),
                        ),
                      ),
                      Icon(
                        Icons.add,
                        color: Color(0xff5E6292),
                      ),
                    ],
                  ),
                ),
          (_orderType == 2 && _isBuy)
              ? Container()
              : Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff292C51),
                    ),
                    color: Color(0xff292C51),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.remove,
                        color: Color(0xff5E6292),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          onChanged: (value) {
                            calculateTotal('amount');
                          },
                          textAlign: TextAlign.center,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              widget.scaffoldKey!.currentState
                                  .hideCurrentSnackBar();
                              snackAlert(context, SnackTypes.errors,
                                  'Amount is required');
                              return '';
                            }
                            return null;
                          },
                          style: TextStyle(fontSize: 16),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: TextStyle(
                              fontSize: 16,
                            ),
                            errorStyle: TextStyle(height: 0),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: redIndicator),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            hintText:
                                'Amount (${futureMarket.activeMarket['base']})',
                          ),
                          controller: _amountField,
                        ),
                      ),
                      Icon(
                        Icons.add,
                        color: Color(0xff5E6292),
                      ),
                    ],
                  ),
                ),
          _orderType == 1 ? _selectAmountPecentage() : Container(),
          ((_orderType == 2 && _isBuy) || _orderType == 1)
              ? Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff292C51),
                    ),
                    color: Color(0xff292C51),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2),
                    ),
                  ),
                  child: TextFormField(
                    onChanged: (value) {
                      calculateTotal('total');
                    },
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        widget.scaffoldKey!.currentState.hideCurrentSnackBar();
                        snackAlert(
                          context,
                          SnackTypes.errors,
                          'Error in placing and order, try again',
                        );
                        return '';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 16),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      border: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 16,
                      ),
                      errorStyle: TextStyle(height: 0),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: redIndicator),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      hintText: 'Total (${futureMarket.activeMarket['quote']})',
                    ),
                    controller: _totalField,
                  ),
                )
              : Container(),
          _orderType == 2 ? _selectAmountPecentage() : Container(),
          Container(
            padding: EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Avbl',
                  style: TextStyle(color: secondaryTextColor),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 2),
                      child: Text(_availableBalance),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 5),
                      child: Text('${futureMarket.activeMarket['quote']}'),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _amountController.clear();
                        });
                        if (auth.isAuthenticated) {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter updateState) {
                                  return transferAsset(
                                    context,
                                    futureMarket,
                                    updateState,
                                  );
                                },
                              );
                            },
                          );
                        } else {
                          Navigator.pushNamed(context, '/authentication');
                        }
                      },
                      child: Icon(
                        Icons.swap_horiz,
                        size: 15,
                        color: linkColor,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            width: width * 0.7,
            child: ElevatedButton(
              onPressed: () {
                if (auth.isAuthenticated) {
                  if (_formTradeKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    // widget.scaffoldKey!.currentState.hideCurrentSnackBar();
                    // snackAlert(
                    //   context,
                    //   SnackTypes.warning,
                    //   'Feature is under process',
                    // );
                    // createOrder();
                    snackAlert(context, SnackTypes.warning, 'Coming Soon...');
                  } else {
                    // widget.scaffoldKey!.currentState.hideCurrentSnackBar();
                    // snackAlert(
                    //   context,
                    //   SnackTypes.warning,
                    //   'Feature is under process',
                    // );
                  }
                } else {
                  Navigator.pushNamed(context, '/authentication');
                }
              },
              style: ElevatedButton.styleFrom(
                primary: _isBuy ? Color(0xff26A160) : Color(0xffD84646),
                textStyle: TextStyle(),
              ),
              child: Text(
                auth.isAuthenticated
                    ? '${_isBuy ? 'Buy' : 'Sell'} ${futureMarket.activeMarket['base']}'
                    : 'Login / Sign Up',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem _buildPopupMenuItem(String title, int position) {
    return PopupMenuItem(
      value: position,
      child: Row(
        children: [
          Text(title),
        ],
      ),
    );
  }

  Widget _selectAmountPecentage() {
    return Container(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  print('Select preceision');
                },
                child: Container(
                  width: width * 0.13,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff292C51),
                    ),
                    color: Color(0xff292C51),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '25%',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  print('Select preceision');
                },
                child: Container(
                  width: width * 0.13,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff292C51),
                    ),
                    color: Color(0xff292C51),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '50%',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  print('Select preceision');
                },
                child: Container(
                  width: width * 0.13,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff292C51),
                    ),
                    color: Color(0xff292C51),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '75%',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  print('Select preceision');
                },
                child: Container(
                  width: width * 0.13,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff292C51),
                    ),
                    color: Color(0xff292C51),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '100%',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> transferringAsset() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);

    Map formData = {
      "amount": _amountController.text,
      "coinSymbol": _defaultTransferCoin,
    };

    Navigator.pop(context);

    if (_fromDigitalAccountToFutureAccount) {
      await futureMarket.makeSpotToFutureTransfer(context, auth, formData);
    } else {
      await futureMarket.makeFutureToSpotTransfer(context, auth, formData);
    }
    getAvailalbePrice();
  }

  double getFutureBalanceCoin(futureMarket) {
    return double.parse(
        '${futureMarket.openPositions['accountList'][0]['canUseAmount']}');
  }

  Widget transferAsset(context, futureMarket, setState) {
    height = MediaQuery.of(context).size.height;
    var asset = Provider.of<Asset>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);

    List _marginCoins = futureMarket.openPositions.isNotEmpty
        ? futureMarket.openPositions['accountList']
        : [
            {'symbol': 'USDT'},
          ];

    return Container(
      padding: EdgeInsets.all(10),
      height: height * 0.65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Balance Transfer',
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
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Container(
              padding: EdgeInsets.all(10),
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
                  Column(
                    children: [
                      _fromDigitalAccountToFutureAccount
                          ? digitalAccounts(context, futureMarket)
                          : futureAccounts(context, futureMarket),
                      SizedBox(
                        width: width * 0.72,
                        child: Divider(),
                      ),
                      !_fromDigitalAccountToFutureAccount
                          ? digitalAccounts(context, futureMarket)
                          : futureAccounts(context, futureMarket),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _fromDigitalAccountToFutureAccount =
                            !_fromDigitalAccountToFutureAccount;
                        // _availableBalanceFrom = _fromDigitalAccountToFutureAccount
                        //     ? double.parse(
                        //         '${asset.accountBalance['allCoinMap'][_defaultCoin]['normal_balance']}')
                        //     : getFutureBalanceCoin(futureMarket);
                        // _availableBalanceTo = _fromDigitalAccountToFutureAccount
                        //     ? getFutureBalanceCoin(futureMarket)
                        //     : double.parse(
                        //         '${asset.accountBalance['allCoinMap'][_defaultCoin]['normal_balance']}');
                      });
                    },
                    icon: Image.asset(
                      'assets/img/transfer.png',
                      width: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Coins',
                style: TextStyle(
                  color: secondaryTextColor,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                width: 0.3,
                color: Color(0xff5E6292),
              ),
            ),
            child: SizedBox(
              width: width * 0.9,
              child: DropdownButton<String>(
                isExpanded: true,
                isDense: true,
                value: _defaultTransferCoin,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                underline: Container(
                  height: 0,
                ),
                onChanged: (String? newValue) {
                  print('Before: $_defaultTransferCoin');
                  setState(() {
                    _defaultTransferCoin = newValue!;
                  });
                  print('After: $_defaultTransferCoin');
                },
                items: _marginCoins.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                      value: value['symbol'],
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 10),
                            child: CircleAvatar(
                              radius: 12,
                              child: Image.network(
                                '${public.publicInfoMarket['market']['coinList'][value['symbol']]['icon']}',
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 5),
                            child: Text(value['symbol']),
                          ),
                          Text(
                            '${public.publicInfoMarket['market']['coinList'][value['symbol']]['longName']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ));
                }).toList(),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text(
                    'The number of tranfers',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
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
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              signed: true,
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: TextStyle(
                                fontSize: 14,
                              ),
                              hintText: "Please enter the number of transfers",
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _amountController.text =
                                        _fromDigitalAccountToFutureAccount
                                            ? '${asset.accountBalance['allCoinMap'][_defaultTransferCoin]['normal_balance']}'
                                            : '${getFutureBalanceCoin(futureMarket)}';
                                  });
                                },
                                child: Text(
                                  'ALL',
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
                Container(
                  padding: EdgeInsets.only(
                    top: 5,
                    right: 5,
                    left: 5,
                    bottom: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Can be transferred ($_defaultTransferCoin):',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _fromDigitalAccountToFutureAccount
                            ? '${asset.accountBalance['allCoinMap'][_defaultTransferCoin]['normal_balance']}'
                            : '${getFutureBalanceCoin(futureMarket)}',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 15),
                  width: width,
                  child: ElevatedButton(
                    onPressed: () {
                      transferringAsset();
                      // showAlert(
                      //   context,
                      //   Container(),
                      //   'Alert',
                      //   [
                      //     Text('Coming soon...'),
                      //   ],
                      //   'Ok',
                      // );
                    },
                    child: Text('Transfer'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget digitalAccounts(context, futureMarket) {
    return SizedBox(
      width: width * 0.72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(
                    right: _fromDigitalAccountToFutureAccount ? 20 : 36),
                child: Text(_fromDigitalAccountToFutureAccount ? 'From' : 'To'),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  radius: 12,
                  child: Image.network(
                    '${futureMarket.publicSpotInfoMarket['market']['coinList'][_defaultTransferCoin]['icon']}',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 20),
                child: Text('Digital Account'),
              ),
            ],
          ),
          // Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Widget futureAccounts(context, futureMarket) {
    return SizedBox(
      width: width * 0.72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(
                    right: !_fromDigitalAccountToFutureAccount ? 20 : 36),
                child:
                    Text(!_fromDigitalAccountToFutureAccount ? 'From' : 'To'),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  radius: 12,
                  child: Image.network(
                    '${futureMarket.publicSpotInfoMarket['market']['coinList'][_defaultTransferCoin]['icon']}',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 20),
                child: Text('Contract account'),
              ),
            ],
          ),
          // Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}
