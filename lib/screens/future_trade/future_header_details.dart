import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/future_market.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class FutureHeaderDetails extends StatefulWidget {
  const FutureHeaderDetails({Key? key}) : super(key: key);

  @override
  State<FutureHeaderDetails> createState() => _FutureHeaderDetailsState();
}

class _FutureHeaderDetailsState extends State<FutureHeaderDetails> {
  String _filterType = '';

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: true);
    var futureMarket = Provider.of<FutureMarket>(context, listen: true);

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    auth.isAuthenticated
                        ? showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return marginMode(
                                    context,
                                    futureMarket,
                                    setState,
                                  );
                                },
                              );
                            },
                          )
                        : snackAlert(
                            context,
                            SnackTypes.warning,
                            'Login to trade',
                          );
                  },
                  child: Container(
                      padding: EdgeInsets.only(left: 4),
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
                        children: [
                          Text(
                            'Cross',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: secondaryTextColor,
                          ),
                        ],
                      )),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    // auth.isAuthenticated
                    //     ? showModalBottomSheet<void>(
                    //         context: context,
                    //         builder: (BuildContext context) {
                    //           return StatefulBuilder(
                    //             builder: (BuildContext context,
                    //                 StateSetter setState) {
                    //               return transferAsset(
                    //                 context,
                    //                 public,
                    //                 setState,
                    //               );
                    //             },
                    //           );
                    //         },
                    //       )
                    //     : Navigator.pushNamed(context, '/authentication');
                  },
                  child: Container(
                      padding: EdgeInsets.only(left: 4),
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
                        children: [
                          Text(
                            '100x',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: secondaryTextColor,
                          ),
                        ],
                      )),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    // auth.isAuthenticated
                    //     ? showModalBottomSheet<void>(
                    //         context: context,
                    //         builder: (BuildContext context) {
                    //           return StatefulBuilder(
                    //             builder: (BuildContext context,
                    //                 StateSetter setState) {
                    //               return transferAsset(
                    //                 context,
                    //                 public,
                    //                 setState,
                    //               );
                    //             },
                    //           );
                    //         },
                    //       )
                    //     : Navigator.pushNamed(context, '/authentication');
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 4,
                      bottom: 4,
                      left: 6,
                      right: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xff292C51),
                      ),
                      color: Color(0xff292C51),
                      borderRadius: BorderRadius.all(
                        Radius.circular(2),
                      ),
                    ),
                    child: Text(
                      'N',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Funding / Countdown',
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryTextColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
                Text(
                  '0.0069%/03:12:30',
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget marginMode(context, futureMarket, setState) {
    height = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(10),
      height: height * 0.65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Margin Mode',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  size: 20,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
