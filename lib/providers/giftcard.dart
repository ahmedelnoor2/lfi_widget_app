import 'dart:convert';
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

  Future<void> getAllCountries(ctx, auth,userid) async {
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] ='${userid}';

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
    // Get all cards
  bool cardloading=false;

  List _allCard = [];

  List get allCard {
    return _allCard;
  }

  Future<void> getAllCard(ctx, auth,userid) async {
    cardloading=true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] ='${userid}';

    var url = Uri.https(lyoApiUrl, 'gift-card/cards');
    print(url);

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);
      print(responseData);

      if (responseData['code'] == 200) {
        cardloading=false;
        _allCard = responseData['data'];
    
        return notifyListeners();
      } else {
        cardloading=false;
        _allCard = [];
        return notifyListeners();
      }
    } catch (error) {
      cardloading=false;
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }


  //// Do Transaction////
  ///
      // Get all cards
  bool dotransactionloading=false;

  Map _doTransaction = {};

  Map get doTransaction {
    return _doTransaction;
  }

  Future<void> getDoTransaction(ctx, auth,userid,postdata) async {
    dotransactionloading=true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] ='${userid}';

    var mydata=json.encode(postdata);
    print(mydata);

    var url = Uri.https(lyoApiUrl,'gift-card/transaction');
    print(url);
    

    try {
      final response = await http.post(url,body:mydata ,headers: headers,);

      final responseData = json.decode(response.body);
       print(responseData);

      if (responseData['code'] == 200) {

        dotransactionloading=false;
        _doTransaction = responseData;
        snackAlert(ctx, SnackTypes.success, responseData['msg']);
    
        return notifyListeners();
      } else {
        snackAlert(ctx, SnackTypes.warning, responseData['msg']);
        dotransactionloading=false;
        _doTransaction = {};
        return notifyListeners();
      }
    } catch (error) {
      cardloading=false;
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }
}
