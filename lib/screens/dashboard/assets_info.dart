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
            child: Card(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: width * 0.025,
                      right: width * 0.025,
                      left: width * 0.025,
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
                              width: width * 0.26,
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
                        const Divider(),
                      ],
                    ),
                  ),
                  Column(
                    children: widget.headerSymbols
                        .map(
                          (item) => Container(
                            padding: EdgeInsets.all(width * 0.025),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: width * 0.2,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      CircleAvatar(
                                        radius: width * 0.03,
                                        child: Image.network(
                                          '${public.publicInfoMarket['market']['coinList'][item['coin']]['icon']}',
                                        ),
                                      ),
                                      Text('${item['coin']}'),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.04,
                                  width: width * 0.2,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${item['price']}',
                                      ),
                                      Text(
                                        getNumberFormat(
                                          context,
                                          public.rate[public.activeCurrency[
                                                          'fiat_symbol']
                                                      .toUpperCase()] !=
                                                  null
                                              ? public.rate[public
                                                  .activeCurrency['fiat_symbol']
                                                  .toUpperCase()][item['coin']]
                                              : '0',
                                        ),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ],
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
                                        height: height * 0.04,
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
