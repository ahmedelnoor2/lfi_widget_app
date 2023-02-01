import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:gallery_saver/files.dart';

import '../utils/AppConstant.utils.dart';
import 'package:http/http.dart' as http;

class LanguageChange with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'exchange-token': '',
    'cookie': 'lan=en_Us',
  };

  Locale _currentLocale = new Locale("en");

  Locale get currentLocale => _currentLocale;

  void changeLocale(String _locale) {
    this._currentLocale = new Locale(_locale);
    notifyListeners();
  }

  bool _islanguageloading = false;

  bool get islanguageloading {
    return _islanguageloading;
  }

  Map _getlanguage = {};

  Map get getlanguage {
    return _getlanguage;
  }

  var defaultlanguage = 'lan=en_US';
  Future<void> getlanguageChange(ctx) async {
    _islanguageloading = true;
    var url = Uri.https(
      apiUrl,
      '/getLocale',
    );
    headers['cookie'] = defaultlanguage;
    print(headers['cookie']);

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 0) {
        _islanguageloading = false;
        _getlanguage = responseData['data']['mobile'];
        print('object....');
        print(_getlanguage);

        return notifyListeners();
      } else {
        _getlanguage = {};
        _islanguageloading = false;
        return notifyListeners();
      }
    } catch (error) {
      _getlanguage = {};
      _islanguageloading = false;

      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }
}
