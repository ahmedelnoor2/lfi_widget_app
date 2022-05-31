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

    return Container(
      child: widget.headerSymbols.isEmpty
          ? liveFeedSkull(context)
          : Column(
              children: [
                Container(
                  height: height * 0.12,
                  padding: EdgeInsets.only(
                    top: width * 0.055,
                    bottom: width * 0.055,
                  ),
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

        return SizedBox(
          width: width * 0.31,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 3),
                      child: Text(
                        '${market['market']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                    Container(
                      height: 14,
                      width: 32,
                      decoration: BoxDecoration(
                        color: double.parse(market['change']) > 0
                            ? greenPercentageIndicator
                            : redPercentageIndicator,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${double.parse(market['change']) > 0 ? '+' : ''}${double.parse(market['change']).toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 8,
                            color: double.parse(market['change']) > 0
                                ? greenIndicator
                                : errorColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                child: Text(
                  double.parse(market['price']) > 1
                      ? NumberFormat.currency(
                          locale: "en_US",
                          symbol: "",
                        ).format(double.parse(market['price']))
                      : double.parse(market['price']).toStringAsPrecision(4),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: double.parse(market['change']) > 0
                          ? greenIndicator
                          : errorColor),
                ),
              ),
              Text(
                '≈${getNumberFormat(
                  context,
                  public.rate[public.activeCurrency['fiat_symbol']
                              .toUpperCase()] !=
                          null
                      ? public.rate[public.activeCurrency['fiat_symbol']
                          .toUpperCase()][market['coin']]
                      : '0',
                )}',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
