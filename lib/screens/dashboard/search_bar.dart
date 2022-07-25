import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/user.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_share/flutter_share.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    Key? key,
    this.handleDrawer,
  }) : super(key: key);

  final handleDrawer;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _inviteLoader = false;
  bool _shareLoader = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    getUserInvitaionInfo();
  }

  Future<void> getUserInvitaionInfo() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var user = Provider.of<User>(context, listen: false);
    if (auth.isAuthenticated) {
      await user.getUserInvitaionInfo(context, auth);
    }
  }

  Future<void> share(title, text) async {
    await FlutterShare.share(
      title: '$title',
      text: '$text',
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var _currentRoute = ModalRoute.of(context)!.settings.name;

    return Container(
      padding: EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(left: 10),
                child: GestureDetector(
                  onTap: () {
                    // Navigator.pushNamed(context, '/authentication');
                    if (_currentRoute == '/' || _currentRoute == '/dashboard') {
                      widget.handleDrawer();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: CircleAvatar(
                    child: Image.asset('assets/img/user.png'),
                    radius: 12,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/market_search');
                  // snackAlert(context, SnackTypes.warning, 'Coming Soon...');
                },
                child: Container(
                  padding: EdgeInsets.only(left: 15),
                  child: SizedBox(
                    width: width * 0.63,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xff292C51),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 10),
                            child: Image.asset('assets/img/search.png'),
                          ),
                          Text(
                            'Search LYO',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(right: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _inviteLoader
                      ? null
                      : () async {
                          setState(() {
                            _inviteLoader = true;
                          });
                          await getUserInvitaionInfo();
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return showInviteOrAppShare(
                                    context,
                                    setState,
                                  );
                                },
                              );
                            },
                          );
                          setState(() {
                            _inviteLoader = false;
                          });
                        },
                  child: _inviteLoader
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Image.asset(
                          'assets/img/scanner.png',
                          width: 24,
                        ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: () {
                      snackAlert(context, SnackTypes.warning, 'Coming Soon...');
                    },
                    child: Image.asset(
                      'assets/img/notification.png',
                      width: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showInviteOrAppShare(context, setState) {
    height = MediaQuery.of(context).size.height;
    var auth = Provider.of<Auth>(context, listen: true);
    var user = Provider.of<User>(context, listen: true);

    return Container(
      padding: EdgeInsets.all(10),
      height: height * 0.65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                auth.isAuthenticated ? 'Invite Friends' : 'Share Application',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  size: 20,
                ),
              )
            ],
          ),
          Divider(),
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: QrImage(
                  data: user.userInvitation.isNotEmpty
                      ? '${user.userInvitation['inviteUrl']}'
                      : kIsWeb
                          ? 'https://www.lyotrade.com/'
                          : Platform.isAndroid
                              ? 'https://play.google.com/store/apps/details?id=com.lyotrade'
                              : 'https://apps.apple.com/app/lyo-trade-crypto-btc-exchange/id1624895730',
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                  size: 150.0,
                ),
              ),
              auth.isAuthenticated
                  ? InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: user.userInvitation.isNotEmpty
                                ? '${user.userInvitation['inviteCode']}'
                                : '',
                          ),
                        );
                        showAlert(
                          context,
                          Icon(
                            Icons.copy,
                          ),
                          'Copied',
                          [
                            Text('Invitaion code copied.'),
                          ],
                          'Ok',
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            style: BorderStyle.solid,
                            width: 0.3,
                            color: Color(0xff5E6292),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Invitaion Code'),
                            Row(
                              children: [
                                Text(user.userInvitation.isNotEmpty
                                    ? '${user.userInvitation['inviteCode']}'
                                    : ''),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Icon(
                                    Icons.copy,
                                    size: 18,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: _shareLoader
                          ? null
                          : () {
                              setState(() {
                                _shareLoader = true;
                              });
                              if (kIsWeb) {
                                Clipboard.setData(
                                  const ClipboardData(
                                    text: 'https://www.lyotrade.com/',
                                  ),
                                );
                                showAlert(
                                  context,
                                  const Icon(
                                    Icons.copy,
                                  ),
                                  'Copied',
                                  [
                                    const Text('App link copied'),
                                  ],
                                  'Ok',
                                );
                              } else {
                                if (Platform.isAndroid) {
                                  share(
                                    'Android APP',
                                    'https://play.google.com/store/apps/details?id=com.lyotrade',
                                  );
                                } else {
                                  share(
                                    'iOS APP',
                                    'https://apps.apple.com/app/lyo-trade-crypto-btc-exchange/id1624895730',
                                  );
                                }
                              }
                              setState(() {
                                _shareLoader = false;
                              });
                            },
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            style: BorderStyle.solid,
                            width: 0.3,
                            color: Color(0xff5E6292),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Share Application'),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              child: _shareLoader
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(),
                                    )
                                  : Icon(
                                      Icons.share,
                                      size: 18,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
              auth.isAuthenticated
                  ? InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: user.userInvitation.isNotEmpty
                                ? '${user.userInvitation['inviteUrl']}'
                                : '',
                          ),
                        );
                        showAlert(
                          context,
                          Icon(
                            Icons.copy,
                          ),
                          'Copied',
                          [
                            Text('Invitaion link copied.'),
                          ],
                          'Ok',
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            style: BorderStyle.solid,
                            width: 0.3,
                            color: Color(0xff5E6292),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Invitaion Link'),
                            Row(
                              children: [
                                Text(user.userInvitation.isNotEmpty
                                    ? '${user.userInvitation['inviteUrl'].substring(0, 13)}...${user.userInvitation['inviteUrl'].substring(user.userInvitation['inviteUrl'].length - 5, user.userInvitation['inviteUrl'].length)}'
                                    : ''),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Icon(
                                    Icons.copy,
                                    size: 18,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }
}
