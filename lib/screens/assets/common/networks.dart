import 'package:flutter/material.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

Widget networks(
  context,
  asset,
  allNetworks,
  defaultNetwork,
  changeCoinType,
) {
  return Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.close,
                color: secondaryTextColor,
                size: 20,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 70),
              child: const Text('Select Network'),
            ),
          ],
        ),
        asset.getCost['mainChainNameTip'] != null
            ? Text(
                '${asset.getCost['mainChainNameTip'].split('.')[asset.getCost['mainChainNameTip'].split('.').length - 1]}',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              )
            : Container(),
        Container(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            children: allNetworks
                .map<Widget>(
                  (netwrk) => GestureDetector(
                    onTap: () {
                      changeCoinType(netwrk);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${netwrk['mainChainName']}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.done,
                                size: 18,
                                color: netwrk['mainChainName'] == defaultNetwork
                                    ? greenBTNBGColor
                                    : secondaryTextColor,
                              ),
                            ],
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        )
      ],
    ),
  );
}
