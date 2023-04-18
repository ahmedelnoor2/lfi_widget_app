import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/dex_provider.dart';
import 'package:lyotrade/providers/future_market.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/providers/loan_provider.dart';

import 'package:lyotrade/providers/notification_provider.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/referral.dart';
import 'package:lyotrade/providers/staking.dart';
import 'package:lyotrade/providers/topup.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/providers/trade_challenge.dart';
import 'package:lyotrade/providers/user.dart';
import 'package:lyotrade/providers/user_kyc.dart';
import 'package:lyotrade/screens/assets/assets.dart';
import 'package:lyotrade/screens/assets/deposit_assets.dart';
import 'package:lyotrade/screens/assets/digital_assets.dart';
import 'package:lyotrade/screens/assets/margin_assets.dart';
import 'package:lyotrade/screens/assets/asset_details.dart';
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
import 'package:lyotrade/screens/dashboard/announcement/announcement_details.dart';
import 'package:lyotrade/screens/dashboard/gift_card/buycard.dart';
import 'package:lyotrade/screens/dashboard/gift_card/gift_card.dart';
import 'package:lyotrade/screens/dashboard/gift_card/transaction_history.dart';
import 'package:lyotrade/screens/dashboard/market_search.dart';
import 'package:lyotrade/screens/dex_swap/dex_swap.dart';
import 'package:lyotrade/screens/future_trade/future_market_transaction.dart';
import 'package:lyotrade/screens/future_trade/future_trade.dart';
import 'package:lyotrade/screens/intro_screen/intro_screen.dart';
import 'package:lyotrade/screens/kyc/enitityverificatrion.dart';
import 'package:lyotrade/screens/kyc/kycscreen.dart';
import 'package:lyotrade/screens/kyc/perosmalvarification.dart';
import 'package:lyotrade/screens/language/choose_language.dart';
import 'package:lyotrade/screens/market/market.dart';
import 'package:lyotrade/screens/pix_payment/pix_payment.dart';
import 'package:lyotrade/screens/pix_payment/pix_payment_details.dart';
import 'package:lyotrade/screens/pix_payment/pix_process_payment.dart';
import 'package:lyotrade/screens/pix_payment/pix_transactions.dart';
import 'package:lyotrade/screens/referal/pages/leader_board.dart';
import 'package:lyotrade/screens/referal/referal_onvitationdetail.dart';
import 'package:lyotrade/screens/security/disable_account.dart';
import 'package:lyotrade/screens/notification/notifcationmessage.dart';
import 'package:lyotrade/screens/referal/referal.dart';
import 'package:lyotrade/screens/security/email_change.dart';
import 'package:lyotrade/screens/security/forgot/create_password.dart';
import 'package:lyotrade/screens/security/forgot/forgotpassword.dart';
import 'package:lyotrade/screens/security/google_auth.dart';
import 'package:lyotrade/screens/security/password.dart';
import 'package:lyotrade/screens/security/phone.dart';
import 'package:lyotrade/screens/security/security.dart';
import 'package:lyotrade/screens/setting/setting.dart';
import 'package:lyotrade/screens/splash_screen/splash.dart';
import 'package:lyotrade/screens/staking/common/stake_order.dart';
import 'package:lyotrade/screens/staking/stake.dart';
import 'package:lyotrade/screens/take_loan/confrim_loan.dart';
import 'package:lyotrade/screens/take_loan/process_loan.dart';
import 'package:lyotrade/screens/take_loan/take_loan.dart';
import 'package:lyotrade/screens/topup/topup.dart';
import 'package:lyotrade/screens/trade/kline_chart.dart';
import 'package:lyotrade/screens/trade/margin/margin_trade_history.dart';
import 'package:lyotrade/screens/trade/market_margin_header.dart';
import 'package:lyotrade/screens/trade/trade.dart';
import 'package:lyotrade/screens/trade/trade_history.dart';
import 'package:lyotrade/screens/trade_challenge/reward_center.dart';
import 'package:lyotrade/screens/trade_challenge/trade_challenge.dart';

import 'package:lyotrade/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/dashboard/gift_card/serviceprovider/giftcard-serviceprovider.dart';
import 'screens/pix_payment/pix_cpf_detail.dart';
import 'screens/dashboard/gift_card/gift_detail.dart';

