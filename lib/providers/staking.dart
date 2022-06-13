import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart/entity/index.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:k_chart/entity/k_line_entity.dart';

class Staking with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
  };

  // Get Active Stake Info
  Map _activeStakeInfo = {};

  Map get activeStakeInfo {
    return _activeStakeInfo;
  }

  Future<void> getActiveStakeInfo(ctx, auth, stakeId) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$incrementApi/increment/project_info',
    );

    var postData = json.encode({'id': stakeId});

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 0) {
        _activeStakeInfo = responseData['data'];
        return notifyListeners();
      } else if (responseData['code'] == 10002) {
        Navigator.pop(ctx);
        snackAlert(ctx, SnackTypes.warning, 'Please login to access');
      } else {
        _activeStakeInfo = {};
        return notifyListeners();
      }
    } catch (error) {
      // throw error;
      print(error);
      return;
    }
  }

  // Create Staking order
  Map _activeStakingOrder = {};

  Map get activeStakingOrder {
    return _activeStakingOrder;
  }

  Future<void> createStakingOrder(ctx, auth, formData) async {
    /**
      {
        orderNum: 1cbdc77d81874fadabe42ea485863d91, 
        appKey: lyotrade_5157,
        userId: 23961095,
        opUrl: https://service.lyotrade.com/platform/pay.html
      }
    */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$incrementApi/staking_create_order',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 0) {
        Navigator.pop(ctx);
        _activeStakingOrder = responseData['data'];
        Navigator.pushNamed(ctx, '/stake_order');
        notifyListeners();
        return;
      } else if (responseData['code'] == 10002) {
        _activeStakingOrder = {};
        Navigator.pop(ctx);
        snackAlert(ctx, SnackTypes.warning, 'Please login to access');
        return notifyListeners();
      } else {
        _activeStakingOrder = {};
        showAlert(ctx, Icon(Icons.warning_amber), 'Error',
            [Text('${responseData['msg']}')], 'Ok');
        return notifyListeners();
      }
    } catch (error) {
      // throw error;
      print(error);
      return;
    }
  }

  // Staking Order Data
  Map _stakeOrderData = {};

  Map get stakeOrderData {
    return _stakeOrderData;
  }

  Future<void> getOrderDetails(ctx, formData) async {
    /**
      {
        orderNum: 1cbdc77d81874fadabe42ea485863d91, 
        appKey: lyotrade_5157
      }
    */

    var url = Uri.https(
      serviceApi,
      '$plfApi/chainup/open/opay/orderDetail',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == "0") {
        _stakeOrderData = responseData['data'];
        return notifyListeners();
      } else if (responseData['code'] == 10002) {
        _stakeOrderData = {};
        snackAlert(ctx, SnackTypes.warning, 'Please login to access');
      } else {
        _stakeOrderData = {};
        snackAlert(ctx, SnackTypes.errors, '${responseData['msg']}');
      }
    } catch (error) {
      // throw error;
      print(error);
      return;
    }
  }

  // Pay stake order

  Future<void> payStakeOrder(ctx, formData) async {
    /**
      {
        appKey: "lyotrade_5157"
        assetType: "201"
        googleCode: "12345"
        orderNum: "38c92e7d03684bc18ab9c7155000c193"
        smsAuthCode: ""
        userId: "23961095"
      }
    */

    var url = Uri.https(
      serviceApi,
      '$plfApi/chainup/open/opay/toPay',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(url, body: postData, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == "0") {
        Navigator.pop(ctx);
        Navigator.pop(ctx);
        snackAlert(ctx, SnackTypes.success, 'Successfully paid');
      } else if (responseData['code'] == 10002) {
        Navigator.pop(ctx);
        snackAlert(ctx, SnackTypes.warning, 'Please login to access');
      } else {
        Navigator.pop(ctx);
        snackAlert(ctx, SnackTypes.errors, '${responseData['msg']}');
      }
    } catch (error) {
      // throw error;
      print(error);
      return;
    }
  }
}
