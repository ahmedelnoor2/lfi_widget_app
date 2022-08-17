import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/user_kyc.dart';

import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

import 'package:flutter_idensic_mobile_sdk_plugin/flutter_idensic_mobile_sdk_plugin.dart';

class personalverification extends StatefulWidget {
  static const routeName = '/personalverification';
  @override
  State<StatefulWidget> createState() => _personalverificationState();
}

class _personalverificationState extends State<personalverification>
    with SingleTickerProviderStateMixin {
  bool _processing = false;
  SNSMobileSDK? snsMobileSDK;
  bool useDismissTimer = false;
  bool useApplicantConf = false;
  bool useCustomTheme = false;
  bool _processingSdk = false;

  @override
  void initState() {
    super.initState();
    getKycTierList();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> getKycTierList() async {
    setState(() {
      _processing = true;
    });

    var auth = Provider.of<Auth>(context, listen: false);
    await auth.getPersonalKycTiers(context, {'type': '0'});

    setState(() {
      _processing = false;
    });
  }

  void setupOptionalHandlers(SNSMobileSDKBuilder builder) {
    if (useApplicantConf) {
      builder
          .withApplicantConf({"email": "test@test.com", "phone": "123456789"});
    }

    final SNSStatusChangedHandler onStatusChanged =
        (SNSMobileSDKStatus newStatus, SNSMobileSDKStatus prevStatus) {
      print("onStatusChanged: $prevStatus -> $newStatus");

      // just to show how dismiss() method works
      if (useDismissTimer && prevStatus == SNSMobileSDKStatus.Ready) {
        new Timer(Duration(seconds: 10), () {
          snsMobileSDK?.dismiss();
        });
      }
    };

    final SNSEventHandler onEvent = (SNSMobileSDKEvent event) {
      print("onEvent: $event");
    };

    final SNSActionResultHandler onActionResult =
        (SNSMobileSDKActionResult result) {
      print("onActionResult: $result");

      // you must return a `Future` that in turn should be completed with a value of `SNSActionResultHandlerReaction` type
      // you could pass `.Cancel` to force the user interface to close, or `.Continue` to proceed as usual
      return Future.value(SNSActionResultHandlerReaction.Continue);
    };

    builder.withHandlers(
        onStatusChanged: onStatusChanged,
        onActionResult: onActionResult,
        onEvent: onEvent);
  }

  void setupTheme(SNSMobileSDKBuilder builder) {
    if (!useCustomTheme) {
      return;
    }

    builder.withTheme({
      "universal": {
        "fonts": {
          "assets": [
            // refers to the ttf/otf files (ios needs them to register fonts before they could be used)
            {"name": "Scriptina", "file": "assets/fonts/SCRIPTIN.ttf"},
            {
              "name": "Caslon Antique",
              "file": "assets/fonts/Caslon Antique.ttf"
            },
            {"name": "Requiem", "file": "assets/fonts/Requiem.ttf"},
            {"name": "Drift Wood", "file": "assets/fonts/Driftwood.ttf"},
            {"name": "DAGGERSQUARE", "file": "assets/fonts/DAGGERSQUARE.otf"},
            {"name": "Plasma Drip (BRK)", "file": "assets/fonts/plasdrip.ttf"}
          ],
          "headline1": {
            "name":
                "Scriptina", // use ttf's `Full Name` or the name of any system font installed, or omit the key to keep the default font-face
            "size": 40 // in points
          },
          "headline2": {"name": "Drift Wood", "size": 22},
          "subtitle1": {"name": "DAGGERSQUARE", "size": 20},
          "subtitle2": {"name": "Plasma Drip (BRK)", "size": 18},
          "body": {"name": "Caslon Antique", "size": 16},
          "caption": {"name": "Requiem", "size": 12}
        },
        "images": {
          "iconMail":
              "assets/img/mail-icon.png", // either an image name or a path to the image (the size in points equals the size in pixels)
          "iconClose": {
            "image": "assets/img/cross-icon.png",
            "scale":
                3, // adjusts the "logical" size (in points), points=pixels/scale
            "rendering": "template" // "template" or "original"
          },
          "verificationStepIcons": {
            "identity": {"image": "assets/img/robot-icon.png", "scale": 3},
          }
        },
        "colors": {
          "navigationBarItem": {
            "light": "#FF000080", // #RRGGBBAA - white with 50% alpha
            "dark": "0x80FF0000" // 0xAARRGGBB - white with 50% alpha
          },
          "alertTint":
              "#FF000080", // sets both light and dark to the same color
          "backgroundCommon": {"light": "#FFFFFF", "dark": "#1E232E"},
          "backgroundNeutral": {
            "light": "#A59A8630" // keeps default `dark`
          },
          "backgroundInfo": {"light": "#9E95C0"},
          "backgroundSuccess": {"light": "#749C6F30"},
          "backgroundWarning": {"light": "#F1BE4F30"},
          "backgroundCritical": {"light": "#BB362A30"},
          "contentLink": {"light": "#DD8B35"},
          "contentStrong": {"light": "#4F4945"},
          "contentNeutral": {"light": "#7F877B"},
          "contentWeak": {"light": "#A59A86"},
          "contentInfo": {"light": "#1B1F4E"},
          "contentSuccess": {"light": "#749C6F"},
          "contentWarning": {"light": "#F1BE4F"},
          "contentCritical": {"light": "#BB362A"},
          "primaryButtonBackground": {"light": "#558387"},
          "primaryButtonBackgroundHighlighted": {"light": "#44696B"},
          "primaryButtonBackgroundDisabled": {"light": "#8AA499"},
          "primaryButtonContent": {"light": "#fff"},
          "primaryButtonContentHighlighted": {"light": "#fff"},
          "primaryButtonContentDisabled": {"light": "#fff"},
          "secondaryButtonBackground": {},
          "secondaryButtonBackgroundHighlighted": {"light": "#8AA499"},
          "secondaryButtonBackgroundDisabled": {},
          "secondaryButtonContent": {"light": "#558387"},
          "secondaryButtonContentHighlighted": {"light": "#fff"},
          "secondaryButtonContentDisabled": {"light": "#8AA499"},
          "cameraBackground": {"light": "#222"},
          "cameraContent": {"light": "#D2C5A5"},
          "fieldBackground": {"light": "#F9F1CB80"},
          "fieldBorder": {},
          "fieldPlaceholder": {"light": "#8F8376"},
          "fieldContent": {"light": "#32302F"},
          "fieldTint": {"light": "#558387"},
          "listSeparator": {"light": "#8F837680"},
          "listSelectedItemBackground": {"light": "#D2C5A580"},
          "bottomSheetHandle": {"light": "#8AA499"},
          "bottomSheetBackground": {"light": "#FFFFFF", "dark": "#4F4945"}
        }
      },
      "ios": {
        "metrics": {
          "commonStatusBarStyle": "default",
          "activityIndicatorStyle": "medium",
          "screenHorizontalMargin": 16,
          "buttonHeight": 48,
          "buttonCornerRadius": 8,
          "buttonBorderWidth": 1,
          "cameraStatusBarStyle": "default",
          "fieldHeight": 48,
          "fieldCornerRadius": 0,
          "viewportBorderWidth": 8,
          "bottomSheetCornerRadius": 16,
          "bottomSheetHandleSize": {"width": 36, "height": 4},
          "verificationStepCardStyle": "filled",
          "supportItemCardStyle": "filled",
          "documentTypeCardStyle": "filled",
          "selectedCountryCardStyle": "bordered",
          "cardCornerRadius": 16,
          "cardBorderWidth": 2,
          "listSectionTitleAlignment": "natural"
        }
      }
    });
  }

  Future<void> startVerifictaion(levelName) async {
    setState(() {
      _processingSdk = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var userKyc = Provider.of<UserKyc>(context, listen: false);
    if (levelName == 'Tire1') {
      await userKyc.getSamsubToken(context, auth, {
        'levelName': levelName,
        'type': '0',
      });
    } else {
      await userKyc.changeSamsubToken(context, auth, {
        'levelName': levelName,
        'type': '0',
      });
      await userKyc.getAccessSamsubToken(context, auth, {
        'levelName': levelName,
        'type': '0',
      });
    }
    var accessToken = userKyc.samsubToken['accessToken'];

    final onTokenExpiration = () async {
      return Future<String>.delayed(
          Duration(seconds: 2), () => "your new access token");
    };

    setState(() {
      _processingSdk = false;
    });

    final builder = SNSMobileSDK.init(accessToken, onTokenExpiration);

    setupOptionalHandlers(builder);
    setupTheme(builder);

    snsMobileSDK = builder.withLocale(Locale("en")).withDebug(true).build();

    final result = await snsMobileSDK!.launch();

    print("Completed with result: $result");

    getKycTierList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);

    var userInfoList = {};
    if (auth.personalKycTiers.isNotEmpty) {
      for (var personalKyc in auth.personalKycTiers['userInfoList']) {
        userInfoList[personalKyc['levelName']] = personalKyc;
      }
    }

    return Scaffold(
      appBar: hiddenAppBar(),
      body: _processing
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 20),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.chevron_left),
                            ),
                          ),
                          Text(
                            'Personal Verification',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children: auth.personalKycTiers['list']
                          .map<Widget>(
                            (kycTier) => Card(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                width: width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(right: 10),
                                          child: Text(
                                            '${kycTier['levelName']}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        userInfoList.containsKey(
                                                kycTier['levelName'])
                                            ? userInfoList[kycTier['levelName']]
                                                        ['reviewStatus'] ==
                                                    1
                                                ? Icon(
                                                    Icons.verified,
                                                    color: successColor,
                                                  )
                                                : Container()
                                            : Container(),
                                      ],
                                    ),
                                    Divider(),
                                    Text(
                                      'Requirements',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                        bottom: 5,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: kycTier[
                                                'requirementsReferenceStrList']
                                            .map<Widget>(
                                              (requirement) => Container(
                                                padding:
                                                    EdgeInsets.only(bottom: 5),
                                                child: Text(
                                                  '* $requirement',
                                                  style: TextStyle(
                                                      color:
                                                          secondaryTextColor),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Crypto Deposit Limit'),
                                              Text(
                                                'Unlimited',
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Crypto Withdrawal Limit'),
                                              Text(
                                                '${kycTier['withdrawLimitAmount']} ${kycTier['withdrawLimitSymbol']} Daily',
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('P2P Transaction Limits'),
                                              Text(
                                                'Unlimited',
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        userInfoList.containsKey(
                                                kycTier['levelName'])
                                            ? Container(
                                                padding:
                                                    EdgeInsets.only(bottom: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('Status'),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 5),
                                                          child: userInfoList[kycTier[
                                                                          'levelName']]
                                                                      [
                                                                      'reviewStatus'] ==
                                                                  0
                                                              ? Icon(
                                                                  Icons.timer,
                                                                  size: 18,
                                                                  color:
                                                                      warningColor,
                                                                )
                                                              : userInfoList[kycTier[
                                                                              'levelName']]
                                                                          [
                                                                          'reviewStatus'] ==
                                                                      1
                                                                  ? Icon(
                                                                      Icons
                                                                          .check_circle,
                                                                      size: 18,
                                                                      color:
                                                                          successColor,
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .cancel,
                                                                      size: 18,
                                                                      color:
                                                                          errorColor,
                                                                    ),
                                                        ),
                                                        Text(
                                                          userInfoList[kycTier[
                                                                          'levelName']]
                                                                      [
                                                                      'reviewStatus'] ==
                                                                  1
                                                              ? 'Verified'
                                                              : userInfoList[kycTier[
                                                                              'levelName']]
                                                                          [
                                                                          'reviewStatus'] ==
                                                                      0
                                                                  ? 'Pending'
                                                                  : 'Rejected',
                                                          style: TextStyle(
                                                            color: userInfoList[
                                                                            kycTier['levelName']]
                                                                        [
                                                                        'reviewStatus'] ==
                                                                    0
                                                                ? warningColor
                                                                : userInfoList[kycTier['levelName']]
                                                                            [
                                                                            'reviewStatus'] ==
                                                                        1
                                                                    ? successColor
                                                                    : errorColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                    userInfoList
                                            .containsKey(kycTier['levelName'])
                                        ? userInfoList[kycTier['levelName']]
                                                    ['reviewStatus'] ==
                                                1
                                            ? Container()
                                            : Divider()
                                        : Container(),
                                    userInfoList
                                            .containsKey(kycTier['levelName'])
                                        ? userInfoList[kycTier['levelName']]
                                                    ['reviewStatus'] ==
                                                1
                                            ? Container()
                                            : LyoButton(
                                                onPressed: (_processingSdk)
                                                    ? null
                                                    : () {
                                                        if (kycTier[
                                                                'levelName'] ==
                                                            'Tier1') {
                                                          if (userInfoList
                                                              .containsKey(kycTier[
                                                                  'levelName'])) {
                                                            if ((userInfoList[kycTier[
                                                                            'levelName']][
                                                                        'reviewStatus'] ==
                                                                    2 ||
                                                                userInfoList[kycTier[
                                                                            'levelName']]
                                                                        [
                                                                        'reviewStatus'] ==
                                                                    0)) {
                                                              print('Upadte');
                                                              startVerifictaion(
                                                                  kycTier[
                                                                      'levelName']);
                                                            }
                                                          } else {
                                                            print('Apply');
                                                            startVerifictaion(
                                                                kycTier[
                                                                    'levelName']);
                                                          }
                                                        } else if (kycTier[
                                                                'levelName'] ==
                                                            'Tier2') {
                                                          if (userInfoList
                                                              .containsKey(kycTier[
                                                                  'levelName'])) {
                                                            if ((userInfoList[kycTier[
                                                                            'levelName']][
                                                                        'reviewStatus'] ==
                                                                    2 ||
                                                                userInfoList[kycTier[
                                                                            'levelName']]
                                                                        [
                                                                        'reviewStatus'] ==
                                                                    0)) {
                                                              print('Upadte');
                                                              startVerifictaion(
                                                                  kycTier[
                                                                      'levelName']);
                                                            }
                                                          } else {
                                                            print('Apply');
                                                            startVerifictaion(
                                                                kycTier[
                                                                    'levelName']);
                                                          }
                                                        }
                                                      },
                                                text: userInfoList.containsKey(
                                                        kycTier['levelName'])
                                                    ? userInfoList[kycTier[
                                                                    'levelName']]
                                                                [
                                                                'reviewStatus'] ==
                                                            1
                                                        ? 'Verified'
                                                        : (userInfoList[kycTier[
                                                                        'levelName']]
                                                                    [
                                                                    'reviewStatus'] ==
                                                                2)
                                                            ? 'Resubmit'
                                                            : userInfoList[kycTier[
                                                                            'levelName']]
                                                                        [
                                                                        'reviewStatus'] ==
                                                                    0
                                                                ? 'Update'
                                                                : 'Start Now'
                                                    : 'Start Now',
                                                active: userInfoList.containsKey(
                                                        kycTier['levelName'])
                                                    ? ((kycTier['levelName'] ==
                                                                    'Tier1' ||
                                                                kycTier['levelName'] ==
                                                                    'Tier2') &&
                                                            userInfoList[kycTier['levelName']]
                                                                    [
                                                                    'reviewStatus'] ==
                                                                1)
                                                        ? true
                                                        : (userInfoList[kycTier['levelName']]['reviewStatus'] ==
                                                                    2 ||
                                                                userInfoList[kycTier['levelName']]['reviewStatus'] ==
                                                                    0)
                                                            ? true
                                                            : false
                                                    : (kycTier['levelName'] ==
                                                                'Tier2' &&
                                                            !userInfoList
                                                                .containsKey(
                                                                    [kycTier['levelName']]))
                                                        ? true
                                                        : false,
                                                activeColor: userInfoList
                                                        .containsKey(kycTier[
                                                            'levelName'])
                                                    ? userInfoList[kycTier[
                                                                    'levelName']]
                                                                [
                                                                'reviewStatus'] ==
                                                            1
                                                        ? successColor
                                                        : (userInfoList[kycTier[
                                                                            'levelName']]
                                                                        [
                                                                        'reviewStatus'] ==
                                                                    2 ||
                                                                userInfoList[kycTier['levelName']]
                                                                        [
                                                                        'reviewStatus'] ==
                                                                    0)
                                                            ? Color(0xff5E6292)
                                                            : Color(0xff5E6292)
                                                    : Color(0xff5E6292),
                                                isLoading: _processingSdk,
                                              )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
