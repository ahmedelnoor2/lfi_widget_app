import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/dashboard/skeleton/dashboard_skull.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';

class AssetsInfo extends StatefulWidget {
  const AssetsInfo({
    Key? key,
    required this.headerSymbols,
  }) : super(key: key);

  final List headerSymbols;

  @override
  State<AssetsInfo> createState() => _AssetsInfoState();
}

class _AssetsInfoState extends State<AssetsInfo>
    with SingleTickerProviderStateMixin {
  List<dynamic> rates = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);

    if (public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()] !=
        null) {
      rates = public
          .rate[public.activeCurrency['fiat_symbol'].toUpperCase()].entries
          .map(
            (entry) => {
              'coin': entry.key,
              'value': entry.value,
            },
          )
          .toList();
    }

    return widget.headerSymbols.isEmpty
        ? assetsInfoSkull(context)
        : SizedBox(
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: width * 0.025,
                      bottom: width * 0.025,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: width * 0.15,
                              child: Text(
                                'Coin',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width * 0.34,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Price(USDT)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: width * 0.2,
                              child: Text(
                                '24H Change',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: widget.headerSymbols
                        .map(
                          (item) => Container(
                            padding: EdgeInsets.only(
                              bottom: width * 0.005,
                              top: width * 0.01,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: width * 0.25,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(right: 10),
                                        child: CircleAvatar(
                                          radius: 14,
                                          child: Image.network(
                                            '${public.publicInfoMarket['market']['coinList'][item['coin']]['icon']}',
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${item['coin']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.04,
                                  width: width * 0.22,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      double.parse(item['price'])
                                          .toStringAsPrecision(6),
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  // height: height * 0.04,
                                  width: width * 0.2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        height: height * 0.045,
                                        width: width * 0.2,
                                        child: Card(
                                          shadowColor: Colors.transparent,
                                          color:
                                              double.parse(item['change']) > 0
                                                  ? greenPercentageIndicator
                                                  : redPercentageIndicator,
                                          child: Center(
                                            child: Text(
                                              '${double.parse(item['change']) > 0 ? '+' : ''}${double.parse(item['change']).toStringAsFixed(2)}%',
                                              style: TextStyle(
                                                color: double.parse(
                                                            item['change']) >
                                                        0
                                                    ? greenlightchartColor
                                                    : errorColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          );
  }
}
