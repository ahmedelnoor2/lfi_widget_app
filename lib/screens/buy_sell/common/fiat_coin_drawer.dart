import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

import 'package:flutter_svg/flutter_svg.dart';

class FiatCoinDrawer extends StatefulWidget {
  const FiatCoinDrawer({
    Key? key,
    this.fiatController,
  }) : super(key: key);

  final fiatController;

  @override
  State<FiatCoinDrawer> createState() => _FiatCoinDrawerState();
}

class _FiatCoinDrawerState extends State<FiatCoinDrawer> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> changeFiatCoin(payments, currency) async {
    var auth = Provider.of<Auth>(context, listen: false);

    payments.setSelectedFiatCurrency(currency);

    Navigator.pop(context);
      print(payments.selectedCryptoCurrency['ticker']);
    await payments.getEstimateRate(context, auth, {
    
      'from_currency': payments.selectedFiatCurrency['ticker'],
      'from_amount': widget.fiatController.text,
      'to_currency': payments.selectedCryptoCurrency['current_ticker'],
      'to_network': payments.selectedCryptoCurrency['network'],
      'to_amount': '1',
      'source':'widget',
      'linkId':'38e0f8626aee4b'
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var payments = Provider.of<Payments>(context, listen: true);

    return Container(
      height: height,
      padding: EdgeInsets.only(
        top: 10,
        right: 10,
        left: 10,
        bottom: 30,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select a currency from',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  size: 20,
                ),
              )
            ],
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(10),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xff292C51),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  style: BorderStyle.solid,
                  width: 0.3,
                  color: Color(0xff5E6292),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 15),
                    child: Icon(
                      Icons.search,
                      size: 15,
                      color: secondaryTextColor,
                    ),
                  ),
                  SizedBox(
                    width: width * 0.75,
                    child: TextFormField(
                      onChanged: (val) {
                        payments.filterFiatSearchResults(val);
                      },
                      controller: _searchController,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 15,
                        ),
                        hintText: "Type a currency",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: payments.fiatSearchCurrencies.isNotEmpty
                  ? payments.fiatSearchCurrencies.length
                  : payments.fiatCurrencies.length,
              itemBuilder: (context, index) {
                var _fiatCurrency = payments.fiatSearchCurrencies.isNotEmpty
                    ? payments.fiatSearchCurrencies[index]
                    : payments.fiatCurrencies[index];

                return Column(
                  children: [
                    ListTile(
                      onTap: () async {
                        print(_fiatCurrency);
                        changeFiatCoin(payments, _fiatCurrency);
                      },
                      leading: CircleAvatar(
                        radius: 18,
                        child: SvgPicture.network(
                          '$changeNowApi${_fiatCurrency['icon']['url']}',
                          width: 50,
                        ),
                      ),
                      title: Text(
                        '${_fiatCurrency['ticker'].toUpperCase()}',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        '${_fiatCurrency['name']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
