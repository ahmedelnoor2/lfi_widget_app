import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class TradeForm extends StatefulWidget {
  const TradeForm({
    Key? key,
    this.isLastPriceUpdate,
    this.toggleIsPriceUpdate,
  }) : super(key: key);

  final isLastPriceUpdate;
  final toggleIsPriceUpdate;

  @override
  State<TradeForm> createState() => _TradeFormState();
}

class _TradeFormState extends State<TradeForm>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountField = TextEditingController();
  final TextEditingController _priceField = TextEditingController();
  final TextEditingController _totalField = TextEditingController();

  late final TabController _tabTradeController =
      TabController(length: 2, vsync: this);

  Color _tabIndicatorColor = Colors.green;
  int _orderType = 1;

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

  void togglePriceUpdate() {
    widget.toggleIsPriceUpdate();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    // if (widget.isLastPriceUpdate) {
    //   togglePriceUpdate();
    // }

    return Column(
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
        (_tabTradeController.index == 0 && _orderType == 2)
            ? Container()
            : Container(
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                  style: TextStyle(fontSize: 14),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (BTC)',
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
                    // floatingLabelAlignment: FloatingLabelAlignment.center,
                    // border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.add),
                    prefixIcon: Icon(Icons.remove),
                    // labelText: '30534.21',
                  ),
                  controller: _amountField,
                ),
              ),
        (_tabTradeController.index == 1 && _orderType == 2)
            ? Container()
            : Container(
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please a price';
                    }
                    return null;
                  },
                  style: TextStyle(fontSize: 14),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Price (USDT)',
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
        _selectAmountPecentage(),
        (_orderType == 2)
            ? Container()
            : Container(
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter total';
                    }
                    return null;
                  },
                  style: TextStyle(fontSize: 14),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
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
                      child: Text('Total (USDT)'),
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
                    child: Text('USDT'),
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
              print('buy');
            },
            style: ElevatedButton.styleFrom(
                primary: _tabTradeController.index == 0
                    ? greenBTNBGColor
                    : pinkBTNBGColor),
            child:
                Text('${_tabTradeController.index == 0 ? 'Buy' : 'Sell'} BTC'),
          ),
        ),
      ],
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