int? initScreen;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  initScreen = await preferences.getInt('initScreen');
  await preferences.setInt('initScreen', 1);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top])
      .then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(create: (_) => Auth()),
        ChangeNotifierProvider<LanguageChange>(create: (_) => LanguageChange()),
        ChangeNotifierProvider<Public>(create: (_) => Public()),
        ChangeNotifierProvider<Asset>(create: (_) => Asset()),
        ChangeNotifierProvider<User>(create: (_) => User()),
        ChangeNotifierProvider<Trading>(create: (_) => Trading()),
        ChangeNotifierProvider<FutureMarket>(create: (_) => FutureMarket()),
        ChangeNotifierProvider<Staking>(create: (_) => Staking()),
        ChangeNotifierProvider<LoanProvider>(
          create: (_) => LoanProvider(),
        ),
        ChangeNotifierProvider<ReferralProvider>(
            create: (_) => ReferralProvider()),
        ChangeNotifierProvider<Payments>(create: (_) => Payments()),
        ChangeNotifierProvider<DexProvider>(create: (_) => DexProvider()),
        ChangeNotifierProvider<ReferralProvider>(
            create: (_) => ReferralProvider()),
        ChangeNotifierProvider<Notificationprovider>(
            create: (_) => Notificationprovider()),
        ChangeNotifierProvider<UserKyc>(create: (_) => UserKyc()),
        ChangeNotifierProvider<TradeChallenge>(
          create: (_) => TradeChallenge(),
        ),
        ChangeNotifierProvider<GiftCardProvider>(
          create: (_) => GiftCardProvider(),
        ),
        ChangeNotifierProvider<TopupProvider>(create: (_) => TopupProvider())
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'LYOTRADE',
            theme: lightThemeData,
            darkTheme: darkThemeData,
            themeMode: auth.thMode,
            home: initScreen == 0 || initScreen == null
                ? IntroScreen()
                : SpashScreen(),
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
              AssetDetails.routeName: (context) => const AssetDetails(),
              Security.routeName: (context) => const Security(),
              Phone.routeName: (context) => const Phone(),
              Password.routeName: (context) => const Password(),
              Forgotpassword.routeName: (context) => Forgotpassword(),
              GoogleAuth.routeName: (context) => const GoogleAuth(),
              EmailChange.routeName: (context) => const EmailChange(),
              Transactions.routeName: (context) => const Transactions(),
              KlineChart.routeName: (context) => const KlineChart(),
              DigitalAssets.routeName: (context) => const DigitalAssets(),
              MarginAssets.routeName: (context) => MarginAssets(),
              OtcAssets.routeName: (context) => const OtcAssets(),
              BuySellCrypto.routeName: (context) => const BuySellCrypto(),
              ConfirmLoan.routeName: (context) => const ConfirmLoan(),
              TakeLoan.routeName: (context) => const TakeLoan(),
              ProcessLoan.routeName: (context) => const ProcessLoan(),
              Referal.routeName: ((context) => Referal()),
              Kycscreen.routeName: ((context) => Kycscreen()),
              personalverification.routeName: (context) =>
                  personalverification(),
              EnitityVerification.routeName: ((context) =>
                  EnitityVerification()),
              Notificationsscreen.routeName: ((context) =>
                  const Notificationsscreen()),
              ProcessPayment.routeName: (context) => const ProcessPayment(),
              BuySellTransactions.routeName: (context) =>
                  const BuySellTransactions(),
              DexSwap.routeName: (context) => const DexSwap(),
              DisableAccount.routeName: (context) => const DisableAccount(),
              PixPayment.routeName: (context) => const PixPayment(),
              PixProcessPayment.routeName: (context) =>
                  const PixProcessPayment(),
              PixTransactions.routeName: (context) => const PixTransactions(),
              PixPaymentDetails.routeName: (context) =>
                  const PixPaymentDetails(),
              MarketSearch.routeName: (context) => const MarketSearch(),
              Refralinvitation.routeName: (context) => const Refralinvitation(),
              LeaderBoard.routeName: (context) => const LeaderBoard(),
              AnnouncementDetails.routeName: (context) =>
                  const AnnouncementDetails(),
              Createpassword.routeName: (context) => const Createpassword(),
              SpashScreen.routeName: (context) => const SpashScreen(),
              Setting.routeName: ((context) => const Setting()),
              FutureMarketTransaction.routeName: (context) =>
                  const FutureMarketTransaction(),
              GiftCardServiceProvider.routeName: (context) =>
                  GiftCardServiceProvider(),
              GiftCard.routeName: (context) => const GiftCard(),
              GiftDetail.routeName: (context) => GiftDetail(),
              GiftCardTransaction.routeName: (context) =>
                  const GiftCardTransaction(),
              BuyCard.routeName: (context) => BuyCard(),
              TopUp.routeNmame: (context) => const TopUp(),
              TradeChallengeScreen.routeName: (context) =>
                  const TradeChallengeScreen(),
              RewardCenterScreen.routeName: (context) =>
                  const RewardCenterScreen(),
              ChooseLanguage.routeName: (context) => ChooseLanguage()
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
