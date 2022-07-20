import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../utils/AppConstant.utils.dart';
import 'package:http/http.dart' as http;

class ReferralProvider with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'exchange-token': '',
  };

  var _referraldata;

  get referraldata {
    return _referraldata;
  }

  List _refmapdata = [];

  List get refmapdata {
    return _refmapdata;
  }

  
  var coinName = 'USDT';

  var keyword = '';
  var keyborad = '2';

  Future<void> getreferral(auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$referral/agent_data_query',
    );

    var data = {
      'coinName': '$coinName',
      "keyword": '$keyword',
      "keyword_type": '$keyborad',
      "pageNum": '1'
    };
print(data);
    var body = jsonEncode(data);

    try {
      final response = await http.post(url, headers: headers, body: body);
      print(response.statusCode);
      final responseData = json.decode(response.body);

      if (responseData['msg'] == 'success') {
        _referraldata = responseData['data'];

        print(responseData['data']);
        _refmapdata = responseData['data']['mapList'];

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

  /////position data///

  var _positiondata;

  get positiondata {
    return _positiondata;
  }

  List _positiondatalist = [];

  List get positiondatalist {
    return _positiondatalist;
  }

  var pcoinName = 'USDT';

  var pkeyword = 'UID';
  var pkeyborad = '1';

  Future<void> getpositionreferral(auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$referral/agent_account_query',
    );

    var data = {
      'coinName': '$pcoinName',
      "keyword": '$pkeyword',
      "keyword_type": '$pkeyborad',
      "pageNum": '1',
      "securityInfo":
          '{\"adBlock\":false,\"addBehavior\":false,\"audio\":\"124.04347527516074\",\"availableScreenResolution\":\"1920,1032\",\"browserEngine\":\"Blink\",\"browserName\":\"Chrome\",\"browserVersion\":\"103.0.0.0\",\"canvasHash\":\"70e10ec7363092c89f758ffdf08b3d31\",\"colorDepth\":24,\"cookieCode\":\"NjU5ZTRkM2IyYzBkZmE4YmNkZTZiMjdmNWJhYzIzNzI\",\"cookieEnabled\":\"1\",\"cpuClass\":\"not available\",\"custID\":\"lyotrade.com\",\"deviceMemory\":8,\"devicePixelRatio\":1,\"doNotTrack\":\"unknown\",\"flashVersion\":0,\"fontsHash\":\"fbf095ef85e25ead98370cf1b2486578\",\"hardwareConcurrency\":6,\"hasLiedBrowser\":false,\"hasLiedLanguages\":false,\"hasLiedOs\":false,\"hasLiedResolution\":false,\"indexedDb\":true,\"isIncognito\":0,\"isRiskBrowser\":0,\"javaEnabled\":\"0\",\"language\":\"en-US\",\"localCode\":\"192.168.133.59\",\"localStorage\":true,\"mimeTypesHash\":\"fe9c964a38174deb6891b6523b8e4518\",\"navigatorPlatform\":\"Win32\",\"openDatabase\":true,\"os\":\"Windows\",\"osVersion\":\"10\",\"platform\":\"WEB\",\"pluginsHash\":\"2ee4df5f3ed7f5f93e45890a79b8af53\",\"screenResolution\":\"1920,1080\",\"sessionStorage\":true,\"timezone\":\"Asia/Dubai\",\"timezoneOffset\":-240,\"touchSupport\":\"0,false,false\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36\",\"webSmartID\":\"ad6b5876603634505d8860694192e03c\",\"webdriver\":false,\"webglHash\":\"cd99dbbfe7f80887679e2a94333c6259\",\"webglVendorAndRenderer\":\"Google Inc. (Intel)~ANGLE (Intel, Intel(R) UHD Graphics 630 Direct3D11 vs_5_0 ps_5_0, D3D11)\",\"hashCode\":\"HZmivXHk4rjv7fZBHriOv4g0yy2wvbnD_zZ200WvWaU\",\"algID\":\"ZuFNKbPgR9\",\"deviceId\":\"\",\"timestamp\":1657788954464,\"log_BSDeviceFingerprint\":\"1\",\"log_original\":\"0\",\"device\":\"sCo6fyLKEmsHpHkjTijQNG0web3Dy6cqqXkJOybepqYexokSNZcE4b8LpyYuGxzL\",\"log_CHFIT_DEVICEID\":\"1\"}',
      "uaTime": '2022-07-14 10:22:19'
    };

    var body = jsonEncode(data);

    try {
      final response = await http.post(url, headers: headers, body: body);

      final responseData = json.decode(response.body);
      if (responseData['msg'] == 'success') {
        _positiondata = responseData['data'];
        _positiondatalist = responseData['data']['mapList'];

        print(_positiondatalist);
        return notifyListeners();
      } else {
        _positiondatalist = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }
}
