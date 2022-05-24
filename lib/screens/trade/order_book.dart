import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:provider/provider.dart';

class OrderBook extends StatefulWidget {
  const OrderBook({
    Key? key,
    this.asks,
    this.bids,
    this.lastPrice,
    this.setAmountField,
  }) : super(key: key);
  final List? asks;
  final List? bids;
  final String? lastPrice;
  final Function? setAmountField;

  @override
  State<OrderBook> createState() => _OrderBookState();
}

class _OrderBookState extends State<OrderBook> {
  Future<void> setPriceField(value) async {
    widget.setAmountField!(value);
  }

  @override
  Widget build(BuildContext context) {
    var list = [0.10, 0.20, 0.40, 0.60, 0.80, 1];

    var public = Provider.of<Public>(context, listen: true);

    List? rasks = widget.asks!.isNotEmpty ? widget.asks!.sublist(0, 6) : [];
    List? asks = List.from(rasks.reversed);
    List? bids = widget.bids!.isNotEmpty ? widget.bids!.sublist(0, 6) : [];

    var bidMax = bids.isNotEmpty
        ? (bids.reduce((current, next) =>
            double.parse('${current[1]}') > double.parse('${next[1]}')
                ? current
                : next)[1])
        : 0;
    var askMax = asks.isNotEmpty
        ? (asks.reduce((current, next) =>
            double.parse('${current[1]}') > double.parse('${next[1]}')
                ? current
                : next)[1])
        : 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  'Price',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '(${public.activeMarket['showName'].split('/')[1]})',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '(${public.activeMarket['showName'].split('/')[0]})',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: asks.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                setPriceField(asks[index][0]);
              },
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(
                      top: 3,
                      bottom: 3,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          double.parse('${asks[index][0]}')
                              .toStringAsPrecision(7),
                          style: TextStyle(color: errorColor),
                        ),
                        Text(
                          double.parse('${asks[index][1]}') > 10
                              ? double.parse('${asks[index][1]}')
                                  .toStringAsFixed(2)
                              : double.parse('${asks[index][1]}')
                                  .toStringAsPrecision(4),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      color: Color.fromARGB(73, 175, 86, 76),
                      width: (double.parse('${asks[index][1]}') /
                              double.parse('$askMax')) *
                          100,
                      height: 23,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(2),
              child: Text(
                double.parse('${widget.lastPrice}').toStringAsPrecision(7),
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(2),
              child: Text(
                '≈ ${getNumberFormat(context, double.parse(widget.lastPrice ?? '0'))}',
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
            ),
          ],
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: bids.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                setPriceField(bids[index][0]);
              },
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(
                      top: 3,
                      bottom: 3,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          double.parse('${bids[index][0]}')
                              .toStringAsPrecision(7),
                          style: TextStyle(color: greenlightchartColor),
                        ),
                        Text(
                          double.parse('${bids[index][1]}') > 10
                              ? double.parse('${bids[index][1]}')
                                  .toStringAsFixed(2)
                              : double.parse('${bids[index][1]}')
                                  .toStringAsPrecision(4),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      color: Color.fromARGB(71, 72, 163, 65),
                      width: (double.parse('${bids[index][1]}') /
                              double.parse('$bidMax')) *
                          100,
                      height: 23,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Container(
          padding: EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  print('Select preceision');
                },
                child: Container(
                  width: width * 0.34,
                  padding: EdgeInsets.all(3),
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
                      Text(
                        '0.1',
                        style: TextStyle(fontSize: 15),
                      ),
                      Icon(
                        Icons.expand_more,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('Select preceision');
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(67, 118, 118, 118),
                    ),
                    color: Color.fromARGB(67, 118, 118, 118),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Icon(
                    Icons.dashboard,
                    color: secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
