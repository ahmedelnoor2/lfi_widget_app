import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

class Transactions extends StatefulWidget {
  static const routeName = '/transactions';
  const Transactions({Key? key, this.txtype}) : super(key: key);

  final txtype;

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, null),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_off,
              size: 80,
              color: secondaryTextColor,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Text(
                'No Data',
                style: TextStyle(
                  color: secondaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
