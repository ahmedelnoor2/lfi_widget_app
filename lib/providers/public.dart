import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/utils/AppConstant.utils.dart';

class Public with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
  };

  Map _rate = {};
  Map _publicInfoMarket = {};
  List _currencies = [];
  Map _activeCurrency = {
    "fiat_symbol": "usd",
    "icon": "/upload/aa.jpg",
    "fiat_icon": "\$",
  };
  List _headerSymbols = [];

  Map get rate {
    return _rate;
  }

  Map get activeCurrency {
    return _activeCurrency;
  }

  List get currencies {
    return _currencies;
  }

  Map get publicInfoMarket {
    return _publicInfoMarket;
  }

  List get headerSymbols {
    return _headerSymbols;
  }

  Future<void> setHeaderSymbols(headerSymb) async {
    _headerSymbols = headerSymb;
    return notifyListeners();
  }

  Future<void> changeCurrency(fiatSymbol) async {
    _activeCurrency = _currencies.firstWhere(
      (currency) => currency['fiat_symbol'] == fiatSymbol,
    );
    return notifyListeners();
  }

  Future<void> getFiatCoins() async {
    var url = Uri.https(
      apiUrl,
      '$exApi/common/getFaitCoinList',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);
      if (responseData['code'] == "0") {
        _currencies = responseData['data'];
        return notifyListeners();
      }
    } catch (error) {
      // throw error;
      return;
    }
  }

  Future<void> getPublicInfoMarket() async {
    var url = Uri.https(
      apiUrl,
      '$exApi/common/public_info_market',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == "0") {
        _publicInfoMarket = responseData['data'];
        return notifyListeners();
      }
    } catch (error) {
      // throw error;
      return;
    }
  }

  Future<void> assetsRate() async {
    var url = Uri.https(
      apiUrl,
      '$exApi/common/rateV2',
    );

    var postData = json.encode({
      "fiat": _activeCurrency['fiat_symbol'].toUpperCase(),
    });

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == "0") {
        _rate = responseData['data']['rate'];
        return notifyListeners();
      }
    } catch (error) {
      // throw error;
      return;
    }
  }
}
