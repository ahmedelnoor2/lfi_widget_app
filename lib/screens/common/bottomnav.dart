import 'package:flutter/material.dart';

bottomNav(context) {
  var _currentRoute = ModalRoute.of(context)!.settings.name;

  return BottomNavigationBar(
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/img/bottom_bar/${(_currentRoute == '/' || _currentRoute == '/dashboard') ? 'home_active' : 'home'}.png',
          width: 24,
        ),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/img/bottom_bar/${(_currentRoute == '/market') ? 'market_active' : 'market'}.png',
          width: 24,
        ),
        label: 'Markets',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/img/bottom_bar/${(_currentRoute == '/trade') ? 'trade_active' : 'trade'}.png',
          width: 24,
        ),
        label: 'Trade',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/img/bottom_bar/${(_currentRoute == '/future_trade') ? 'future_active' : 'future'}.png',
          width: 24,
        ),
        label: 'Futures',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/img/bottom_bar/${(_currentRoute == '/assets') ? 'asset_active' : 'asset'}.png',
          width: 24,
        ),
        label: 'Assets',
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
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
          break;
        case 1:
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/market',
            (route) => false,
          );
          break;
        case 2:
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/trade',
            (route) => false,
          );
          break;
        case 3:
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/future_trade',
            (route) => false,
          );
          break;
        case 4:
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/assets',
            (route) => false,
          );
          break;
        default:
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
          break;
      }
    },
  );
}
