import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class BuySellTransactions extends StatefulWidget {
  static const routeName = '/buy_sell_transactions';
  const BuySellTransactions({Key? key}) : super(key: key);

  @override
  State<BuySellTransactions> createState() => _BuySellTransactionsState();
}

class _BuySellTransactionsState extends State<BuySellTransactions> {
  @override
  void initState() {
    getAllTransactions();
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> getAllTransactions() async {
    var payments = Provider.of<Payments>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);

    await payments.getAllTransactions(context, auth);
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var payments = Provider.of<Payments>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left),
        ),
        title: Text(
          'Transactions',
          style: TextStyle(fontStyle: FontStyle.normal, fontSize: 20),
        ),
      ),
      body: ListView.builder(
        itemCount: payments.allTransactions.length,
        itemBuilder: (context, index) {
          var transaction = payments.allTransactions[index];

          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: width * 0.4,
                      height: 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${transaction['txData']['from_currency']}',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                ' - ${transaction['txData']['to_currency']}',
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 10),
                                child: Text(
                                  'Amount:',
                                  style: TextStyle(
                                      fontSize: 15, color: secondaryTextColor),
                                ),
                              ),
                              Text(
                                '${double.parse(transaction['txData']['expected_from_amount']).toStringAsFixed(4)}',
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 10),
                                child: Text(
                                  'Price:',
                                  style: TextStyle(
                                      fontSize: 15, color: secondaryTextColor),
                                ),
                              ),
                              Text(
                                '${double.parse(transaction['txData']['expected_to_amount']).toStringAsFixed(4)}',
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '2020-05-67 12:30:67',
                          style: TextStyle(color: secondaryTextColor),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Text('Status: new'),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 2, bottom: 2),
                          child: Text('TxID: --'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}
