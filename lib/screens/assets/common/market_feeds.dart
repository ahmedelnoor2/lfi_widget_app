import 'package:flutter/material.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/assets/skeleton/assets_skull.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class MarketFeeds extends StatefulWidget {
  const MarketFeeds({
    Key? key,
    required this.availableMarkets,
    required this.marketData,
    required this.loadingMarketData,
  }) : super(key: key);

  final List availableMarkets;
  final Map marketData;
  final bool loadingMarketData;

  @override
  State<MarketFeeds> createState() => _MarketFeedsState();
}

class _MarketFeedsState extends State<MarketFeeds>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.availableMarkets.isNotEmpty
            ? Container(
                padding: EdgeInsets.only(left: 5, bottom: 5),
                child: Text(
                  'Markets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Container(),
        SizedBox(
          height: width * 0.26,
          width: width,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.availableMarkets.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final market = widget.availableMarkets[index];

              return InkWell(
                onTap: () async {
                  await public.setActiveMarket(market);
                  Navigator.pushNamed(context, '/kline_chart');
                },
                child: Card(
                  child: Container(
                    width: width * 0.30,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${market['showName']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: secondaryTextColor,
                              ),
                            ),
                            double.parse('${market['multiple']}') > 0
                                ? Text(
                                    '${market['multiple']}x',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: warningColor,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 6, bottom: 6),
                          child: widget.loadingMarketData
                              ? priceSkull(context)
                              : Text(
                                  '${widget.marketData['${market['symbol']}'] != null ? widget.marketData['${market['symbol']}']['price'] : '--'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                        widget.loadingMarketData
                            ? priceSkull(context)
                            : Text(
                                '${widget.marketData['${market['symbol']}'] != null ? widget.marketData['${market['symbol']}']['change'] : '--'}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: widget.marketData[
                                              '${market['symbol']}'] !=
                                          null
                                      ? double.parse(
                                                  '${widget.marketData['${market['symbol']}']['change']}') >
                                              0
                                          ? greenIndicator
                                          : redIndicator
                                      : secondaryTextColor,
                                ),
                              ),
                      ],
                    ),
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
