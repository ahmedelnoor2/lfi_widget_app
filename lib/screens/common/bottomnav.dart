import 'package:flutter/material.dart';

bottomNav(context) {
  var _currentRoute = ModalRoute.of(context)!.settings.name;

  return BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart),
        label: 'Markets',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.currency_exchange),
        label: 'Trade',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet),
        label: 'Assets',
      ),
    ],
    currentIndex: (_currentRoute == '/' || _currentRoute == '/dashboard')
        ? 0
        : _currentRoute == '/market'
            ? 1
            : _currentRoute == '/trade'
                ? 2
                : _currentRoute == '/assets'
                    ? 3
                    : 0,
    selectedItemColor: Colors.blue[400],
    unselectedItemColor: Colors.white60,
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
