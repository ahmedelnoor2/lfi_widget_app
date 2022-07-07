import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/dex_provider.dart';
import 'package:lyotrade/providers/future_market.dart';
import 'package:lyotrade/providers/loan_provider.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/staking.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/providers/user.dart';
import 'package:lyotrade/screens/assets/assets.dart';
import 'package:lyotrade/screens/assets/deposit_assets.dart';
import 'package:lyotrade/screens/assets/digital_assets.dart';
import 'package:lyotrade/screens/assets/margin_assets.dart';
import 'package:lyotrade/screens/assets/margin_transactions.dart';
import 'package:lyotrade/screens/assets/otc_assets.dart';
import 'package:lyotrade/screens/assets/p2p_transactions.dart';
import 'package:lyotrade/screens/assets/transaction_details.dart';
import 'package:lyotrade/screens/assets/transactions.dart';
import 'package:lyotrade/screens/assets/transfer_assets.dart';
import 'package:lyotrade/screens/assets/withdraw_assets.dart';
import 'package:lyotrade/screens/auth/authentication.dart';
import 'package:lyotrade/screens/buy_sell/buy_sell_crypto.dart';
import 'package:lyotrade/screens/buy_sell/buy_sell_transactions.dart';
import 'package:lyotrade/screens/buy_sell/common/process_payment.dart';
import 'package:lyotrade/screens/dashboard.dart';
import 'package:lyotrade/screens/dex_swap/dex_swap.dart';
import 'package:lyotrade/screens/future_trade/future_trade.dart';
import 'package:lyotrade/screens/market/market.dart';
import 'package:lyotrade/screens/security/email_change.dart';
import 'package:lyotrade/screens/security/google_auth.dart';
import 'package:lyotrade/screens/security/password.dart';
import 'package:lyotrade/screens/security/phone.dart';
import 'package:lyotrade/screens/security/security.dart';
import 'package:lyotrade/screens/staking/common/stake_order.dart';
import 'package:lyotrade/screens/staking/stake.dart';
import 'package:lyotrade/screens/take_loan/take_loan.dart';
import 'package:lyotrade/screens/trade/kline_chart.dart';
import 'package:lyotrade/screens/trade/margin/margin_trade_history.dart';
import 'package:lyotrade/screens/trade/trade.dart';
import 'package:lyotrade/screens/trade/trade_history.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top]).then((_) => runApp(const MyApp()));
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    double _letterSpacing = 0.3;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(create: (_) => Auth()),
        ChangeNotifierProvider<Public>(create: (_) => Public()),
        ChangeNotifierProvider<Asset>(create: (_) => Asset()),
        ChangeNotifierProvider<User>(create: (_) => User()),
        ChangeNotifierProvider<Trading>(create: (_) => Trading()),
        ChangeNotifierProvider<FutureMarket>(create: (_) => FutureMarket()),
        ChangeNotifierProvider<Staking>(create: (_) => Staking()),
        ChangeNotifierProvider<LoanProvider>(create: (_) => LoanProvider()),
        ChangeNotifierProvider<Payments>(create: (_) => Payments()),
        ChangeNotifierProvider<DexProvider>(create: (_) => DexProvider()),
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
              // pageTransitionsTheme: PageTransitionsTheme(
              //   builders: {
              //     TargetPlatform.android: NoTransitionsBuilder(),
              //     TargetPlatform.iOS: NoTransitionsBuilder(),
              //   },
              // ),
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
              bottomSheetTheme: BottomSheetThemeData(
                backgroundColor: Color.fromARGB(255, 26, 29, 63),
              ),
              primarySwatch:
                  createMaterialColor(Color.fromARGB(255, 1, 254, 246)),
              scaffoldBackgroundColor: Color.fromARGB(255, 26, 29, 63),
              backgroundColor: Color.fromARGB(255, 26, 29, 63),
              textTheme: TextTheme(
                headline1: TextStyle(
                    fontSize: 72.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: _letterSpacing,
                    color: Colors.white),
                headline2: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                headline3: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                headline4: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                headline5: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                headline6: TextStyle(
                  fontSize: 36.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                bodyText2: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                bodyText1: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                subtitle1: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                caption: TextStyle(
                  color: secondaryTextColor,
                  letterSpacing: _letterSpacing,
                ),
                button: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                overline: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
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
                  // enabledBorder: UnderlineInputBorder(
                  //   borderSide: BorderSide(
                  //     color: secondaryTextColor,
                  //   ),
                  // ),
                  // focusedBorder: UnderlineInputBorder(
                  //   borderSide: BorderSide(
                  //     color: Color.fromARGB(255, 1, 254, 246),
                  //   ),
                  // ),
                  // border: UnderlineInputBorder(
                  //   borderSide: BorderSide(
                  //     color: Color.fromARGB(255, 1, 254, 246),
                  //   ),
                  // ),
                  // labelStyle: TextStyle(color: Colors.white),
                  ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(0, 35),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
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
              Stake.routeName: (context) => const Stake(),
              StakeOrder.routeName: (context) => const StakeOrder(),
              TradeHistory.routeName: (context) => const TradeHistory(),
              MarginTradeHistory.routeName: (context) =>
                  const MarginTradeHistory(),
              TransactionDetails.routeName: (context) =>
                  const TransactionDetails(),
              P2pTransactions.routeName: (context) => const P2pTransactions(),
              MarginTransactions.routeName: (context) =>
                  const MarginTransactions(),
              FutureTrade.routeName: (context) => const FutureTrade(),
              Assets.routeName: (context) => const Assets(),
              DepositAssets.routeName: (context) => const DepositAssets(),
              WithdrawAssets.routeName: (context) => const WithdrawAssets(),
              TransferAssets.routeName: (context) => const TransferAssets(),
              Security.routeName: (context) => const Security(),
              Phone.routeName: (context) => const Phone(),
              Password.routeName: (context) => const Password(),
              GoogleAuth.routeName: (context) => const GoogleAuth(),
              EmailChange.routeName: (context) => const EmailChange(),
              Transactions.routeName: (context) => const Transactions(),
              KlineChart.routeName: (context) => const KlineChart(),
              DigitalAssets.routeName: (context) => const DigitalAssets(),
              MarginAssets.routeName: (context) => const MarginAssets(),
              OtcAssets.routeName: (context) => const OtcAssets(),
              BuySellCrypto.routeName: (context) => const BuySellCrypto(),
              TakeLoan.routeName: (context) => const TakeLoan(),
              ProcessPayment.routeName: (context) => const ProcessPayment(),
              BuySellTransactions.routeName: (context) =>
                  const BuySellTransactions(),
              DexSwap.routeName: (context) => const DexSwap(),
            },
          );
        },
      ),
    );
  }
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    // only return the child without warping it with animations
    return child!;
  }
}
