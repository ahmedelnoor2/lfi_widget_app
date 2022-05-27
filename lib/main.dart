import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/providers/user.dart';
import 'package:lyotrade/screens/assets/assets.dart';
import 'package:lyotrade/screens/assets/deposit_assets.dart';
import 'package:lyotrade/screens/assets/transactions.dart';
import 'package:lyotrade/screens/assets/withdraw_assets.dart';
import 'package:lyotrade/screens/auth/authentication.dart';
import 'package:lyotrade/screens/dashboard.dart';
import 'package:lyotrade/screens/future_trade/future_trade.dart';
import 'package:lyotrade/screens/market/market.dart';
import 'package:lyotrade/screens/security/email_change.dart';
import 'package:lyotrade/screens/security/google_auth.dart';
import 'package:lyotrade/screens/security/password.dart';
import 'package:lyotrade/screens/security/security.dart';
import 'package:lyotrade/screens/trade/kline_chart.dart';
import 'package:lyotrade/screens/trade/trade.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(create: (_) => Auth()),
        ChangeNotifierProvider<Public>(create: (_) => Public()),
        ChangeNotifierProvider<Asset>(create: (_) => Asset()),
        ChangeNotifierProvider<User>(create: (_) => User()),
        ChangeNotifierProvider<Trading>(create: (_) => Trading()),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'LYOTRADE',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              brightness: Brightness.dark,
              appBarTheme: AppBarTheme(
                backgroundColor: Color.fromARGB(255, 26, 29, 63),
              ),
              fontFamily: 'Yantramanav',
              // bottomAppBarTheme: BottomAppBarTheme(
              //   color: Color.fromARGB(255, 26, 29, 63),
              // ),
              // bottomAppBarColor: Color.fromARGB(255, 26, 29, 63),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Color.fromARGB(255, 26, 29, 63),
                selectedItemColor: Color.fromARGB(255, 1, 254, 246),
                unselectedItemColor: secondaryTextColor,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
              ),
              primarySwatch:
                  createMaterialColor(Color.fromARGB(255, 1, 254, 246)),
              scaffoldBackgroundColor: Color.fromARGB(255, 26, 29, 63),
              backgroundColor: Color.fromARGB(255, 26, 29, 63),
              textTheme: TextTheme(
                headline1: TextStyle(
                    fontSize: 72.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                headline2: TextStyle(color: Colors.white),
                headline3: TextStyle(color: Colors.white),
                headline4: TextStyle(color: Colors.white),
                headline5: TextStyle(color: Colors.white),
                headline6: TextStyle(
                    fontSize: 36.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white),
                bodyText2: TextStyle(color: Colors.white),
                bodyText1: TextStyle(color: Colors.white),
                subtitle1: TextStyle(color: Colors.white),
                caption: TextStyle(color: secondaryTextColor),
                button: TextStyle(color: Colors.white),
                overline: TextStyle(color: Colors.white),
              ),
              drawerTheme: DrawerThemeData(
                backgroundColor: Color.fromARGB(255, 26, 29, 63),
              ),
              cardTheme: CardTheme(
                color: Color.fromARGB(255, 41, 44, 81),
              ),
              iconTheme: IconThemeData().copyWith(color: Colors.white),
              primaryIconTheme: IconThemeData().copyWith(color: Colors.white),
              inputDecorationTheme: InputDecorationTheme(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: secondaryTextColor,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 1, 254, 246),
                  ),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 1, 254, 246),
                  ),
                ),
                labelStyle: TextStyle(color: Colors.white),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(0, 32),
                  textStyle: TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // darkTheme: ThemeData.dark(),
            // themeMode: ThemeMode.dark,
            home: const Dashboard(),
            routes: {
              Dashboard.routeName: (context) => const Dashboard(),
              Authentication.routeName: (context) => const Authentication(),
              Market.routeName: (context) => const Market(),
              Trade.routeName: (context) => const Trade(),
              FutureTrade.routeName: (context) => const FutureTrade(),
              Assets.routeName: (context) => const Assets(),
              DepositAssets.routeName: (context) => const DepositAssets(),
              WithdrawAssets.routeName: (context) => const WithdrawAssets(),
              Security.routeName: (context) => const Security(),
              Password.routeName: (context) => const Password(),
              GoogleAuth.routeName: (context) => const GoogleAuth(),
              EmailChange.routeName: (context) => const EmailChange(),
              Transactions.routeName: (context) => const Transactions(),
              KlineChart.routeName: (context) => const KlineChart(),
            },
          );
        },
      ),
    );
  }
}
