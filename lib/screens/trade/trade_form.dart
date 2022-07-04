import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/screens/future_trade/future_trade_form.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';

class TradeForm extends StatefulWidget {
  const TradeForm({
    Key? key,
    this.scaffoldKey,
    this.lastPrice,
  }) : super(key: key);

  final scaffoldKey;
  final lastPrice;

  @override
  State<TradeForm> createState() => _TradeFormState();
}

class _TradeFormState extends State<TradeForm> {
  final _formTradeKey = GlobalKey<FormState>();
  final TextEditingController _amountField = TextEditingController();
  final TextEditingController _priceField = TextEditingController();
  final TextEditingController _totalField = TextEditingController();

  var _timer;

  // late final TabController _tabTradeController =
  //     TabController(length: 2, vsync: this);

  Color _tabIndicatorColor = greenIndicator;
  int _orderType = 1;
  double _amount = 0;
  double _price = 0;
  double _total = 0;
  String _availableBalance = '0.000000';
  bool _isBuy = true;
  double _currentAmountSelection = 0;

  @override
  void initState() {
    setAvailalbePrice();
    super.initState();
  }

  @override
  void dispose() {
    _amountField.dispose();
    _priceField.dispose();
    _totalField.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  void updateLastPrice() {
    _priceField.text = widget.lastPrice;
    setState(() {
      _price = double.parse(widget.lastPrice);
    });
    calculateTotal('price');
  }

  Future<void> setAvailalbePrice() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);

