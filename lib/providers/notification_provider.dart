import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:http/http.dart' as http;

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
      baseurlmesg,
      '$mesg/user_message',
    );

    var data = postData;

    var body = jsonEncode(data);
    try {
      isLoading = true;
      final response = await http.post(url, headers: headers, body: body);

      final responseData = json.decode(response.body);

      if (responseData['msg'] == 'success') {
        userMessageList = responseData['data']['userMessageList'];
        isLoading = false;
        return notifyListeners();
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
      baseurlmesg,
      '$mesg/message_del',
    );
    print(url);

    var data = {"ids": "$id"};

    var body = jsonEncode(data);
    try {
      isdeleteloading = true;
      final response = await http.post(url, headers: headers, body: body);
      print(response.statusCode);
      final responseData = json.decode(response.body);

      print(responseData);
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
}
