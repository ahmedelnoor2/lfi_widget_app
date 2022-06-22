import 'package:flutter/material.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

Widget drawer(
  context,
  width,
  height,
  asset,
  public,
  searchController,
  getCoinCosts,
) {
  print(asset.allDigAsset);
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[850],
    ),
    width: width,
    child: Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 35),
          child: Row(
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
                child: const Text('Select Coin'),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          child: SizedBox(
            height: width * 0.13,
            child: TextField(
              onChanged: (value) async {
                await asset.filterSearchResults(value);
              },
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: height * 0.8,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: asset.allDigAsset.isNotEmpty
                ? asset.allDigAsset.length
                : asset.digitialAss.length,
            itemBuilder: (context, index) {
              var _asset = asset.allDigAsset.isNotEmpty
                  ? asset.allDigAsset[index]
                  : asset.digitialAss[index];

              return ListTile(
                onTap: () {
                  getCoinCosts(asset.allDigAsset.isNotEmpty
                      ? asset.allDigAsset[index]['coin']
                      : asset.digitialAss[index]['coin']);
                  searchController.clear();
                  asset.filterSearchResults('');
                  Navigator.pop(context);
                },
                leading: CircleAvatar(
                  radius: width * 0.035,
                  child: Image.network(
                    '${public.publicInfoMarket['market']['coinList'][_asset['coin']]['icon']}',
                  ),
                ),
                title: Text('${_asset['coin']}'),
                trailing: Text('${_asset['values']['total_balance']}'),
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget transferDrawer(
  context,
  width,
  height,
  selectedP2pAssets,
  p2pAccounts,
  public,
  selectP2pCoin,
) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[850],
    ),
    width: width,
    child: Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 35),
          child: Row(
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
                child: const Text('Select Coin'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height * 0.8,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: p2pAccounts.length,
            itemBuilder: (context, index) {
              var _account = p2pAccounts[index];

              return ListTile(
                onTap: () {
                  selectP2pCoin(_account);
                  Navigator.pop(context);
                },
                leading: CircleAvatar(
                  radius: width * 0.035,
                  child: Image.network(
                    '${public.publicInfoMarket['market']['coinList'][_account['coinSymbol']]['icon']}',
                  ),
                ),
                title: Text('${_account['coinSymbol']}'),
                trailing: Icon(
                  Icons.check,
                  color:
                      selectedP2pAssets['coinSymbol'] == _account['coinSymbol']
                          ? greenIndicator
                          : secondaryTextColor,
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
