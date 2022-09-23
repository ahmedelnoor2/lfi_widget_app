import 'dart:convert';

import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/screens/common/widget/loading_dialog.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class OnramperCryptoCoins extends StatefulWidget {
  const OnramperCryptoCoins({
    Key? key,
    required this.changeOnrampCrpto,
  }) : super(key: key);

  final Function changeOnrampCrpto;

  @override
  State<OnramperCryptoCoins> createState() => _OnramperCryptoCoinsState();
}

class _OnramperCryptoCoinsState extends State<OnramperCryptoCoins> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                      onChanged: ((value) {
                        payments.runCryptoFilter(value);
                      }),
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
              child: payments.onRampCryptoFoundList.isNotEmpty
                  ? Stack(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: payments.onRampCryptoFoundList.length,
                          itemBuilder: (context, index) {
                            var _cryptoCurrency =
                                payments.onRampCryptoFoundList[index];

                            return Column(
                              children: [
                                ListTile(
                                  onTap: () async {
                                    await payments
                                        .setSelectedOnrampCryptoCurrency(
                                            _cryptoCurrency);
                                    widget.changeOnrampCrpto();
                                    await payments
                                        .getOnrampEstimateRate(context, {
                                      "fromCurrency": payments
                                          .selectedOnrampFiatCurrency['code'],
                                      "toCurrency": payments
                                          .selectedOnrampCryptoCurrency['code'],
                                      "paymentMethod":
                                          payments.selectedpaymentmethod,
                                      "amount": payments.amount
                                    });
                                    Navigator.pop(context);
                                  },
                                  leading: ClipOval(
                                      child: Container(
                                    color: Colors.transparent,
                                    child: CachedMemoryImage(
                                      uniqueKey: _cryptoCurrency.toString(),
                                      base64: payments.onRamperDetails['icons']
                                              [_cryptoCurrency['code']]['icon']
                                          .split(',')[1]
                                          .replaceAll("\n", ""),
                                    ),
                                  )),
                                  title: Text(
                                    '${_cryptoCurrency['code'].toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${_cryptoCurrency['network'] ?? _cryptoCurrency['id']}',
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
                        payments.isLoadingEstimate
                            ? Center(
                              child: CircularProgressIndicator(),
                            )
                            : Container()
                      ],
                    )
                  : Align(
                      alignment: Alignment.topCenter,
                      child: const Text(
                        'No results found',
                        style: TextStyle(fontSize: 24),
                      ),
                    ))
        ],
      ),
    );
  }
}
