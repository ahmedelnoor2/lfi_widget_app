import 'package:flutter/material.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

class MarketHeader extends StatefulWidget {
  const MarketHeader({Key? key}) : super(key: key);

  @override
  State<MarketHeader> createState() => _MarketHeaderState();
}

class _MarketHeaderState extends State<MarketHeader> {
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(
        top: width * 0.04,
        left: width * 0.04,
        right: width * 0.04,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.sync_alt_rounded,
                  size: 25,
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 5),
                child: Text(
                  'BTC/USDT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  '+3.90%',
                  style: TextStyle(color: greenlightchartColor, fontSize: 12),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Icon(
                  Icons.candlestick_chart,
                  color: secondaryTextColor,
                  size: 20,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Icon(
                  Icons.monetization_on,
                  color: secondaryTextColor,
                  size: 20,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Icon(
                  Icons.more_horiz,
                  color: secondaryTextColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
