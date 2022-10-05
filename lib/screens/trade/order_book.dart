import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

class OrderBook extends StatefulWidget {
  const OrderBook({
    Key? key,
    this.asks,
    this.bids,
    this.lastPrice,
  }) : super(key: key);
  final List? asks;
  final List? bids;
  final String? lastPrice;

  @override
  State<OrderBook> createState() => _OrderBookState();
}

class _OrderBookState extends State<OrderBook> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   

  }
  double _precessionValue = 0.1;
 

  void setPriceField(public, value) {
    public.setAmountField(value);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);

    List? rasks = widget.asks!.isNotEmpty
        ? widget.asks!.length > 6
            ? widget.asks!.sublist(0, 6)
            : widget.asks
        : [];
    List? asks = List.from(rasks!.reversed);
    List? rbids = widget.bids!.isNotEmpty
        ? widget.bids!.length > 6
            ? widget.bids!.sublist(0, 6)
            : widget.bids
        : [];
    List? bids = List.from(rbids!);

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
                    fontSize: 10,
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
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        asks.isEmpty                     //isloading
            ? SkeletonParagraph( 
                style: SkeletonParagraphStyle(
                    lines: 6,
                    spacing: 6,
                    lineStyle: SkeletonLineStyle(
                      randomLength: true,
                      height: 10,
                      borderRadius: BorderRadius.circular(8),
                      minLength: MediaQuery.of(context).size.width / 6,
                      maxLength: MediaQuery.of(context).size.width,
                      
                    )),
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: asks.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      setPriceField(public, asks[index][0]);
                    },
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(
                            top: 1,
                            bottom: 1,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  double.parse('${asks[index][0] ?? 0}')
                                      .toStringAsPrecision(7),
                                  style: TextStyle(
                                    color: redIndicator,
                                   
                                  ),
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  double.parse('${asks[index][1] ?? 0}') > 10
                                      ? double.parse('${asks[index][1] ?? 0}')
                                          .toStringAsFixed(2)
                                      : double.parse('${asks[index][1] ?? 0}')
                                          .toStringAsPrecision(4),
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            color: Color.fromARGB(73, 175, 86, 76),
                            // width: ((double.parse('${asks[index][1] ?? 0}') /
                            //             double.parse('$askMax')) *
                            //         2) *
                            //     100,
                            // width: width * 0.5,
                            height: 21,
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
            Text(
              double.parse('${widget.lastPrice}').toStringAsPrecision(7),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              '≈ ${getNumberFormat(context, double.parse(widget.lastPrice ?? '0'))}',
              style: TextStyle(fontSize: 12, color: secondaryTextColor),
            ),
          ],
        ),
        bids.isEmpty
            ? SkeletonParagraph(                     //isloading
                style: SkeletonParagraphStyle(
                    lines: 6,
                    spacing: 6,
                    lineStyle: SkeletonLineStyle(
                      randomLength: true,
                      height: 10,
                      borderRadius: BorderRadius.circular(8),
                      minLength: MediaQuery.of(context).size.width / 6,
                      maxLength: MediaQuery.of(context).size.width,
                      
                    )),
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: bids.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      setPriceField(public, bids[index][0] ?? 0);
                    },
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(
                            top: 1,
                            bottom: 1,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FittedBox(
                                
                      fit: BoxFit.cover,
                                child: Text(
                                  double.parse('${bids[index][0] ?? 0}')
                                      .toStringAsPrecision(7),
                                  style: TextStyle(
                                    color: greenIndicator,
                                
                                  ),
                                ),
                              ),
                              FittedBox(
                                
                      fit: BoxFit.cover,
                                child: Text(
                                  double.parse('${bids[index][1] ?? 0}') > 10
                                      ? double.parse('${bids[index][1] ?? 0}')
                                          .toStringAsFixed(2)
                                      : double.parse('${bids[index][1] ?? 0}')
                                          .toStringAsPrecision(4),
                                  
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            color: Color.fromARGB(71, 72, 163, 65),
                            // width: ((double.parse('${bids[index][1] ?? 0}') /
                            //             double.parse('$bidMax')) *
                            //         2) *
                            //     100,
                            // width: width * 0.5,
                            height: 21,
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
             PopupMenuButton(
                child: Container(
                  width: width * 0.30,
                  height: height * 0.04,
                  margin: EdgeInsets.only(bottom: 2),
                  padding:
                      EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 5),
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
                        _precessionValue.toString(),
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
                    _precessionValue = double.parse(value.toString());
                  });
                },
                itemBuilder: (ctx) => [
                  _buildPercessionItem('0.1', 0.1),
                  _buildPercessionItem('0.001', 0.001),
                  _buildPercessionItem('0.00001', 0.00001),
                ],
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
                      Radius.circular(2),
                    ),
                  ),
                  child: Icon(
                    Icons.dashboard,
                    color: secondaryTextColor,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  PopupMenuItem _buildPercessionItem(String title, double position) {
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
