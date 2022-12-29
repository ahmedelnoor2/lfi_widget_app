import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Translate.utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GiftCardProvider with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'token': '',
    'userId': '',
  };

  Map _toActiveCountry = {};

  Map get toActiveCountry {
    return _toActiveCountry;
  }

  void setActiveCountry(country) {
    _toActiveCountry = country;
    return notifyListeners();
  }

  // Get all countries//

  List _allCountries = [];

  List get allCountries {
    return _allCountries;
  }

  Future<void> getAllCountries(ctx, auth, userid) async {
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var url = Uri.https(lyoApiUrl, 'gift-card/countries');
    print(url);

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);
      print(responseData);

      if (responseData['code'] == 200) {
        _allCountries = responseData['data'];
        _toActiveCountry = _allCountries[0];
        return notifyListeners();
      } else {
        _allCountries = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  //// Get All Catalog ///
  Map _toActiveCatalog = {};

  Map get toActiveCatalog {
    return _toActiveCatalog;
  }

  void settActiveCatalog(catlog) {
    _toActiveCatalog = catlog;
    return notifyListeners();
  }

  bool IsCatalogloading = false;

  List _allCatalog = [];

  List get allCatalog {
    return _allCatalog;
  }

  List _sliderlist = [];

  List get sliderlist {
    return _sliderlist;
  }

  Future<void> getAllCatalog(
    ctx,
    auth,
    userid,
  ) async {
    IsCatalogloading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var url = Uri.https(lyoApiUrl, 'gift-card/catalogues');

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 200) {
        IsCatalogloading = false;
        _allCatalog = responseData['data'];
        _toActiveCatalog = _allCatalog[0];

        _sliderlist = _allCatalog.take(5).toList();

        return notifyListeners();
      } else {
        IsCatalogloading = false;
        _allCatalog = [];
        return notifyListeners();
      }
    } catch (error) {
      IsCatalogloading = false;
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // Get all cards
  bool cardloading = false;

  List _allCard = [];

  List get allCard {
    return _allCard;
  }

  Future<void> getAllCard(
    ctx,
    auth,
    userid,
  ) async {
    cardloading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';
   
    var countrycode = await _toActiveCountry['iso3'];
    var catid = await _toActiveCatalog['id'];
   
    var url = Uri.https(lyoApiUrl, 'gift-card/cards/$catid/$countrycode');
    print(url);

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      print(responseData);

      if (responseData['code'] == 200) {
        cardloading = false;
        _allCard = responseData['data'];

        return notifyListeners();
      } else {
        cardloading = false;
        _allCard = [];
        return notifyListeners();
      }
    } catch (error) {
      cardloading = false;
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  //// Do Transaction////

  bool dotransactionloading = false;

  Map _doTransaction = {};

  Map get doTransaction {
    return _doTransaction;
  }

  Future<void> getDoTransaction(ctx, auth, userid, postdata) async {
    dotransactionloading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var mydata = json.encode(postdata);
    print(mydata);

    var url = Uri.https(lyoApiUrl, 'gift-card/transaction');
    print(url);

    try {
      final response = await http.post(
        url,
        body: mydata,
        headers: headers,
      );

      final responseData = json.decode(response.body);
      print(responseData);

      if (responseData['code'] == 200) {
        dotransactionloading = false;
        _doTransaction = responseData;
        snackAlert(ctx, SnackTypes.success, responseData['msg']);

        return notifyListeners();
      } else {
        snackAlert(ctx, SnackTypes.warning, responseData['msg']);
        dotransactionloading = false;
        _doTransaction = {};
        return notifyListeners();
      }
    } catch (error) {
      cardloading = false;
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }
}
