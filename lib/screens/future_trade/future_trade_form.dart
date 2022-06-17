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

  final TextEditingController _takeProfitField = TextEditingController();
  final TextEditingController _stopLossField = TextEditingController();

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

  //Avance Options
  bool _advancedOptions = false;
  String _advanceOptionValue = 'P/O';

  //TP/SL Options
  bool _tpSlOptions = false;

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
    _takeProfitField.dispose();
    _stopLossField.dispose();
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
      await futureMarket.getCurrentOrders(
          context, auth, futureMarket.activeMarket['id']);
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

  Future<void> createOrder(type) async {
    var auth = Provider.of<Auth>(context, listen: false);
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);
    var formData = {
      // "price": _orderType == 1
      //     ? _priceField.text
      //     : (_orderType == 2)
      //         ? null
      //         : public.lastPrice,
      // "side": _isBuy ? "BUY" : "SELL",
      // "symbol": public.activeMarket['symbol'],
      // "type": _orderType,
      // "volume":
      //     (_orderType == 2 && _isBuy) ? _totalField.text : _amountField.text,

      "contractId": futureMarket.activeMarket['id'],
      "isConditionOrder": false,
      "isOto": false,
      "leverageLevel": futureMarket.userConfiguration['nowLevel'],
      "open": _isBuy ? "OPEN" : "CLOSE",
      "positionType": futureMarket.userConfiguration['positionModel'],
      "price": _priceField.text,
      "side": type,
      "stopLossPrice": 0,
      "stopLossTrigger": null,
      "stopLossType": 2,
      "takerProfitPrice": 0,
      "takerProfitTrigger": null,
      "takerProfitType": 2,
      "triggerPrice": null,
      "type": 1,
      "volume": int.parse((double.parse(_amountField.text) /
              double.parse('${futureMarket.activeMarket['multiplier']}'))
          .toStringAsFixed(0)),
    };

    // print(formData);

    await futureMarket.createOrder(context, auth, formData);
    await futureMarket.getCurrentOrders(
        context, auth, futureMarket.activeMarket['id']);
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

    // print(futureMarket.lastPrice);

    return Form(
      key: _formTradeKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    'Open',
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
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          PopupMenuButton(
            child: Container(
              margin: EdgeInsets.only(bottom: 2),
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
                    _orderType == 1
                        ? 'Limit Order'
                        : _orderType == 2
                            ? 'Market Order'
                            : 'Stop Order',
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
              _buildPopupMenuItem('Stop Order', 3),
            ],
          ),
          Container(
            padding: EdgeInsets.only(bottom: 2),
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
          (_orderType == 2)
              ? Container(
                  margin: EdgeInsets.only(bottom: 5),
                  padding: EdgeInsets.all(8),
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
          (_orderType == 2 && _isBuy)
              ? Container(
                  margin: EdgeInsets.only(bottom: 5),
                  padding: EdgeInsets.all(6),
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
          (_orderType == 2)
              ? Container()
              : Container(
                  margin: EdgeInsets.only(bottom: 5),
                  padding: EdgeInsets.all(5),
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
                  margin: EdgeInsets.only(bottom: 4),
                  padding: EdgeInsets.all(5),
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
                                'Volume (${futureMarket.activeMarket['base']})',
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
          _selectAmountPecentage(),
          Container(
            padding: EdgeInsets.only(top: 4, bottom: 2),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 5),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _advancedOptions = !_advancedOptions;
                          });
                        },
                        child: Icon(
                          Icons.check_circle,
                          color: _advancedOptions
                              ? linkColor
                              : secondaryTextColor400,
                          size: 15,
                        ),
                      ),
                    ),
                    Text(
                      'Advance Options',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          _advancedOptions
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Transform.scale(
                            scale: 0.9,
                            child: Radio(
                              activeColor: linkColor,
                              value: 'P/O',
                              groupValue: _advanceOptionValue,
                              onChanged: <String>(value) {
                                setState(() {
                                  _advanceOptionValue = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Text(
                          'P/O',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Transform.scale(
                            scale: 0.9,
                            child: Radio(
                              activeColor: linkColor,
                              value: 'IOC',
                              groupValue: _advanceOptionValue,
                              onChanged: <String>(value) {
                                setState(() {
                                  _advanceOptionValue = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Text(
                          'IOC',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Transform.scale(
                            scale: 0.9,
                            child: Radio(
                              activeColor: linkColor,
                              value: 'FOK',
                              groupValue: _advanceOptionValue,
                              onChanged: <String>(value) {
                                setState(() {
                                  _advanceOptionValue = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Text(
                          'FOK',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    )
                  ],
                )
              : Container(),
          Container(
            padding: EdgeInsets.only(top: 2, bottom: 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 5),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _tpSlOptions = !_tpSlOptions;
                          });
                        },
                        child: Icon(
                          Icons.check_circle,
                          color:
                              _tpSlOptions ? linkColor : secondaryTextColor400,
                          size: 15,
                        ),
                      ),
                    ),
                    Text(
                      'TP/SL',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          _tpSlOptions
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 100,
                      margin: EdgeInsets.only(bottom: 5),
                      padding: EdgeInsets.all(6),
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
                            widget.scaffoldKey!.currentState
                                .hideCurrentSnackBar();
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
                            fontSize: 12,
                          ),
                          errorStyle: TextStyle(height: 0),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: redIndicator),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          hintText: 'Take Profit',
                        ),
                        controller: _takeProfitField,
                      ),
                    ),
                    Container(
                      width: 100,
                      margin: EdgeInsets.only(bottom: 5),
                      padding: EdgeInsets.all(6),
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
                            widget.scaffoldKey!.currentState
                                .hideCurrentSnackBar();
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
                            fontSize: 12,
                          ),
                          errorStyle: TextStyle(height: 0),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: redIndicator),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          hintText: 'Stop Loss',
                        ),
                        controller: _stopLossField,
                      ),
                    )
                  ],
                )
              : Container(),
          Container(
            padding: EdgeInsets.only(top: 2, bottom: 2),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 5),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 5),
                            child: Text(
                              'Max Buy:',
                              style: TextStyle(
                                fontSize: 12,
                                color: greenIndicator,
                              ),
                            ),
                          ),
                          Text(
                            '0 USDT',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text(
                            'Max Sell:',
                            style: TextStyle(
                              fontSize: 12,
                              color: redIndicator,
                            ),
                          ),
                        ),
                        Text(
                          '0 USDT',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 2, bottom: 2),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text(
                            'Cost:',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                        Text(
                          '0 USDT',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text(
                            'Cost:',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                        Text(
                          '0 USDT',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: auth.isAuthenticated ? null : width * 0.55,
                child: ElevatedButton(
                  onPressed: () {
                    if (auth.isAuthenticated) {
                      if (_formTradeKey.currentState!.validate()) {
                        createOrder('BUY');
                        // snackAlert(
                        //     context, SnackTypes.warning, 'Coming Soon...');
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
                    primary: Color(0xff26A160),
                    textStyle: TextStyle(),
                  ),
                  child: Text(
                    auth.isAuthenticated
                        ? '${_isBuy ? 'Open Long' : 'Close Short'}'
                        : 'Login / Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              auth.isAuthenticated
                  ? SizedBox(
                      // width: width * 0.7,
                      child: ElevatedButton(
                        onPressed: () {
                          if (auth.isAuthenticated) {
                            if (_formTradeKey.currentState!.validate()) {
                              createOrder('SELL');
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
                          primary: Color(0xffD84646),
                          textStyle: TextStyle(),
                        ),
                        child: Text(
                          '${_isBuy ? 'Open Short' : 'Close Long'}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
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
      padding: EdgeInsets.only(bottom: 4),
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
                  padding: EdgeInsets.all(2),
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
                  padding: EdgeInsets.all(2),
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
                  padding: EdgeInsets.all(2),
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
                  padding: EdgeInsets.all(2),
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
    return futureMarket.openPositions.isNotEmpty
        ? double.parse(
            '${futureMarket.openPositions['accountList'][0]['canUseAmount']}')
        : 0.00;
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
