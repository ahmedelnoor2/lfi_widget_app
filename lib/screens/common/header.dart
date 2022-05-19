import 'package:flutter/material.dart';
import 'package:lyotrade/screens/assets/deposit_assets.dart';
import 'package:lyotrade/screens/assets/withdraw_assets.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';

Widget headerImage() {
  return const Image(
    image: AssetImage('assets/img/logo.png'),
    width: 150,
  );
}

appBar(context, _handleDrawer) {
  var _currentRoute = ModalRoute.of(context)!.settings.name;

  return AppBar(
    leading: IconButton(
      icon: (_currentRoute == '/' || _currentRoute == '/dashboard')
          ? const Icon(Icons.account_circle)
          : const Icon(Icons.chevron_left),
      onPressed: () {
        if (_currentRoute == '/' || _currentRoute == '/dashboard') {
          _handleDrawer();
        } else {
          Navigator.pop(context);
        }
      },
    ),
    title: headerImage(),
    elevation: 0,
    shadowColor: Colors.transparent,
    actions: (_currentRoute == DepositAssets.routeName ||
            _currentRoute == WithdrawAssets.routeName)
        ? [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.list_alt),
            )
          ]
        : [],
  );
}

Widget assetsBar(
  context,
  auth,
  width,
  innerBoxIsScrolled,
  tabController,
  accountBalance,
  public,
  totalAccountBalance,
) {
  return SliverAppBar(
    toolbarHeight: width * 0.2,
    leading: Container(),
    leadingWidth: 0,
    title: Container(
      padding: EdgeInsets.zero,
      // width: width,
      height: width * 0.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Assets in ${accountBalance['totalBalanceSymbol'] ?? '0'}',
            style: TextStyle(
              fontSize: 12,
              color: secondaryTextColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '≈ ${totalAccountBalance['totalbalance'] ?? '0'}',
                style: const TextStyle(fontSize: 15),
              ),
              Container(
                padding: EdgeInsets.only(left: width * 0.02),
                child: Text(
                  '≈${getNumberFormat(
                    context,
                    public.rate[public.activeCurrency['fiat_symbol']
                                    .toUpperCase()]
                                [accountBalance['totalBalanceSymbol']] !=
                            null
                        ? '${double.parse(totalAccountBalance['totalbalance'] ?? '0') * public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()][accountBalance['totalBalanceSymbol']]}'
                        : '0',
                  )}',
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 25,
                padding: EdgeInsets.only(right: width * 0.01),
                child: OutlinedButton(
                  onPressed: () {
                    if (auth.userInfo['realAuthType'] != null) {
                      if (auth.userInfo['realAuthType'] == 0) {
                        snackAlert(
                          context,
                          SnackTypes.warning,
                          'Please verify your kyc to access deposits',
                        );
                      } else {
                        Navigator.pushNamed(context, '/deposit_assets');
                      }
                    }
                  },
                  child: Row(
                    children: const [
                      Icon(
                        Icons.arrow_downward,
                        size: 11,
                      ),
                      Text(
                        'Deposit',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 25,
                padding: EdgeInsets.only(right: width * 0.01),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/withdraw_assets');
                  },
                  child: Row(
                    children: const [
                      Icon(
                        Icons.arrow_upward,
                        size: 11,
                      ),
                      Text(
                        'Withdraw',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 25,
                padding: EdgeInsets.only(right: width * 0.03),
                child: OutlinedButton(
                  onPressed: () {
                    debugPrint('Received click');
                  },
                  child: Row(
                    children: const [
                      Icon(
                        Icons.currency_exchange,
                        size: 11,
                      ),
                      Text(
                        'Transfer',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    actions: [
      Container(
        padding: EdgeInsets.only(
          right: width * 0.02,
          bottom: width * 0.06,
        ),
        child: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.remove_red_eye,
            size: width * 0.04,
          ),
        ),
      ),
    ],
    pinned: true,
    floating: true,
    centerTitle: false,
    forceElevated: innerBoxIsScrolled,
    bottom: TabBar(
      tabs: <Tab>[
        Tab(text: 'Digital'),
        Tab(text: 'P2P'),
        Tab(text: 'Margin'),
      ],
      controller: tabController,
    ),
  );
}
