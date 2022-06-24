import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lyotrade/providers/dex_provider.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class ExchangeNow extends StatefulWidget {
  const ExchangeNow({Key? key}) : super(key: key);

  @override
  State<ExchangeNow> createState() => _ExchangeNowState();
}

class _ExchangeNowState extends State<ExchangeNow> {
  bool _loadingCoins = false;

  @override
  Widget build(BuildContext context) {
    var dexProvider = Provider.of<DexProvider>(context, listen: true);

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 20),
            child: InkWell(
              onTap: () {
                // _selectedToAccount == 'Margin Account'
                //     ? showModalBottomSheet<void>(
                //         context: context,
                //         builder: (BuildContext context) {
                //           return selectCoin(context, public);
                //         },
                //       )
                //     : _scaffoldKey.currentState!.openDrawer();
              },
              child: Container(
                padding:
                    EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    width: 0.3,
                    color: Color(0xff5E6292),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: CircleAvatar(
                            radius: 12,
                            child: dexProvider.fromActiveCurrency.isNotEmpty
                                ? SvgPicture.network(
                                    '${dexProvider.fromActiveCurrency['image']}',
                                    width: 50,
                                  )
                                : Container(),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text(
                            dexProvider.fromActiveCurrency.isNotEmpty
                                ? dexProvider.fromActiveCurrency['ticker']
                                    .toUpperCase()
                                : '--',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          dexProvider.fromActiveCurrency.isNotEmpty
                              ? dexProvider.fromActiveCurrency['name']
                              : '--',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                dexProvider.swapFromAndTo();
              },
              icon: Image.asset(
                'assets/img/transfer.png',
                width: 32,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              // _selectedToAccount == 'Margin Account'
              //     ? showModalBottomSheet<void>(
              //         context: context,
              //         builder: (BuildContext context) {
              //           return selectCoin(context, public);
              //         },
              //       )
              //     : _scaffoldKey.currentState!.openDrawer();
            },
            child: Container(
              padding:
                  EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  width: 0.3,
                  color: Color(0xff5E6292),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: CircleAvatar(
                          radius: 12,
                          child: dexProvider.toActiveCurrency.isNotEmpty
                              ? SvgPicture.network(
                                  '${dexProvider.toActiveCurrency['image']}',
                                  width: 50,
                                )
                              : Container(),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 5),
                        child: Text(
                          dexProvider.fromActiveCurrency.isNotEmpty
                              ? dexProvider.toActiveCurrency['ticker']
                                  .toUpperCase()
                              : '--',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        dexProvider.fromActiveCurrency.isNotEmpty
                            ? dexProvider.fromActiveCurrency['name']
                            : '--',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.info,
                          size: 18,
                        ),
                      ),
                    ),
                    Text('Exchange rate (expected)'),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '1 BTC ~ 212209.99 USDT',
                      style: TextStyle(color: linkColor),
                    ),
                  ],
                )
              ],
            ),
          ),
          InkWell(
            onTap: _loadingCoins
                ? null
                : () {
                    // processBuy();
                    snackAlert(context, SnackTypes.warning, 'Coming Soon...');
                  },
            child: Container(
              width: width,
              padding: EdgeInsets.only(
                top: 10,
                bottom: 30,
              ),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // color: Color(0xff5E6292),
                  color:
                      (_loadingCoins) ? Color(0xff292C51) : Color(0xff5E6292),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    // style: BorderStyle.solid,
                    width: 0,
                    // color: Color(0xff5E6292),
                    color:
                        _loadingCoins ? Colors.transparent : Color(0xff5E6292),
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: (_loadingCoins)
                      ? SizedBox(
                          child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2),
                          height: 25,
                          width: 25,
                        )
                      : Text(
                          'SWAP Now',
                          style: TextStyle(
                            fontSize: 20,
                            color: (_loadingCoins)
                                ? secondaryTextColor
                                : Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
