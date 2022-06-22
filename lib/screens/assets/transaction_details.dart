import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/header.dart';

class TransactionDetails extends StatefulWidget {
  static const routeName = '/transaction_details';
  const TransactionDetails({Key? key}) : super(key: key);

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hiddenAppBar(),
      body: Container(
        padding: EdgeInsets.only(
          bottom: 15,
          left: 15,
          right: 15,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.chevron_left),
                    ),
                    Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.remove_red_eye),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Divider(),
            ),
          ],
        ),
      ),
    );
  }
}
