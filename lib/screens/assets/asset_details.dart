import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';

class AssetDetails extends StatefulWidget {
  static const routeName = '/asset_details';
  const AssetDetails({Key? key}) : super(key: key);

  @override
  State<AssetDetails> createState() => _AssetDetailsState();
}

class _AssetDetailsState extends State<AssetDetails> {
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);
    var public = Provider.of<Public>(context, listen: true);
    var asset = Provider.of<Asset>(context, listen: true);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Container(
        padding: EdgeInsets.only(
          right: 15,
          left: 15,
          bottom: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 20),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.chevron_left),
                        ),
                      ),
                      Text(
                        '${public.publicInfoMarket['market']['coinList'][asset.selectedAsset['coin']]['longName']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: Container(
                width: width,
                padding: EdgeInsets.only(
                  bottom: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            'Balance',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Total',
                            style: TextStyle(
                                fontSize: 16, color: secondaryTextColor),
                          ),
                        ),
                        Text(
                          double.parse(
                                  '${asset.selectedAsset['values']['total_balance']}')
                              .toStringAsFixed(5),
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            '≈ ${getNumberFormat(
                              context,
                              public.rate[public.activeCurrency['fiat_symbol']
                                          .toUpperCase()][asset.accountBalance[
                                              asset.selectedAsset['coin']] ??
                                          'BTC'] !=
                                      null
                                  ? double.parse(asset.selectedAsset['values']['total_balance'] ?? '0') *
                                      public.rate[public
                                              .activeCurrency['fiat_symbol']
                                              .toUpperCase()]
                                          [asset.selectedAsset['coin']]
                                  : 0,
                            )}',
                            style: TextStyle(
                                fontSize: 16, color: secondaryTextColor),
                          ),
                        ),
                        Divider(),
                        Container(
                          padding: EdgeInsets.only(top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Available',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    double.parse(
                                            '${asset.selectedAsset['values']['normal_balance']}')
                                        .toStringAsFixed(5),
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Unavailalbe',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    double.parse(
                                            '${asset.selectedAsset['values']['lock_balance']}')
                                        .toStringAsFixed(5),
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(right: 5),
                              child: LyoButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/withdraw_assets',
                                  );
                                },
                                text: 'Withdraw',
                                active: true,
                                isLoading: false,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 5),
                              child: LyoButton(
                                onPressed: () {
                                  if (auth.userInfo['realAuthType'] == 0 ||
                                      auth.userInfo['authLevel'] == 0) {
                                    snackAlert(context, SnackTypes.warning,
                                        'Deposit limited (Please check KYC status)');
                                  } else {
                                    Navigator.pushNamed(
                                        context, '/deposit_assets');
                                  }
                                },
                                text: 'Deposit',
                                active: true,
                                activeColor: linkColor,
                                activeTextColor: Colors.black,
                                isLoading: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
