import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/user.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/screens/common/widget/error_dialog.dart';
import 'package:lyotrade/screens/common/widget/loading_dialog.dart';

import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool _payWithLyoCred = false;
  bool _processLogout = false;

  String _versionNumber = '0.0';

  @override
  void initState() {
    checkVersion();
    checkFeeCoinStatus();
    getProfileImage();
    super.initState();
  }

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();
  Future<void> _getImage() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageXFile != null) {
      setState(() {
        imageXFile;
      });
    }
    startUploading();
  }

  Future<void> startUploading() async {
    var auth = Provider.of<Auth>(context, listen: false);

    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please select an image.",
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return LoadingDialog(
              message: "Uploading Image",
            );
          });

      await auth.uploadProfileImage(context, auth.loginVerificationToken,
          auth.userInfo['id'], imageXFile, imageXFile!.name);

      getProfileImage();
    }
  }

  Future<void> getProfileImage() async {
    var auth = Provider.of<Auth>(context, listen: false);
    await auth.getProfileImage(context, {
      "token": auth.loginVerificationToken,
      "userId": "${auth.userInfo['id']}"
    });
  }

  Future<void> checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _versionNumber = packageInfo.version;
    });
  }

  void checkFeeCoinStatus() {
    var auth = Provider.of<Auth>(context, listen: false);
    if (auth.userInfo.isNotEmpty) {
      setState(() {
        _payWithLyoCred = auth.userInfo['useFeeCoinOpen'] == 1 ? true : false;
      });
    }
  }
    _launchURL() async {
    const url = 'https://docs.lyotrade.com/help-center/trading-fees#trading-fees';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var public = Provider.of<Public>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);
    var user = Provider.of<User>(context, listen: true);

    return SizedBox(
      width: width,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: kIsWeb ? 120 : width * 0.46,
              child: DrawerHeader(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    auth.userInfo.isEmpty
                        ? ListTile(
                            onTap: () {
                              Navigator.pushNamed(context, '/authentication');
                            },
                            leading: const CircleAvatar(
                              child: Icon(Icons.account_circle),
                            ),
                            title: const Text(
                              'Login',
                              style: TextStyle(fontSize: 20),
                            ),
                            subtitle: const Text('Welcome to LYOTRADE'),
                            trailing: const Icon(
                              Icons.chevron_right,
                            ),
                          )
                        : ListTile(
                            leading: InkWell(
                              onTap: () {
                                kIsWeb ? null : _getImage();
                              },
                              child: CircleAvatar(
                                radius:
                                    MediaQuery.of(context).size.width * 0.10,
                                backgroundColor: Colors.white,
                              
                                backgroundImage: imageXFile == null &&
                                        auth.avatarrespons.isEmpty
                                    ? null
                                    : CachedNetworkImageProvider(
                                        "${auth.avatarrespons[0]['file']['link'] ?? FileImage(File(imageXFile!.path))}"),
                                child: imageXFile == null &&
                                        auth.avatarrespons.isEmpty
                                    ? Icon(
                                        Icons.add_photo_alternate,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.10,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            ),
                            title: Text(
                              '${auth.userInfo['userAccount']}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 20),
                            ),
                            subtitle: InkWell(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text:
                                        '${auth.userInfo.isNotEmpty ? auth.userInfo['id'] : '-'}',
                                  ),
                                );
                                showAlert(
                                  context,
                                  Icon(Icons.copy),
                                  'Copy',
                                  [Text('Copied!')],
                                  'Ok',
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Text(
                                      'UID: ${auth.userInfo.isNotEmpty ? auth.userInfo['id'] : '-'}',
                                    ),
                                  ),
                                  Icon(
                                    Icons.copy,
                                    color: secondaryTextColor,
                                    size: 14,
                                  )
                                ],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () {
                  if (auth.isAuthenticated) {
                    Navigator.pushNamed(context, '/referal_screen');
                  } else {
                    Navigator.pushNamed(context, '/authentication');
                  }
                },
                title: Text('Referral Program'),
                subtitle: Text(
                  'Refer friends and get rewards',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                trailing: Icon(
                  Icons.star_border_outlined,
                ),
              ),
            ),
            kIsWeb
                ? Container()
                : Card(
                    child: ListTile(
                      title: Text('KYC'),
                      subtitle: Text(
                        'Complete your KYC',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        if (auth.isAuthenticated) {
                          Navigator.pushNamed(context, '/kyc_screen');
                        } else {
                          Navigator.pushNamed(context, '/authentication');
                        }
                      },
                      trailing: Icon(Icons.verified_user),
                    ),
                  ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    onTap: () async {
                      if (auth.isAuthenticated) {
                        Navigator.pushNamed(context, '/transactions');
                        await auth.getUserInfo(context);
                      } else {
                        Navigator.pushNamed(context, '/authentication');
                      }
                    },
                    leading: const Icon(Icons.list_alt),
                    title: const Text('History'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    onTap: (() {
                      _launchURL();
                    }),
                    leading: const Icon(Icons.percent),
                    title: const Text('Trading Fee Level'),
                    trailing: Text(
                      'Current Level: ${auth.userInfo['accountStatus'] ?? '--'}',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.percent),
                    title: const Text('Pay with your LYO Credit'),
                    subtitle: Text(
                      'Used as an exchange market, trading currency unit',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Switch(
                      value: auth.userInfo.isEmpty ? false : _payWithLyoCred,
                      onChanged: (val) async {
                        if (auth.isAuthenticated) {
                          setState(() {
                            _payWithLyoCred = val;
                          });
                          await user.toggleFeeCoinOpen(
                              context, auth, val ? 1 : 0);
                          await auth.getUserInfo(context);
                        } else {
                          Navigator.pushNamed(context, '/authentication');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Security'),
                    trailing: Text(
                      'Payment and Password',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () async {
                      if (auth.isAuthenticated) {
                        Navigator.pushNamed(context, '/security');
                        await auth.getUserInfo(context);
                      } else {
                        Navigator.pushNamed(context, '/authentication');
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: const Text('Currency'),
                    trailing: DropdownButton<String>(
                      icon: Container(),
                      isDense: true,
                      underline: Container(),
                      value: public.activeCurrency['fiat_symbol'],
                      // icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      onChanged: (newCurrency) async {
                        await public.changeCurrency(newCurrency);
                        await public.assetsRate();
                      },
                      items: public.currencies
                          .map<DropdownMenuItem<String>>((currency) {
                        return DropdownMenuItem<String>(
                          value: currency['fiat_symbol'],
                          child: Text(
                            '${currency['fiat_icon']} ${currency['fiat_symbol'].toUpperCase()}',
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                   ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, '/setting');
                    },
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                ],
              ),
            ),
            auth.userInfo.isNotEmpty
                ? Container(
                    padding: EdgeInsets.only(right: 10, left: 10, top: 5),
                    child: LyoButton(
                      onPressed: _processLogout
                          ? null
                          : () async {
                              setState(() {
                                _processLogout = true;
                              });
                              await auth.logout(context);
                              setState(() {
                                _processLogout = false;
                              });
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/dashboard', (route) => false);
                            },
                      text: 'Logout',
                      active: true,
                      activeColor: linkColor,
                      activeTextColor: Colors.black,
                      isLoading: _processLogout,
                    ))
                : Container(),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.only(top: 10),
                child: Text('Version: $_versionNumber'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
