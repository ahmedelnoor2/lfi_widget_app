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
        SizedBox(
          width: width * 0.5,
          height: height * 0.1,
          child: Card(
            child: Center(
              child: Text('Buy Crypto'),
            ),
          ),
        ),
        SizedBox(
          width: width * 0.5,
          height: height * 0.1,
          child: Card(
            child: Center(
              child: Text('To Earn'),
            ),
          ),
        ),
      ],
    );
  }
}
