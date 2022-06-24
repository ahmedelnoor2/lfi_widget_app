import 'package:flutter/material.dart';
import 'package:lyotrade/providers/loan_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:provider/provider.dart';

class TakeLoan extends StatefulWidget {
  static const routeName = '/crypto_loan';
  const TakeLoan({Key? key}) : super(key: key);

  @override
  State<TakeLoan> createState() => _TakeLoanState();
}

class _TakeLoanState extends State<TakeLoan> {
  @override
  void initState() {
    getCurrencies();
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> getCurrencies() async {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);
    await loanProvider.getCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);
    // print(loanProvider.currencies);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 10),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.chevron_left),
                      ),
                    ),
                    Text(
                      'Borrow Against Crypto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.history),
                )
              ],
            ),
            Text('Loan'),
          ],
        ),
      ),
    );
  }
}
