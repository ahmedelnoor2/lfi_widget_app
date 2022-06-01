import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
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

  // late final TabController _tabTradeController =
  //     TabController(length: 2, vsync: this);

  Color _tabIndicatorColor = Colors.green;
  int _orderType = 1;
  double _amount = 0;
  double _price = 0;
  double _total = 0;
  bool _isBuy = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _amountField.dispose();
    _priceField.dispose();
    _totalField.dispose();
    super.dispose();
  }

  void updateLastPrice() {
    _priceField.text = widget.lastPrice;
    setState(() {
      _price = double.parse(widget.lastPrice);
    });
  }

  void calculateTotal(field) {
    if (field == 'amount') {
      if (_amountField.text.isNotEmpty) {
        setState(() {
          _amount = double.parse(_amountField.text);
          _total = double.parse(_amountField.text) * _price;
        });
        _totalField.text = '${double.parse(_amountField.text) * _price}';
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
        setState(() {
          _total = double.parse(_totalField.text);
          _amount = double.parse(_totalField.text) / _price;
        });
        _amountField.text = '${double.parse(_totalField.text) / _price}';
      } else {
        _amountField.clear();
      }
    }
  }

  Future<void> setAmountField() async {
    var public = Provider.of<Public>(context, listen: false);
    _priceField.text = public.amountField;
    await public.amountFieldDisable();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var public = Provider.of<Public>(context, listen: true);

    if (public.amountFieldUpdate) {
      setAmountField();
    }

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
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 5),
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
          (!_isBuy && _orderType == 2)
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
                          onTap: () {},
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
                              fontSize: 14,
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
          (_isBuy && _orderType == 2)
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
                          style: TextStyle(fontSize: 14),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: TextStyle(
                              fontSize: 14,
                            ),
                            errorStyle: TextStyle(height: 0),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.red),
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
          _selectAmountPecentage(),
          Container(
            margin: EdgeInsets.only(bottom: 5),
            padding: EdgeInsets.all(12),
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
              style: TextStyle(fontSize: 14),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                isDense: true,
                border: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
                errorStyle: TextStyle(height: 0),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.red),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                hintText:
                    'Total (${public.activeMarket['showName'].split('/')[1]})',
              ),
              controller: _totalField,
            ),
          ),
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
                      child: Text('0.0000'),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 5),
                      child: Text(
                          '${public.activeMarket['showName'].split('/')[1]}'),
                    ),
                    Icon(
                      Icons.add_circle,
                      size: 15,
                      color: linkColor,
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
                if (_formTradeKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  widget.scaffoldKey!.currentState.hideCurrentSnackBar();
                  snackAlert(
                    context,
                    SnackTypes.warning,
                    'Feature is under process',
                  );
                } else {
                  widget.scaffoldKey!.currentState.hideCurrentSnackBar();
                  snackAlert(
                    context,
                    SnackTypes.warning,
                    'Feature is under process',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: _isBuy ? Color(0xff26A160) : Color(0xffD84646),
                textStyle: TextStyle(),
              ),
              child: Text(
                '${_isBuy ? 'Buy' : 'Sell'} ${public.activeMarket['showName'].split('/')[0]}',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
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
                        fontSize: 10,
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
                        fontSize: 10,
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
                        fontSize: 10,
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
                        fontSize: 10,
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
