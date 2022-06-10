import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/staking.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class StakeOrder extends StatefulWidget {
  static const routeName = '/stake_order';
  const StakeOrder({Key? key}) : super(key: key);

  @override
  State<StakeOrder> createState() => _StakeOrderState();
}

class _StakeOrderState extends State<StakeOrder> {
  @override
  void initState() {
    getOrderDetails();
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> getOrderDetails() async {
    var staking = Provider.of<Staking>(context, listen: false);

    print(staking.activeStakingOrder);

    await staking.getOrderDetails(
      context,
      {
        'orderNum': staking.activeStakingOrder['orderNum'],
        'appKey': staking.activeStakingOrder['appKey'],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);
    var staking = Provider.of<Staking>(context, listen: true);
    print(staking.stakeOrderData);

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
                      padding: EdgeInsets.only(right: 20),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.chevron_left),
                      ),
                    ),
                    Text(
                      'Payment Confirmation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: width,
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Image.network(
                    '${public.publicInfoMarket['market']['coinList'][staking.stakeOrderData['payCoinSymbol']]['icon']}',
                  )
                ],
              ),
            ),
            Container(
              width: width,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coin',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${staking.stakeOrderData['showName']}',
                    style: TextStyle(fontSize: 20, color: linkColor),
                  ),
                ],
              ),
            ),
            Container(
              width: width,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Amount',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${staking.stakeOrderData['orderAmount']} ${staking.stakeOrderData['showName']}',
                    style: TextStyle(fontSize: 20, color: linkColor),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 15),
              width: width * 0.9,
              child: ElevatedButton(
                onPressed: true
                    ? () {
                        // if (_formStakeKey.currentState!.validate()) {
                        //   if (double.parse(_amountController.text) <=
                        //       0) {
                        //     showAlert(
                        //       context,
                        //       Icon(Icons.warning_amber),
                        //       'Form Error',
                        //       [Text('Amount is invalid')],
                        //       'Ok',
                        //     );
                        //   } else {
                        //     staking
                        //         .createStakingOrder(context, auth, {
                        //       'projectId': _activeStakeId,
                        //       'amount': double.parse(
                        //           _amountController.text),
                        //       'returnUrl':
                        //           'https://www.lyotrade.com/en_US/freeStaking/$_activeStakeId',
                        //     });
                        //   }
                        // }
                      }
                    : null,
                child: Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
