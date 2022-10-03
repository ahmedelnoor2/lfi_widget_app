import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/utils/Translate.utils.dart';

class Notificationprovider extends ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=UTF-8',
    'Accept': 'application/json',
    'exchange-token': '',
  };

  // List<dynamic> allnotification = [
  //   {
  //     "title": "Registered mobile number is: +971-581495659",
  //     "subtite": "There are many variations of passages",
  //     "desc": "Jul 05 2022"
  //   },
  //   {
  //     "title": "Registered mobile number is: +971-581495659",
  //     "subtite": "There are many variations of passages",
  //     "desc": "Jul 05 2022"
  //   },
  //   {
  //     "title": "Registered mobile number is: +971-581495659",
  //     "subtite": "There are many variations of passages",
  //     "desc": "Jul 05 2022"
  //   },
  //   {
  //     "title": "Registered mobile number is: +971-581495659",
  //     "subtite": "There are many variations of passages",
  //     "desc": "Jul 05 2022"
  //   },
  //   {
  //     "title": "Aregistered mobile number is: +971-581495659",
  //     "subtite": "There are many variations of passages",
  //     "desc": "Jul 05 2022"
  //   },
  //   {
  //     "title": "Registered mobile number is: +971-581495659",
  //     "subtite": "There are many variations of passages",
  //     "desc": "Jul 05 2022"
  //   },
  //   {
  //     "title": "Registered mobile number is: +971-581495659",
  //     "subtite": "There are many variations of passages",
  //     "desc": "Jul 05 2022"
  //   },
  //   {
  //     "title": "Registered mobile number is: +971-581495659",
  //     "subtite": "There are many variations of passages",
  //     "desc": "Jul 05 2022"
  //   },
  //   {
  //     "title": "Registered mobile number is: +971-581495659",
  //     "subtite": "There are many variations of passages",
  //     "desc": "Jul 05 2022"
  //   },
  //   {
  //     "title": "Registered mobile number is: +971-581495659",
  //     "subtite": "There are many variations of passages",
  //     "desc": "Jul 05 2022"
  //   }
  // ];

//  List<dynamic> allnotification=[];
  List userMessageList = [];
  List<dynamic> selectedItems = [];
  var mesgtype = '0';
  bool isLoading = true;
  Future getnotification(ctx, auth, postData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/message/user_message',
    );

    var data = postData;

    var body = jsonEncode(data);
    try {
      isLoading = true;
      final response = await http.post(url, headers: headers, body: body);

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        userMessageList = responseData['data']['userMessageList'];
        isLoading = false;
        return notifyListeners();
      } else if (responseData['code'] == '10002') {
        snackAlert(ctx, SnackTypes.warning, 'Session Expired');
        Navigator.pop(ctx);
        auth.logout(ctx);
      } else {
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  bool isdeleteloading = true;
  Future deletebyidnotification(ctx, auth, id) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/message/message_del',
    );

    var data = {"ids": "$id"};

    var body = jsonEncode(data);
    try {
      isdeleteloading = true;
      final response = await http.post(url, headers: headers, body: body);
      final responseData = json.decode(response.body);

      if (responseData['msg'] == 'success') {
        isdeleteloading = false;
        snackAlert(
            ctx, SnackTypes.success, 'Notification deleted successfully');
        return notifyListeners();
      } else {
        return notifyListeners();
      }
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Failed to Delete Please try again.');
      return;
    }
  }

  Future<void> markAllAsRead(ctx, auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/message/message_update_status',
    );

    var data = {"id": 0};

    var body = jsonEncode(data);
    try {
      isdeleteloading = true;
      final response = await http.post(url, headers: headers, body: body);
      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, 'All notifications mark as read');
        return;
      } else {
        snackAlert(ctx, SnackTypes.errors,
            getTranslate(responseData['msg'].toString()));
        return;
      }
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Failed to Delete Please try again.');
      return;
    }
  }

  bool _readCountResponse = false;

  bool get readCountResponse {
    return _readCountResponse;
  }

  Future<void> readCountMeassage(ctx, auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/message/v4/get_no_read_message_count',
    );

    var data = {};

    var body = jsonEncode(data);
    try {
      isdeleteloading = true;
      final response = await http.post(url, headers: headers, body: body);
      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _readCountResponse =
            responseData['data']['noReadMsgCount'] == 0 ? false : true;

        notifyListeners();

        /// snackAlert(ctx, SnackTypes.success, 'All notifications mark as read');
        return;
      } else if (responseData['code'] == '10002') {
        auth.checkLoginSession(ctx);
      } else {
        print(responseData['msg'].toString());
        return;
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Server Error.');
      return;
    }
  }
}
