import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/assets/assets.dart';
import 'package:lyotrade/screens/auth/authentication.dart';
import 'package:lyotrade/screens/dashboard.dart';
import 'package:lyotrade/screens/future_trade/future_trade.dart';
import 'package:lyotrade/screens/market/market.dart';
import 'package:lyotrade/screens/trade/trade.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

bottomNav(context, auth) {
  var _currentRoute = ModalRoute.of(context)!.settings.name;
  var public = Provider.of<Public>(context, listen: false);
  var languageprovider = Provider.of<LanguageChange>(context, listen: true);

  return BottomNavigationBar(
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/img/bottom_bar/${(_currentRoute == '/' || _currentRoute == '/dashboard') ? 'home_active' : 'home'}.png',
          width: 24,
        ),
        label: languageprovider.getlanguage['navbar'][0] ?? 'Home',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/img/bottom_bar/${(_currentRoute == '/market') ? 'market_active' : 'market'}.png',
          width: 24,
        ),
        label: languageprovider.getlanguage['navbar'][1] ?? 'Markets',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/img/bottom_bar/${(_currentRoute == '/trade') ? 'trade_active' : 'trade'}.png',
          width: 24,
        ),
        label: languageprovider.getlanguage['navbar'][2] ?? 'Trade',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/img/bottom_bar/${(_currentRoute == '/future_trade') ? 'future_active' : 'future'}.png',
          width: 24,
        ),
        label: languageprovider.getlanguage['navbar'][3] ?? 'Futures',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/img/bottom_bar/${(_currentRoute == '/assets') ? 'asset_active' : 'asset'}.png',
          width: 24,
        ),
        label: languageprovider.getlanguage['navbar'][4] ?? 'Assets',
      ),
    ],
    currentIndex: (_currentRoute == '/' || _currentRoute == '/dashboard')
        ? 0
        : _currentRoute == '/market'
            ? 1
            : _currentRoute == '/trade'
                ? 2
                : _currentRoute == '/future_trade'
                    ? 3
                    : _currentRoute == '/assets'
                        ? 4
                        : 0,
    // selectedItemColor: Colors.blue[400],
    // unselectedItemColor: Colors.white60,
    // backgroundColor: Colors.black,
    onTap: (value) {
      switch (value) {
        case 0:
          public.vibrateOn();
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: Dashboard.routeName),
              pageBuilder: (context, animation1, animation2) => Dashboard(),
              transitionDuration: Duration(seconds: 0),
            ),
          );
          break;
        case 1:
          public.vibrateOn();
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: Market.routeName),
              pageBuilder: (context, animation1, animation2) => Market(),
              transitionDuration: Duration(seconds: 0),
            ),
          );
          break;
        case 2:
          public.vibrateOn();
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: Trade.routeName),
              pageBuilder: (context, animation1, animation2) => Trade(
                tradeType: null,
              ),
              transitionDuration: Duration(seconds: 0),
            ),
          );
          break;
        case 3:
          public.vibrateOn();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/future_trade',
            (route) => false,
          );
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: FutureTrade.routeName),
              pageBuilder: (context, animation1, animation2) => FutureTrade(),
              transitionDuration: Duration(seconds: 0),
            ),
          );
          break;
        case 4:
          public.vibrateOn();
          auth.isAuthenticated
              ? Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    settings: RouteSettings(name: Assets.routeName),
                    pageBuilder: (context, animation1, animation2) => Assets(),
                    transitionDuration: Duration(seconds: 0),
                  ),
                )
              : Navigator.push(
                  context,
                  PageRouteBuilder(
                    settings: RouteSettings(name: Authentication.routeName),
                    pageBuilder: (context, animation1, animation2) =>
                        Authentication(),
                    transitionDuration: Duration(seconds: 0),
                  ),
                );
          break;
        default:
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
          break;
      }
    },
  );
}
