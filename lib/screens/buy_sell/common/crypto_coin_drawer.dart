import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class CryptoCoinDrawer extends StatefulWidget {
  const CryptoCoinDrawer({
    Key? key,
    this.fiatController,
    this.getDigitalBalance,
  }) : super(key: key);

  final fiatController;
  final getDigitalBalance;

  @override
  State<CryptoCoinDrawer> createState() => _CryptoCoinDrawerState();
}

class _CryptoCoinDrawerState extends State<CryptoCoinDrawer> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> changeCryptoCoin(payments, currency) async {
    var auth = Provider.of<Auth>(context, listen: false);

    payments.setSelectedCryptoCurrency(currency);
    Navigator.pop(context);
    await payments.getEstimateRate(context, auth, {
      'from_currency': payments.selectedFiatCurrency['ticker'],
      'from_amount': widget.fiatController.text,
      'to_currency': payments.selectedCryptoCurrency['current_ticker'],
      'to_network': payments.selectedCryptoCurrency['network'],
      'to_amount': '1',
    });
    widget.getDigitalBalance();
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
                        payments.filterSearchResults(
                            val, payments.cryptoCurrencies);
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
          SizedBox(
            height: height * 0.72,
            child: ListView.builder(
              // shrinkWrap: true,
              itemCount: payments.cryptoSearchCurrencies.isNotEmpty
                  ? payments.cryptoSearchCurrencies.length
                  : payments.cryptoCurrencies.length,
              itemBuilder: (context, index) {
                var _cryptoCurrency = payments.cryptoSearchCurrencies[index];

                return Column(
                  children: [
                    ListTile(
                      onTap: () async {
                        changeCryptoCoin(payments, _cryptoCurrency);
                      },
                      leading: CircleAvatar(
                        radius: 18,
                        child: SvgPicture.network(
                          '$changeNowApi${_cryptoCurrency['icon']['url']}',
                          width: 50,
                        ),
                      ),
                      title: Text(
                        '${_cryptoCurrency['current_ticker'].toUpperCase()}',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        '${_cryptoCurrency['name']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                      trailing: Container(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 65, 68, 111),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              style: BorderStyle.solid,
                              width: 0.3,
                              color: Color(0xff5E6292),
                            ),
                          ),
                          child: Text(
                            '${_cryptoCurrency['link'].split('-').last.toUpperCase()}',
                            style: TextStyle(
                              color: secondaryTextColor,
                            ),
                          ),
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
