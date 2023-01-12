import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart/entity/index.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';

class TradeChallenge with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'exchange-language': 'en_US',
  };

  ///task center ///

  Map _taskCenter = {};

  Map get taskCenter {
    return _taskCenter;
  }

  bool _isloadingtaskCenter = false;
  bool get isloadingtaskCenter {
    return _isloadingtaskCenter;
  }

  Future<void> getTaskCenter(
    ctx,
    auth,
  ) async {
    headers['exchange-token'] = auth.loginVerificationToken;
    var url = Uri.https(
      apiUrl,
      '$rewardcenterApi/task_center_index',
    );
    try {
      _isloadingtaskCenter = true;
      final response = await http.post(url, headers: headers);
      final responseData = json.decode(response.body);
      if (responseData['code'] == "0") {
        _isloadingtaskCenter = false;
        _taskCenter = responseData['data'];
        return notifyListeners();
      } else {
        _isloadingtaskCenter = false;
        _taskCenter = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      return;
    }
  }

  /// Reward Center///

  Map _rewardcenter = {};

  Map get rewardcenter {
    return _rewardcenter;
  }

  bool _isloadingreward = false;
  bool get isloadingreward {
    return _isloadingreward;
  }

  Future<void> getRewardCenter(
    ctx,
    auth,
  ) async {
    headers['exchange-token'] = auth.loginVerificationToken;
    var url = Uri.https(
      apiUrl,
      '$rewardcenterApi/reward_center_index',
    );
    try {
      _isloadingreward = true;
      final response = await http.post(url, headers: headers);
      final responseData = json.decode(response.body);
      if (responseData['code'] == "0") {
        _rewardcenter = responseData['data'];
        return notifyListeners();
      } else {
        _rewardcenter = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      return;
    }
  }

  ////user task //

  List _usertask = [];

  List get usertask {
    return _usertask;
  }

  bool _isloadinUserTask = false;
  bool get isloadinUserTask {
    return _isloadinUserTask;
  }

  Future<void> getUserTask(ctx, auth, post) async {
    headers['exchange-token'] = auth.loginVerificationToken;
    var url = Uri.https(
      apiUrl,
      '$rewardcenterApi/user_task_info_list',
    );

    var postData = json.encode(post);
    print(postData);

    try {
      _isloadinUserTask = true;
      final response = await http.post(url, body: postData, headers: headers);
      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['code'] == "0") {
        _isloadinUserTask = false;
        _usertask = responseData['data'];
        return notifyListeners();
      } else {
        _isloadinUserTask = false;
        _usertask = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      return;
    }
  }

  ////Reward Record //

  List _rewardRecord = [];

  List get rewardRecord {
    return _rewardRecord;
  }

  bool _isloadingrewardRecord = false;
  bool get isloadingrewardRecord {
    return _isloadingrewardRecord;
  }

  Future<void> getRewardRecord(ctx, auth, post) async {
    headers['exchange-token'] = auth.loginVerificationToken;
    var url = Uri.https(
      apiUrl,
      '$rewardcenterApi/user_reward_record_list',
    );

    var postData = json.encode(post);
    try {
      _isloadingrewardRecord = true;
      final response = await http.post(url, body: postData, headers: headers);
      final responseData = json.decode(response.body);

      if (responseData['code'] == "0") {
        _isloadingrewardRecord = false;
        _rewardRecord = responseData['data']['list'];
        return notifyListeners();
      } else {
        _isloadingrewardRecord = false;
        _rewardRecord = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      return;
    }
  }

  ////Reward Overview //

  List _rewardRecordOverview = [];

  List get rewardRecordOverview {
    return _rewardRecordOverview;
  }

  bool _isloadingrewardOverview = false;
  bool get isloadingrewardOverview {
    return _isloadingrewardOverview;
  }

  Future<void> getRewardOverview(ctx, auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;
    var url = Uri.https(
      apiUrl,
      '$rewardcenterApi/user_reward_overview',
    );
    try {
      _isloadingrewardOverview = true;
      final response = await http.post(url, headers: headers);
      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['code'] == "0") {
        _isloadingrewardOverview = false;
        _rewardRecordOverview = responseData['data'];
        return notifyListeners();
      } else {
        _isloadingrewardOverview = false;
        _rewardRecordOverview = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      return;
    }
  }

  ////User withDrawal record //

  List _userRecordWithDrawal = [];

  List get userRecordWithDrawal {
    return _userRecordWithDrawal;
  }

  bool _isLoadingWithDrawal = false;
  bool get isLoadingWithDrawal {
    return _isLoadingWithDrawal;
  }

  Future<void> getUserWithDrawalRecord(ctx, auth,post) async {
    headers['exchange-token'] = auth.loginVerificationToken;
    var url = Uri.https(
      apiUrl,
      '$rewardcenterApi/user_withdraw_record_list',
    );
     var postData = json.encode(post);
    try {
      _isLoadingWithDrawal = true;
      final response = await http.post(url,body: postData, headers: headers);
      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['code'] == "0") {
        _isLoadingWithDrawal = false;
        _userRecordWithDrawal = responseData['data']['list'];
        return notifyListeners();
      } else {
        _isLoadingWithDrawal = false;
        _userRecordWithDrawal = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      return;
    }
  }

  ///Do Daily Check In ///

  Map _dailyCheckIn = {};

  Map get dailyCheckIn {
    return _dailyCheckIn;
  }

  bool _isloadingdailyCheckIn = false;
  bool get isloadingdailyCheckIn {
    return _isloadingdailyCheckIn;
  }

  Future<void> getDoDailyCheckIn(
    ctx,
    auth,
  ) async {
    headers['exchange-token'] = auth.loginVerificationToken;
    var url = Uri.https(
      apiUrl,
      '$rewardcenterApi/do_daily_sign_in',
    );
    try {
      _isloadingtaskCenter = true;
      final response = await http.post(url, headers: headers);
      final responseData = json.decode(response.body);
      if (responseData['code'] == "0") {
        _isloadingtaskCenter = false;
        _dailyCheckIn = responseData['data'];
        return notifyListeners();
      }else if (responseData['code'] == "101205") {
        _isloadingtaskCenter = false;
        _dailyCheckIn = responseData['data'];
        return notifyListeners();
      } else {
        _isloadingtaskCenter = false;
        _dailyCheckIn = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      return;
    }
  }
  // // Get Active Stake Info
  // Map _activeStakeInfo = {};

  // Map get activeStakeInfo {
  //   return _activeStakeInfo;
  // }

  // Future<void> getActiveStakeInfo(ctx, auth, stakeId) async {
  //   headers['exchange-token'] = auth.loginVerificationToken;

  //   var url = Uri.https(
  //     apiUrl,
  //     '$incrementApi/increment/project_info',
  //   );

  //   var postData = json.encode({'id': stakeId});

  //   try {
  //     final response = await http.post(url, body: postData, headers: headers);

  //     final responseData = json.decode(response.body);

  //     if (responseData['code'] == 0) {
  //       _activeStakeInfo = responseData['data'];
  //       return notifyListeners();
  //     } else if (responseData['code'] == 10002) {
  //       Navigator.pop(ctx);
  //       snackAlert(ctx, SnackTypes.warning, 'Please login to access');
  //       Navigator.pushNamed(ctx, '/authentication');
  //     } else {
  //       _activeStakeInfo = {};
  //       return notifyListeners();
  //     }
  //   } catch (error) {
  //     // throw error;
  //     print(error);
  //     return;
  //   }
  // }

}
