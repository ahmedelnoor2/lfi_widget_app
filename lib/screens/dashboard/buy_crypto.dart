import 'package:flutter/material.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

class BuyCrypto extends StatefulWidget {
  const BuyCrypto({Key? key}) : super(key: key);

  @override
  State<BuyCrypto> createState() => _BuyCryptoState();
}

class _BuyCryptoState extends State<BuyCrypto> {
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {},
          child: SizedBox(
            width: width * 0.325,
            height: height * 0.12,
            child: Card(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Image.asset(
                        'assets/img/buy_crypto.png',
                        width: 24,
                      ),
                    ),
                    Text(
                      'Buy Crypto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'SEPA, VISA, MC',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: SizedBox(
            width: width * 0.325,
            height: height * 0.12,
            child: Card(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Image.asset(
                        'assets/img/deposit.png',
                        width: 24,
                      ),
                    ),
                    Text(
                      'Deposit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'BTC, ETH, LYO',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            print('hit');
          },
          child: SizedBox(
            width: width * 0.32,
            height: height * 0.12,
            child: Card(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Image.asset(
                        'assets/img/earn.png',
                        width: 24,
                      ),
                    ),
                    Text(
                      'To Earn',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'APY up to 72%!',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
