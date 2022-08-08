import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/Translate.utils.dart';

import '../utils/AppConstant.utils.dart';
import 'package:http/http.dart' as http;

class ReferralProvider with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'exchange-token': '',
  };

  var _referralinvitationdata;

  get referralinvitationdata {
    return _referralinvitationdata;
  }

  bool isrefdataloagin = true;

  Future<void> getreferralInvitation(context, auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$referralinvitation/pageConfig',
    );

    isrefdataloagin = true;

    try {
      final response = await http.post(url, headers: headers);
      print(response.statusCode);

      final responseData = json.decode(response.body);

      isrefdataloagin = false;
      if (responseData['code'] == 0) {
        _referralinvitationdata = responseData['data'];
       
        print(referralinvitationdata);

        return notifyListeners();
      } else {

         snackAlert(
              context, SnackTypes.warning, getTranslate(responseData['msg']));
        return notifyListeners();
      }
    } catch (error) {
      
      snackAlert(context, SnackTypes.errors, 'Server Error Try Again');
      return;
    }
  }

  List _rewardlist = [];

  List get rewardlist {
    return _rewardlist;
  }

  bool isrewards = true;
  Future<void> getrewards(context, auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$referralinvitation/invitation_reward_ranking_list',
    );
    var data = {};

    var body = jsonEncode(data);
    isrewards = true;
    try {
      final response = await http.post(url, headers: headers, body: body);

      isrewards = false;
      final responseData = json.decode(response.body);

      if (responseData['code'] == 0) {
        _rewardlist = responseData['data']['list'];

        return notifyListeners();
      } else {
         snackAlert(
              context, SnackTypes.warning, getTranslate(responseData['msg']));
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      snackAlert(context, SnackTypes.errors, 'Server Error Try Again');
      return;
    }
  }

  List _invitationlist = [];

  List get invitationlist {
    return _invitationlist;
  }

  bool isinvitation = true;

  Future<void> getmyInvitation(context, auth,formdata) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$referralinvitation/myInvitations',
    );
    

    var body = jsonEncode(formdata);
    isinvitation = true;
    try {
      final response = await http.post(url, headers: headers, body: body);

      final responseData = json.decode(response.body);
      isinvitation = false;
      if (responseData['code'] == 0) {
        _invitationlist = responseData['data']['invitationList'];

        return notifyListeners();
      } else {
        snackAlert(
              context, SnackTypes.warning, getTranslate(responseData['msg']));
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      snackAlert(context, SnackTypes.errors, 'Server Error Try Again');
      return;
    }
  }

  List _myinvitationrewardslist = [];

  List get myinvitationrewardslist {
    return _myinvitationrewardslist;
  }

  bool isinvitationrewards = true;
  
   
  Future<void> getMyInvitationRewards(context, auth,formdata) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$referralinvitation/myInvitationRewards',
    );
    
    var body = jsonEncode(formdata);
    isinvitationrewards = true;
    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = json.decode(response.body);

      print(responseData);
      if (responseData['code'] == 0) {
        _myinvitationrewardslist = responseData['data']['rewardList'];
       
        isinvitationrewards = false;
        notifyListeners();
         
      } else {
        bool isinvitationrewards = false;
        snackAlert(
            context, SnackTypes.warning, getTranslate(responseData['msg']));
        return notifyListeners();
      }
    } catch (error) {
      snackAlert(context, SnackTypes.errors, ' Server Error Try Again');
      isinvitationrewards = false;
      notifyListeners();
         
      return;
    }
  }
}
