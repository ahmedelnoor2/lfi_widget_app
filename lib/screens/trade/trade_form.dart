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
  }) : super(key: key);

  final scaffoldKey;

  @override
  State<TradeForm> createState() => _TradeFormState();
}

class _TradeFormState extends State<TradeForm>
    with SingleTickerProviderStateMixin {
  final _formTradeKey = GlobalKey<FormState>();
  final TextEditingController _amountField = TextEditingController();
  final TextEditingController _priceField = TextEditingController();
  final TextEditingController _totalField = TextEditingController();

  late final TabController _tabTradeController =
      TabController(length: 2, vsync: this);

  Color _tabIndicatorColor = Colors.green;
  int _orderType = 1;
  double _amount = 0;
  double _price = 0;
  double _total = 0;

  @override
  void initState() {
    updateLastPrice();
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
    var public = Provider.of<Public>(context, listen: false);
    _priceField.text = public.lastPrice;
    setState(() {
      _price = double.parse(public.lastPrice);
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
          TabBar(
            onTap: (value) => setState(() {
              _tabIndicatorColor = value == 0 ? Colors.green : Colors.red;
            }),
            indicatorColor: _tabIndicatorColor,
            tabs: const <Tab>[
              Tab(text: 'Buy'),
              Tab(text: 'Sell'),
            ],
            controller: _tabTradeController,
          ),
          PopupMenuButton(
            child: Container(
              width: width * 0.5,
              margin: EdgeInsets.only(top: 10, bottom: 10),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromARGB(67, 118, 118, 118),
                ),
                color: Color.fromARGB(67, 118, 118, 118),
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      print('info');
                    },
                    child: Icon(
                      Icons.info,
                      size: 15,
                      color: secondaryTextColor,
                    ),
                  ),
                  Text(
                    _orderType == 1 ? 'Limit' : 'Market',
                    style: TextStyle(fontSize: 15),
                  ),
                  Icon(
                    Icons.expand_more,
                    size: 15,
                    color: secondaryTextColor,
                  ),
                ],
              ),
            ),
            onSelected: (value) {
              print(value);
              setState(() {
                _orderType = value as int;
              });
              // _onMenuItemSelected(value as int);
            },
            itemBuilder: (ctx) => [
              _buildPopupMenuItem('Limit', 1),
              _buildPopupMenuItem('Market', 2),
            ],
          ),
          (_orderType == 2)
              ? Container(
                  width: width * 0.5,
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(67, 118, 118, 118),
                    ),
                    color: Color.fromARGB(67, 118, 118, 118),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
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
          (_tabTradeController.index == 1 && _orderType == 2)
              ? Container()
              : Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    onChanged: (value) {
                      calculateTotal('price');
                    },
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if ((value == null || value.isEmpty) && _orderType == 1) {
                        widget.scaffoldKey!.currentState.hideCurrentSnackBar();
                        snackAlert(
                            context, SnackTypes.errors, 'Price is required');
                        return '';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 14),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: redPercentageIndicator,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      errorStyle: TextStyle(height: 0),
                      labelText:
                          'Price (${public.activeMarket['showName'].split('/')[1]})',
                      labelStyle: TextStyle(fontSize: 12),
                      isDense: true,
                      filled: true,
                      fillColor: Color.fromARGB(67, 118, 118, 118),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 0),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 0),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 0),
                      ),
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      // border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.add),
                      prefixIcon: Icon(Icons.remove),
                      // labelText: '30534.21',
                    ),
                    controller: _priceField,
                  ),
                ),
          (_tabTradeController.index == 0 && _orderType == 2)
              ? Container()
              : Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    onChanged: (value) {
                      calculateTotal('amount');
                    },
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        widget.scaffoldKey!.currentState.hideCurrentSnackBar();
                        snackAlert(
                            context, SnackTypes.errors, 'Amount is required');
                        return '';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 14),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: redPercentageIndicator,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      errorStyle: TextStyle(height: 0),
                      labelText:
                          'Amount (${public.activeMarket['showName'].split('/')[0]})',
                      labelStyle: TextStyle(fontSize: 12),
                      isDense: true,
                      filled: true,
                      fillColor: Color.fromARGB(67, 118, 118, 118),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 0),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 0),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 0),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      // floatingLabelAlignment: FloatingLabelAlignment.center,
                      // border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.add),
                      prefixIcon: Icon(Icons.remove),
                      // labelText: '30534.21',
                    ),
                    controller: _amountField,
                  ),
                ),
          _selectAmountPecentage(),
          Container(
            padding: EdgeInsets.only(bottom: 10),
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
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: redPercentageIndicator,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 0),
                ),
                errorStyle: TextStyle(height: 0),
                isDense: true,
                filled: true,
                fillColor: Color.fromARGB(67, 118, 118, 118),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 0),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 0),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                // labelText: 'Total (USDT)',
                label: Align(
                  alignment: Alignment.center,
                  child: Text(
                      'Total (${public.activeMarket['showName'].split('/')[1]})'),
                ),
                labelStyle: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 15,
                ),
              ),
              controller: _totalField,
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
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
          Container(
            padding: EdgeInsets.only(bottom: 10),
            width: width * 0.5,
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
                  primary: _tabTradeController.index == 0
                      ? greenBTNBGColor
                      : pinkBTNBGColor),
              child: Text(
                  '${_tabTradeController.index == 0 ? 'Buy' : 'Sell'} ${public.activeMarket['showName'].split('/')[0]}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectAmountPecentage() {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
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
                  width: width * 0.1,
                  margin: EdgeInsets.only(bottom: 2),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(67, 118, 118, 118),
                    ),
                    color: Color.fromARGB(67, 118, 118, 118),
                  ),
                  child: Container(),
                ),
              ),
              Text(
                '25%',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
              )
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  print('Select preceision');
                },
                child: Container(
                  width: width * 0.1,
                  margin: EdgeInsets.only(bottom: 2),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(67, 118, 118, 118),
                    ),
                    color: Color.fromARGB(67, 118, 118, 118),
                  ),
                  child: Container(),
                ),
              ),
              Text(
                '50%',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
              )
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  print('Select preceision');
                },
                child: Container(
                  width: width * 0.1,
                  margin: EdgeInsets.only(bottom: 2),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(67, 118, 118, 118),
                    ),
                    color: Color.fromARGB(67, 118, 118, 118),
                  ),
                  child: Container(),
                ),
              ),
              Text(
                '75%',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
              )
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  print('Select preceision');
                },
                child: Container(
                  width: width * 0.1,
                  margin: EdgeInsets.only(bottom: 2),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(67, 118, 118, 118),
                    ),
                    color: Color.fromARGB(67, 118, 118, 118),
                  ),
                  child: Container(),
                ),
              ),
              Text(
                '100%',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
              )
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
