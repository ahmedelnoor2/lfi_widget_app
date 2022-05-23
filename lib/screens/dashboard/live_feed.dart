import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/screens/dashboard/skeleton/dashboard_skull.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';

class LiveFeed extends StatefulWidget {
  const LiveFeed({
    Key? key,
    required this.headerSymbols,
  }) : super(key: key);

  final List headerSymbols;

  @override
  State<LiveFeed> createState() => _LiveFeedState();
}

class _LiveFeedState extends State<LiveFeed> {
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);

    return Card(
      child: widget.headerSymbols.isEmpty
          ? liveFeedSkull(context)
          : Column(
              children: [
                Container(
                  height: height * 0.125,
                  padding: EdgeInsets.all(width * 0.05),
                  child: headerList(widget.headerSymbols, public),
                ),
              ],
            ),
    );
  }

  Widget headerList(markets, public) {
    return ListView.builder(
      itemCount: widget.headerSymbols.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final market = widget.headerSymbols[index];

        return FittedBox(
          fit: BoxFit.fill,
          child: Container(
            // width: width * 0.14,
            padding: EdgeInsets.only(right: width * 0.015),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: width * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${market['market']}',
                        style: TextStyle(
                          fontSize: width * 0.013,
                          color: secondaryTextColor,
                        ),
                      ),
                      Text(
                        '${double.parse(market['change']) > 0 ? '+' : ''}${double.parse(market['change']).toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: width * 0.013,
                          color: double.parse(market['change']) > 0
                              ? greenlightchartColor
                              : errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: width * 0.01),
                  child: Text(
                    double.parse(market['price']) > 1
                        ? NumberFormat.currency(
                            locale: "en_US",
                            symbol: "",
                          ).format(double.parse(market['price']))
                        : double.parse(market['price']).toStringAsPrecision(4),
                    style: TextStyle(fontSize: width * 0.02),
                  ),
                ),
                Text(
                  getNumberFormat(
                    context,
                    public.rate[public.activeCurrency['fiat_symbol']
                                .toUpperCase()] !=
                            null
                        ? public.rate[public.activeCurrency['fiat_symbol']
                            .toUpperCase()][market['coin']]
                        : '0',
                  ),
                  style: TextStyle(
                    fontSize: width * 0.013,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
