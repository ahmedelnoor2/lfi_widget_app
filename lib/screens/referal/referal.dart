import 'dart:convert';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';

import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/referral.dart';

import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

import '../common/snackalert.dart';
import '../common/types.dart';

class Referal extends StatefulWidget {
  static const routeName = '/referal_screen';
  @override
  State<StatefulWidget> createState() => _ReferalState();
}

class _ReferalState extends State<Referal> {
  @override
  void initState() {
    super.initState();
    getreferalinivationdat();
  }

  Image? _qrCode;

  bool _isLoading = false;

  Future<void> getreferalinivationdat() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var referalprovider = Provider.of<ReferralProvider>(context, listen: false);

    await referalprovider.getreferralInvitation(context, auth);
    loadQrCode();
  }

  Future<void> loadQrCode() async {
    var referalprovider = Provider.of<ReferralProvider>(context, listen: false);
    setState(() {
      _qrCode = Image.memory(
        base64Decode(
          referalprovider.referralinvitationdata['inviteQECode']
              .split(',')[1]
              .replaceAll("\n", ""),
        ),
      );
    });
  }

  Future<void> share(title, text) async {
    await FlutterShare.share(
      title: '$title',
      text: '$text',
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    var referalprovider = Provider.of<ReferralProvider>(context, listen: true);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: hiddenAppBar(),
      body: SingleChildScrollView(
        child: referalprovider.isrefdataloagin
            ? SizedBox(
                height: MediaQuery.of(context).size.height / 1.3,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                            'Referral',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: (() {
                              Navigator.pushNamed(
                                  context, '/LeaderBoard_screen');
                            }),
                            child: Container(
                                width: width * 0.1,
                                padding: EdgeInsets.only(right: width * 0.02),
                                child: Image.asset('assets/img/ref2.png')),
                          ),
                          GestureDetector(
                            onTap: (() {
                              Navigator.pushNamed(
                                  context, '/Refralinvitation_screen');
                            }),
                            child: Container(
                                width: width * 0.1,
                                padding: EdgeInsets.only(right: width * 0.02),
                                child:
                                    Image.asset('assets/img/invitation.png')),
                          ),
                        ],
                      )
                    ],
                  ),
                  Divider(thickness: 1, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectboxcolour,
                        image: DecorationImage(
                            image: AssetImage(
                              "assets/img/referral.png",
                            ),
                            // fit: BoxFit.contain,
                            alignment: Alignment.bottomRight),
                      ),
                      //  width: width * 100,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Referrer Bonus(USDT) ',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w400),
                            ),
                            Text(
                                referalprovider.referralinvitationdata[
                                        'topReferrerRewardAmount']
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w500)),
                            Container(
                              padding: EdgeInsets.only(
                                  left: 0,
                                  top: height * 0.02,
                                  right: width * 0.3),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Friends',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400)),
                                      Text(
                                          referalprovider
                                              .referralinvitationdata[
                                                  'invitationUserCount']
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: width * 0.2),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Rewards(USDT)',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400)),
                                        Text(
                                            referalprovider
                                                .referralinvitationdata[
                                                    'invitationRewardUsdtSum']
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        Image.asset('assets/img/ref-icon1.png'),
                        Container(
                          padding: EdgeInsets.only(left: 8),
                          child: Text('How to get rebate income?',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8, left: 16, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              height: height * 0.04,
                              width: width * 0.1,
                              decoration: BoxDecoration(
                                color: selectboxcolour,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '1',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Send invitation',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Friends complete registration and trade',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: DottedLine(
                            direction: Axis.vertical,
                            lineLength: height * 0.04,
                            lineThickness: 1.0,
                            dashLength: 2.0,
                            dashColor: Colors.black,
                            dashGapLength: 4.0,
                            dashGapColor: darkgreyColor,
                            dashGapRadius: 0.0,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              height: height * 0.04,
                              width: width * 0.1,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selectboxcolour),
                              child: Text(
                                '2',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Friends complete registration and trade',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'They hiy the road',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: DottedLine(
                            direction: Axis.vertical,
                            lineLength: height * 0.04,
                            lineThickness: 1.0,
                            dashLength: 2.0,
                            dashColor: Colors.black,
                            dashRadius: 0.0,
                            dashGapLength: 4.0,
                            dashGapColor: darkgreyColor,
                            dashGapRadius: 0.0,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              height: height * 0.04,
                              width: width * 0.1,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selectboxcolour),
                              child: Text(
                                '3',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Get rebate income',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'You make savings!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          style: BorderStyle.solid,
                          width: 0.3,
                          color: Color(0xff5E6292),
                        ),
                      ),
                      width: width * 0.30,
                      height: width * 0.30,
                      child: (referalprovider
                                      .referralinvitationdata['inviteQECode'] !=
                                  null &&
                              _qrCode != null)
                          ? _qrCode
                          : const CircularProgressIndicator.adaptive(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 5, bottom: 5),
                    width: MediaQuery.of(context).size.width * 90,
                    child: InkWell(
                      onTap: () {
                        snackAlert(context, SnackTypes.success, 'Copied');
                      },
                      child: Container(
                        height: height * 0.06,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: invitationcodecolour,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Invitation code',
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Text(
                                    '${referalprovider.referralinvitationdata['inviteCode']}',
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              '${referalprovider.referralinvitationdata['inviteCode']}',
                                        ),
                                      );
                                      snackAlert(context, SnackTypes.success,
                                          'Copied');
                                    },
                                    child: Icon(
                                      Icons.copy,
                                      size: 18,
                                      color: linkColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 5, bottom: 5),
                    width: MediaQuery.of(context).size.width * 90,
                    child: InkWell(
                      onTap: () {
                        snackAlert(context, SnackTypes.success, 'Copied');
                      },
                      child: Container(
                        height: height * 0.06,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: invitationcodecolour,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Text(
                                'Referral Link',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Text(
                                    '${referalprovider.referralinvitationdata['inviteUrl'].substring(0, 18)}..',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              '${referalprovider.referralinvitationdata['inviteUrl']}',
                                        ),
                                      );
                                      snackAlert(
                                        context,
                                        SnackTypes.success,
                                        'Copied',
                                      );
                                    },
                                    child: Icon(
                                      Icons.copy,
                                      size: 18,
                                      color: linkColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    child: LyoButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isLoading = true;
                              });
                              share(
                                '${referalprovider.referralinvitationdata['inviteCode']}',
                                '${referalprovider.referralinvitationdata['inviteUrl']}',
                              );
                            },
                      text: 'Invite Friends',
                      active: true,
                      activeColor: linkColor,
                      activeTextColor: Colors.black,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