    if (auth.isAuthenticated) {
      var asset = Provider.of<Asset>(context, listen: false);
      await asset.getAccountBalance(
        context,
        auth,
        "${public.activeMarket['showName'].split('/')[0]},${public.activeMarket['showName'].split('/')[1]}",
      );
      setState(() {
        _availableBalance = _isBuy
            ? double.parse(asset.accountBalance['allCoinMap']
                        [public.activeMarket['name'].split('/')[1]]
                    ['normal_balance'])
                .toStringAsPrecision(6)
            : double.parse(asset.accountBalance['allCoinMap']
                        [public.activeMarket['name'].split('/')[0]]
                    ['normal_balance'])
                .toStringAsPrecision(6);
      });
    }
  }

  void calculateTotal(field) {
    if (field == 'amount') {
      if (_amountField.text.isNotEmpty) {
        try {
          setState(() {
            _amount = double.parse(_amountField.text);
            _total = double.parse(_amountField.text) * _price;
          });
          _totalField.text =
              '${(double.parse(_amountField.text) * _price).toStringAsFixed(4)}';
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
        _totalField.text =
            '${(double.parse(_priceField.text) * _amount).toStringAsFixed(4)}';
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

  Future<void> setPriceField() async {
    var public = Provider.of<Public>(context, listen: false);
    _priceField.text = public.amountField;
    _timer = Timer(Duration(milliseconds: 400), () async {
      await public.amountFieldDisable();
    });
    calculateTotal('price');
  }

  Future<void> createOrder() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var trading = Provider.of<Trading>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);
    var formData = {
      "price": _orderType == 1
          ? _priceField.text
          : (_orderType == 2)
              ? null
              : public.lastPrice,
      "side": _isBuy ? "BUY" : "SELL",
      "symbol": public.activeMarket['symbol'],
      "type": _orderType,
      "volume":
          (_orderType == 2 && _isBuy) ? _totalField.text : _amountField.text,
    };

    await trading.createOrder(context, auth, formData);
    getOpenOrders();
  }

  Future<void> getOpenOrders() async {
    var trading = Provider.of<Trading>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);

    await trading.getOpenOrders(context, auth, {
      "entrust": 1,
      "isShowCanceled": 0,
      "orderType": _orderType,
      "page": 1,
      "pageSize": 10,
      "symbol": "",
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var public = Provider.of<Public>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

    if (public.amountFieldUpdate) {
      setPriceField();
    }

    return Form(
      key: _formTradeKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: kIsWeb ? EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
            child: Row(
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
                        _amountField.clear();
                        _totalField.clear();
                        _currentAmountSelection = 0;
                        _isBuy = true;
                      });
                      setAvailalbePrice();
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
                        _amountField.clear();
                        _totalField.clear();
                        _currentAmountSelection = 0;
                        _isBuy = false;
                      });
                      setAvailalbePrice();
                    },
                    child: Text(
                      'Sell',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
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
                    _orderType == 1 ? 'Limit' : 'Market',
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
              _buildPopupMenuItem('Limit', 1),
              _buildPopupMenuItem('Market', 2),
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
                          inputFormatters: [
                            DecimalTextInputFormatter(
                              decimalRange: public.activeMarket.isNotEmpty
                                  ? public.activeMarket['price']
                                  : 4,
                              coUnit: 2,
                            ),
                          ],
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
                                "Price (${public.activeMarket['showName'].split('/')[1]})",
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
                          inputFormatters: [
                            DecimalTextInputFormatter(
                              decimalRange: public.activeMarket.isNotEmpty
                                  ? public.activeMarket['volume']
                                  : 4,
                              coUnit: 2,
                            ),
                          ],
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
                                'Amount (${public.activeMarket['showName'].split('/')[0]})',
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
          _orderType == 1 ? _selectAmountPecentage(public, asset) : Container(),
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
                    inputFormatters: [
                      DecimalTextInputFormatter(
                        decimalRange: public.activeMarket.isNotEmpty
                            ? public.activeMarket['price']
                            : 4,
                        coUnit: 2,
                      ),
                    ],
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
                      hintText:
                          'Total (${public.activeMarket['showName'].split('/')[1]})',
                    ),
                    controller: _totalField,
                  ),
                )
              : Container(),
          _orderType == 2 ? _selectAmountPecentage(public, asset) : Container(),
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
                      child: Text(
                          '${_isBuy ? public.activeMarket['showName'].split('/')[1] : public.activeMarket['showName'].split('/')[0]}'),
                    ),
                    // Icon(
                    //   Icons.add_circle,
                    //   size: 15,
                    //   color: linkColor,
                    // ),
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
                    createOrder();
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
                padding: kIsWeb ? EdgeInsets.all(18) : EdgeInsets.zero,
              ),
              child: Text(
                auth.isAuthenticated
                    ? '${_isBuy ? 'Buy' : 'Sell'} ${public.activeMarket['showName'].split('/')[0]}'
                    : 'Login / Sign Up',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectAmountPecentage(public, asset) {
    return Container(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _currentAmountSelection = 25;
                    if (_isBuy && (_orderType == 2)) {
                      _totalField.text = (double.parse(asset
                                          .accountBalance['allCoinMap'][
                                      public.activeMarket['name'].split('/')[1]]
                                  ['normal_balance']) *
                              0.25)
                          .toStringAsPrecision(6);
                    } else {
                      _amountField.text = (double.parse(asset
                                          .accountBalance['allCoinMap'][
                                      public.activeMarket['name'].split('/')[0]]
                                  ['normal_balance']) *
                              0.25)
                          .toStringAsPrecision(6);
                    }
                  });
                  if (_isBuy && (_orderType == 2)) {
                    calculateTotal('total');
                  } else {
                    calculateTotal('amount');
                  }
                },
                child: Container(
                  width: width * 0.13,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _currentAmountSelection >= 25
                          ? linkColor
                          : Color(0xff292C51),
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
                        color: _currentAmountSelection >= 25
                            ? linkColor
                            : secondaryTextColor,
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
              InkWell(
                onTap: () {
                  setState(() {
                    _currentAmountSelection = 50;
                    if (_isBuy && (_orderType == 2)) {
                      _totalField.text = (double.parse(asset
                                          .accountBalance['allCoinMap'][
                                      public.activeMarket['name'].split('/')[1]]
                                  ['normal_balance']) *
                              0.50)
                          .toStringAsPrecision(6);
                    } else {
                      _amountField.text = (double.parse(asset
                                          .accountBalance['allCoinMap'][
                                      public.activeMarket['name'].split('/')[0]]
                                  ['normal_balance']) *
                              0.50)
                          .toStringAsPrecision(6);
                    }
                  });
                  if (_isBuy && (_orderType == 2)) {
                    calculateTotal('total');
                  } else {
                    calculateTotal('amount');
                  }
                },
                child: Container(
                  width: width * 0.13,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _currentAmountSelection >= 50
                          ? linkColor
                          : Color(0xff292C51),
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
                        color: _currentAmountSelection >= 50
                            ? linkColor
                            : secondaryTextColor,
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
              InkWell(
                onTap: () {
                  setState(() {
                    _currentAmountSelection = 75;
                    if (_isBuy && (_orderType == 2)) {
                      _totalField.text = (double.parse(asset
                                          .accountBalance['allCoinMap'][
                                      public.activeMarket['name'].split('/')[1]]
                                  ['normal_balance']) *
                              0.75)
                          .toStringAsPrecision(6);
                    } else {
                      _amountField.text = (double.parse(asset
                                          .accountBalance['allCoinMap'][
                                      public.activeMarket['name'].split('/')[0]]
                                  ['normal_balance']) *
                              0.75)
                          .toStringAsPrecision(6);
                    }
                  });
                  if (_isBuy && (_orderType == 2)) {
                    calculateTotal('total');
                  } else {
                    calculateTotal('amount');
                  }
                },
                child: Container(
                  width: width * 0.13,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _currentAmountSelection >= 75
                          ? linkColor
                          : Color(0xff292C51),
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
                        color: _currentAmountSelection >= 75
                            ? linkColor
                            : secondaryTextColor,
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
              InkWell(
                onTap: () {
                  setState(() {
                    _currentAmountSelection = 100;
                    if (_isBuy && (_orderType == 2)) {
                      _totalField.text = truncateTo(
                          '${(double.parse(asset.accountBalance['allCoinMap'][public.activeMarket['name'].split('/')[1]]['normal_balance']) * 1)}',
                          public.activeMarket.isNotEmpty
                              ? public.activeMarket['price']
                              : 4);
                    } else {
                      _amountField.text = truncateTo(
                          '${(double.parse(asset.accountBalance['allCoinMap'][public.activeMarket['name'].split('/')[0]]['normal_balance']) * 1)}',
                          public.activeMarket.isNotEmpty
                              ? public.activeMarket['price']
                              : 4);
                    }
                  });
                  if (_isBuy && (_orderType == 2)) {
                    calculateTotal('total');
                  } else {
                    calculateTotal('amount');
                  }
                },
                child: Container(
                  width: width * 0.13,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _currentAmountSelection >= 100
                          ? linkColor
                          : Color(0xff292C51),
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
                        color: _currentAmountSelection >= 100
                            ? linkColor
                            : secondaryTextColor,
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
}
