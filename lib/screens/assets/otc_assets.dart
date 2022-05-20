import 'package:flutter/material.dart';
import 'package:lyotrade/screens/assets/skeleton/assets_skull.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';

class OtcAssets extends StatefulWidget {
  const OtcAssets({
    Key? key,
    this.assets,
    this.bottomBoxSize,
    this.totalBalance,
    this.totalBalanceSymbol,
  }) : super(key: key);

  final assets;
  final bottomBoxSize;
  final totalBalance;
  final totalBalanceSymbol;

  @override
  State<OtcAssets> createState() => _OtcAssetsState();
}

class _OtcAssetsState extends State<OtcAssets> {
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 4),
          width: width,
          child: Card(
            child: Container(
              padding: EdgeInsets.all(width * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      bottom: width * 0.03,
                    ),
                    child: Text(
                      'Total Assets (${widget.totalBalanceSymbol})',
                      style: TextStyle(
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.totalBalance}',
                        style: TextStyle(
                          fontSize: width * 0.05,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: width * 0.03),
                        child: Text(
                          getNumberFormat(
                            context,
                            public.rate[public.activeCurrency['fiat_symbol']
                                            .toUpperCase()]
                                        [widget.totalBalanceSymbol] !=
                                    null
                                ? '${(widget.totalBalance ?? 0) * public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()][widget.totalBalanceSymbol]}'
                                : '0',
                          ),
                          style: TextStyle(
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: height * widget.bottomBoxSize,
          child: widget.assets.isEmpty
              ? assetsSkull(context)
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: widget.assets.length,
                  itemBuilder: (BuildContext context, int index) {
                    var asset = widget.assets[index];

                    return Card(
                      child: Container(
                        padding: EdgeInsets.all(width * 0.03),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FittedBox(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            right: width * 0.02),
                                        child: CircleAvatar(
                                          radius: width * 0.035,
                                          child: Image.network(
                                            '${public.publicInfoMarket['market']['coinList'][asset['coinSymbol']]['icon']}',
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${asset['coinSymbol']}',
                                        style: TextStyle(
                                          fontSize: width * 0.05,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_sharp,
                                  size: width * 0.05,
                                )
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.only(top: width * 0.035),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: width * 0.18,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                        Text(
                                          double.parse(asset['total_balance'])
                                              .toStringAsFixed(4),
                                          style: TextStyle(
                                            fontSize: width * 0.045,
                                            // color: secondaryTextColor,
                                          ),
                                        ),
                                        Text(
                                          getNumberFormat(
                                            context,
                                            public.rate[
                                                        public.activeCurrency[
                                                                'fiat_symbol']
                                                            .toUpperCase()][widget
                                                        .totalBalanceSymbol] !=
                                                    null
                                                ? '${double.parse(asset['total_balance'] ?? '0') * public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()][asset['coinSymbol']]}'
                                                : '0',
                                          ),
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: width * 0.18,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Available',
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                        Text(
                                          double.parse(asset['normal'])
                                              .toStringAsFixed(4),
                                          style: TextStyle(
                                            fontSize: width * 0.045,
                                            // color: secondaryTextColor,
                                          ),
                                        ),
                                        Text(
                                          getNumberFormat(
                                            context,
                                            public.rate[
                                                        public.activeCurrency[
                                                                'fiat_symbol']
                                                            .toUpperCase()][widget
                                                        .totalBalanceSymbol] !=
                                                    null
                                                ? '${double.parse(asset['normal'] ?? '0') * public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()][asset['coinSymbol']]}'
                                                : '0',
                                          ),
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: width * 0.18,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'In Orders',
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                        Text(
                                          double.parse(asset['lock'])
                                              .toStringAsFixed(4),
                                          style: TextStyle(
                                            fontSize: width * 0.045,
                                            // color: secondaryTextColor,
                                          ),
                                        ),
                                        Text(
                                          getNumberFormat(
                                            context,
                                            public.rate[
                                                        public.activeCurrency[
                                                                'fiat_symbol']
                                                            .toUpperCase()][widget
                                                        .totalBalanceSymbol] !=
                                                    null
                                                ? '${double.parse(asset['lock'] ?? '0') * public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()][asset['coinSymbol']]}'
                                                : '0',
                                          ),
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
