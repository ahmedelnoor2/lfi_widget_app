import 'package:flutter/material.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';

class LatestListing extends StatefulWidget {
  const LatestListing({
    Key? key,
  }) : super(key: key);
  @override
  State<LatestListing> createState() => _LatestListingState();
}

class _LatestListingState extends State<LatestListing> {
  @override
  Widget build(BuildContext context) {
    var public = Provider.of<Public>(context, listen: true);
     var languageprovider = Provider.of<LanguageChange>(context, listen: true);

    // print(widget.listingSymbol);

    // print(getNumberString(
    //   context,
    //   public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()] != null
    //       ? public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()]
    //           ['LYO']
    //       : '0',
    // ));

    double _percentageChange = 0;

    if (public.listingSymbol.isNotEmpty) {
      _percentageChange =
          ((double.parse(public.listingSymbol['price']) - 1.22) /
              ((double.parse(public.listingSymbol['price']) + 1.22) / 2));
    }

    return InkWell(
      onTap: () {
        public.setActiveMarket(
            public.publicInfoMarket['market']['market']['USDT']['LYO1/USDT']);
        Navigator.pushNamed(context, '/kline_chart');
      },
      child: Container(
        padding: EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: <Color>[
                Color(0xff3F4374),
                Color(0xff292C51),
              ],
              tileMode: TileMode.mirror,
            ),
          ),
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 15),
                    child: CircleAvatar(
                      radius: 15,
                      child: Image.asset('assets/img/lyo.png'),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                     languageprovider.getlanguage['home']['credit_title']??   'LYO Credit',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: secondaryTextColor,
                        ),
                      ),
                      Text(
                        'LYO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Text(
                     languageprovider.getlanguage['home']['credit_price']??       'Price (USDT)',
                            style: TextStyle(
                              fontSize: 8,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                        Text(
                          getNumberString(
                            context,
                            public.listingSymbol.isNotEmpty
                                ? double.parse(public.listingSymbol['price'])
                                : 0,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Text(
                     languageprovider.getlanguage['home']['credit_listing']?? 'Since Listing (USDT)',
                          style: TextStyle(
                            fontSize: 8,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                      Text(
                        public.listingSymbol.isNotEmpty
                            ? _percentageChange > 0
                                ? '+${_percentageChange.toStringAsFixed(6)}'
                                : _percentageChange.toStringAsFixed(6)
                            : '0.000000',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: public.listingSymbol.isNotEmpty
                              ? _percentageChange > 0
                                  ? greenIndicator
                                  : errorColor
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
