import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Translate.utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopupProvider with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'token': '',
    'userId': '',
  };
  String paymentstatus = 'Waiting for payment';

  //// Get Wallet//
  List _allwallet = [];

  List get allwallet {
    return _allwallet;
  }

  var walletBalance;

  Future<void> getAllWallet(ctx, auth, userid) async {
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var url = Uri.http(gifttesturl, 'gift-card/wallets');
    // print(url);

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 200) {
        _allwallet = [];
        for (var wallet in responseData['data']) {
          _allwallet.add(wallet['coinType']);
          _allwallet.add(wallet['coin']);
        }
        // _allwallet = responseData['data'];
        print('check..');
        // print(_allwallet['tota']);
        //walletBalance= _allwallet['total_balance']
        return notifyListeners();
      } else {
        _allwallet = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  Map _toActiveCountry = {};

  Map get toActiveCountry {
    return _toActiveCountry;
  }

  void setActiveCountry(country) {
    _toActiveCountry = country;
    return notifyListeners();
  }

  // Get all countries//

  bool isCountryLoading = false;

  List _allCountries = [];

  List get allCountries {
    return _allCountries;
  }

  Future<void> getAllCountries(ctx, auth, userid) async {
    isCountryLoading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var url = Uri.http(gifttesturl, 'top-up/countries');

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == 200) {
        _allCountries = responseData['data']['countries'];

        _toActiveCountry = responseData['data']['active_country'];
        print(_toActiveCountry);
        isCountryLoading = false;
        return notifyListeners();
      } else {
        _allCountries = [];
        isCountryLoading = false;
        return notifyListeners();
      }
    } catch (error) {
      isCountryLoading = false;
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  //// Get All topup provider ///
  Map _toActiveNetWorkprovider = {};

  Map get toActiveNetWorkprovider {
    return _toActiveNetWorkprovider;
  }

  void setActiveNetWorkprovider(topupnetwork) {
    _toActiveNetWorkprovider = topupnetwork;

    return notifyListeners();
  }

  bool IstopupnetWorkloading = false;

  List _allTopupNetwork = [];

  List get allTopupNetwork {
    return _allTopupNetwork;
  }

  Future<void> getAllNetWorkprovider(
      ctx, auth, userid, postdata, catUpdate) async {
    IstopupnetWorkloading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';
    var activeContryName = toActiveCountry['isoName'];

    var url = Uri.http(gifttesturl, 'top-up/operators/$activeContryName');
    print(url);
    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['code'] == 200) {
        IstopupnetWorkloading = false;
        _allTopupNetwork = responseData['data'];
        print("catelogue...");
        print(_allTopupNetwork[0]);
        if (_toActiveNetWorkprovider.isEmpty) {
          _toActiveNetWorkprovider = _allTopupNetwork[0];
        } else if (catUpdate) {
          if (_allTopupNetwork.length > 0) {
            _toActiveNetWorkprovider = _allTopupNetwork[0];
          } else {
            _toActiveNetWorkprovider = {};
          }
        }

        return notifyListeners();
      } else {
        IstopupnetWorkloading = false;
        _allTopupNetwork = [];
        return notifyListeners();
      }
    } catch (error) {
      IstopupnetWorkloading = false;
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

    var countrycode = _toActiveCountry['iso3'] ?? _toActiveCountry['iso2'];
    var catid = _toActiveNetWorkprovider['id'];
    var name = _toActiveNetWorkprovider['brand'].split(" ")[0];

    var url = Uri.http(
        gifttesturl, 'gift-card/cards/$catid/$countrycode', {'name': '$name'});

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

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

  //// Estimate////

  bool isEstimate = false;

  Map _estimateRate = {};

  Map get estimateRate {
    return _estimateRate;
  }

  Future<void> getEstimateRate(ctx, auth, userid, postdata) async {
    print(postdata);
    isEstimate = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var mydata = json.encode(postdata);

    var url = Uri.http(gifttesturl, 'top-up/estimate');

    try {
      final response = await http.post(
        url,
        body: mydata,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      print('estimate response:${responseData}');

      if (responseData['code'] == 200) {
        isEstimate = false;
        _estimateRate = responseData['data'][0];
        print(_estimateRate);
        return notifyListeners();
      } else {
        //snackAlert(ctx, SnackTypes.warning, responseData['msg']);
        isEstimate = false;
        _estimateRate = {};

        return notifyListeners();
      }
    } catch (error) {
      isEstimate = false;

      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  /// Otp verification///
  bool _isverify = false;

  bool get isverify {
    return _isverify;
  }

  void setverify(value) {
    _isverify = value;
  }

  //Google code enable//
  bool _isgoogleCode = false;

  bool get isgoogleCode {
    return _isgoogleCode;
  }

  void setgoolgeCode(value) {
    _isgoogleCode = value;
  }

  bool otpverifcation = false;

  var verificationType = '';

  Map _doverify = {};

  Map get doverify {
    return _doverify;
  }

  Future<void> getDoVerify(ctx, auth, userid, postdata) async {
    otpverifcation = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';
    // print('verificatiom');
    // print(postdata);

    var mydata = json.encode(postdata);

    var url = Uri.http(gifttesturl, 'gift-card/send_verification_request');

    try {
      final response = await http.post(
        url,
        body: mydata,
        headers: headers,
      );

      final responseData = json.decode(response.body);
      //  print('send verification Api.${responseData}');

      if (responseData['code'] == '200') {
        otpverifcation = false;
        _doverify = responseData['data'];

        //verificationType = _doverify['verificationType'];

        //   print(_doverify);
        setverify(true);
        setgoolgeCode(_doverify['googleCode']);

        snackAlert(ctx, SnackTypes.success, responseData['msg']);

        return notifyListeners();
      } else {
        snackAlert(ctx, SnackTypes.warning, responseData['msg']);
        otpverifcation = false;
        _doverify = {};
        return notifyListeners();
      }
    } catch (error) {
      otpverifcation = false;
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  /// withDrawal///

  bool _iswithdrwal = false;
  bool get iswithdrwal {
    return _iswithdrwal;
  }

  Map _dowithdrawal = {};

  Map get dowithdrawal {
    return _dowithdrawal;
  }

  Future<bool> getDoWithDrawal(ctx, auth, userid, postdata) async {
    _iswithdrwal = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';
    var mydata = json.encode(postdata);
    print("with drwawal response...");
    print(mydata);

    var url = Uri.http(gifttesturl, 'gift-card/withdraw');
    print(url);
    try {
      final response = await http.post(
        url,
        body: mydata,
        headers: headers,
      );
      //  print(response);
      final responseData = json.decode(response.body);
      //   print('with drawal process ....');
      //   print(responseData);

      if (responseData['code'] == '0' || responseData['code'] == 0) {
        //    print('i am calling');
        _iswithdrwal = false;
        _dowithdrawal = responseData;
        paymentstatus = 'Card is Processing';

        snackAlert(ctx, SnackTypes.success, responseData['msg']);

        notifyListeners();
        return true;
      } else {
        snackAlert(ctx, SnackTypes.warning, responseData['msg']);
        _iswithdrwal = false;
        _doverify = {};
        notifyListeners();
        return false;
      }
    } catch (error) {
      _iswithdrwal = false;
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      notifyListeners();
      return false;
    }
  }
  //// Do Transaction////

  bool dotransactionloading = false;

  Map _doTransaction = {};

  Map get doTransaction {
    return _doTransaction;
  }

  Future<void> getDoTransaction(ctx, auth, userid, postdata) async {
    print(postdata);
    print('do trnasaction...');
    dotransactionloading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var mydata = json.encode(postdata);

    var url = Uri.http(gifttesturl, 'gift-card/transaction');

    try {
      final response = await http.post(
        url,
        body: mydata,
        headers: headers,
      );

      final responseData = json.decode(response.body);
      print("Transactopn data...");
      print(responseData);

      if (responseData['code'] == '200' || responseData['code'] == 200) {
        dotransactionloading = false;
        _doTransaction = responseData;
        paymentstatus = 'Completed';

        snackAlert(ctx, SnackTypes.success, responseData['msg']);

        return notifyListeners();
      } else {
        snackAlert(ctx, SnackTypes.warning, responseData['msg']);
        dotransactionloading = false;
        _doTransaction = {};
        paymentstatus = 'Failed to process a Gift Card, Please Contact Admin.';
        return notifyListeners();
      }
    } catch (error) {
      dotransactionloading = false;
      paymentstatus = 'Failed to process a Gift Card, Please Contact Admin.';
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  /// Get All Gift Card Transaction ///

  bool istransactionloading = false;

  List _transaction = [];

  List get transaction {
    return _transaction;
  }

  Future<void> getAllTransaction(
    ctx,
    auth,
    userid,
  ) async {
    istransactionloading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var url = Uri.http(gifttesturl, 'gift-card/transaction');

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);
      print(responseData);

      if (responseData['code'] == '200' || responseData['code'] == 200) {
        istransactionloading = false;
        _transaction = responseData['data'].reversed.toList();
        print('check....transactionj');
        print(_transaction.last);

        return notifyListeners();
      } else {
        snackAlert(ctx, SnackTypes.warning, responseData['msg']);
        istransactionloading = false;
        _transaction = [];
        return notifyListeners();
      }
    } catch (error) {
      istransactionloading = false;
      print(error);
      snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  //// get redeem deatils
  bool isredeemloading = false;
  Map _redeem = {};

  Map get redeem {
    return _redeem;
  }

  Future<void> getRedeem(
    ctx,
    auth,
    userid,
    transactionId,
    brandId,
  ) async {
    isredeemloading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var url =
        Uri.http(gifttesturl, 'gift-card/redeem/${brandId}/${transactionId}');

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);
      print(responseData);

      if (responseData['code'] == 200) {
        _redeem = responseData['data'];
        isredeemloading = false;
        return notifyListeners();
      } else {
        _redeem = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }
}
