import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class PixTransactions extends StatefulWidget {
  static const routeName = '/pix_transactions';
  const PixTransactions({Key? key}) : super(key: key);

  @override
  State<PixTransactions> createState() => _PixTransactionsState();
}

class _PixTransactionsState extends State<PixTransactions>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> getAllClientTransaction() async {
    var payments = Provider.of<Payments>(context, listen: false);
    await payments.getAllPixTransactions(payments.pixKycClients['client_uuid']);
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var payments = Provider.of<Payments>(context, listen: true);

    var allTransactions = [];
    if (payments.allPixTransactions.isNotEmpty) {
      allTransactions = List.from(payments.allPixTransactions.reversed);
    }

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.chevron_left),
                      ),
                    ),
                    Text(
                      'BRL Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: height * 0.85,
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider();
                },
                padding: EdgeInsets.zero,
                itemCount: payments.allPixTransactions.length,
                itemBuilder: (BuildContext context, int index) {
                  var transaction = allTransactions[index];
                  return ListTile(
                    title: Text(
                      'BRL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('yyy-mm-dd hh:mm:ss')
                          .format(DateTime.parse('${transaction['date_end']}')),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '${transaction['value']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${transaction['status']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: transaction['status'] == 'ACCEPTED'
                                ? successColor
                                : transaction['status'] == 'PROCESSING'
                                    ? warningColor
                                    : errorColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
