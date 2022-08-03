import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/notification_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/screens/common/snackalert.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

import '../common/types.dart';

class Notificationsscreen extends StatefulWidget {
  static const routeName = '/notification_screen';
  const Notificationsscreen({Key? key}) : super(key: key);

  @override
  State<Notificationsscreen> createState() => _NotificationsscreenState();
}

class _NotificationsscreenState extends State<Notificationsscreen>
    with SingleTickerProviderStateMixin {
  String dropdownValue = 'All';

  bool _isselected = false;

  String _messageType = '0';

  @override
  void initState() {
    getnotification();
    super.initState();
  }

  Future<void> getnotification() async {
    var notificationProvider =
        Provider.of<Notificationprovider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    await notificationProvider.getnotification(context, auth, {
      "page": "1",
      "pageSize": "10",
      "messageType": _messageType,
    });
  }

  Widget build(BuildContext context) {
    var notificationProvider =
        Provider.of<Notificationprovider>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: false);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: hiddenAppBar(),
      body: SafeArea(
          child: Column(children: [
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
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                InkWell(
                  onTap: (() {
                    _buildBottomSheet(
                      context,
                      notificationProvider,
                      auth,
                      setState,
                    );
                  }),
                  child: Container(
                    height: 50,
                    width: 70,
                    child: Image.asset('assets/img/filter_icon.png'),
                  ),
                ),
              ],
            )
          ],
        ),
        Divider(),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: <Widget>[
                      Checkbox(
                          activeColor: greyDarkTextColor,
                          value: _isselected,
                          onChanged: (value) {
                            setState(() {
                              _isselected = value ?? false;
                              if (_isselected == true) {
                                notificationProvider.userMessageList
                                    .map((e) => notificationProvider
                                        .selectedItems
                                        .add(e))
                                    .toList();
                              } else {
                                notificationProvider.userMessageList
                                    .map((e) => notificationProvider
                                        .selectedItems
                                        .remove(e))
                                    .toList();
                              }
                            });
                          }),
                      Text("Select All"),
                    ],
                  ),
                  // Container(
                  //   height: 35,
                  //   width: 50,
                  //   child: Image.asset('assets/img/deleteicon.png'),
                  // ),
                ],
              ),
            ),
          ],
        ),
        notificationProvider.isLoading
            ? Center(child: CircularProgressIndicator())
            : Expanded(
                child: notificationProvider.userMessageList.isEmpty
                    ? Center(
                        child: noData('No messages'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: notificationProvider.userMessageList.length,
                        itemBuilder: (context, index) {
                          var item =
                              notificationProvider.userMessageList[index];
                          return Column(
                            children: [
                              Slidable(
                                enabled: true,
                                // Specify a key if the Slidable is dismissible.
                                key: const ValueKey(0),

                                // The start action pane is the one at the left or the top side.
                                startActionPane: ActionPane(
                                  // A motion is a widget used to control how the pane animates.
                                  motion: const ScrollMotion(),

                                  // A pane can dismiss the Slidable.
                                  // dismissible: DismissiblePane(onDismissed: () {}),

                                  // All actions are defined in the children parameter.
                                  children: const [
                                    // A SlidableAction can have an icon and/or a label.
                                    // SlidableAction(
                                    //   // An action can be bigger than the others.
                                    //   flex: 2,

                                    //   onPressed: deleteitem,
                                    //   backgroundColor: Color(0xFF7BC043),
                                    //   foregroundColor: Colors.white,
                                    //   icon: Icons.read_more,
                                    //   label: 'Read',
                                    // ),
                                  ],
                                ),

                                // The end action pane is the one at the right or the bottom side.
                                endActionPane: ActionPane(
                                  motion: ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (c) async {
                                        notificationProvider
                                            .deletebyidnotification(
                                                context, auth, item['id'])
                                            .whenComplete(() {
                                          setState(() {
                                            notificationProvider
                                                .getnotification(
                                                    context, auth, {
                                              "page": "1",
                                              "pageSize": "10",
                                              "messageType": _messageType,
                                            });
                                          });
                                        });
                                      },
                                      backgroundColor: Color(0xFFFE4A49),
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ],
                                ),

                                // The child of the Slidable is what the user sees when the
                                // component is not dragged.
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Container(
                                    color: (notificationProvider.selectedItems
                                            .contains(item))
                                        ? tileseletedcoloue
                                        : Colors.transparent,
                                    child: ListTile(
                                      onTap: () {
                                        if (notificationProvider.selectedItems
                                            .contains(item)) {
                                          notificationProvider.selectedItems
                                              .removeWhere(
                                                  (val) => val == item);
                                          notificationProvider
                                              .notifyListeners();
                                        }
                                      },
                                      onLongPress: () {
                                        if (!notificationProvider.selectedItems
                                            .contains(item)) {
                                          notificationProvider.selectedItems
                                              .add(item);
                                          notificationProvider
                                              .notifyListeners();
                                        }
                                      },
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: selectboxcolour,
                                        ),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: notificationProvider
                                                    .selectedItems
                                                    .contains(item)
                                                ? Image.asset(
                                                    'assets/img/select.png',
                                                    width: 20,
                                                    fit: BoxFit.fill,
                                                  )
                                                : Text(
                                                    notificationProvider
                                                                .userMessageList[
                                                            index]
                                                        ['messageContent'][0],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                      ),
                                      title: Text(
                                        notificationProvider
                                            .userMessageList[index]
                                                ['messageContent']
                                            .toString(),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      // subtitle: Text(
                                      //     notificationProvider.userMessageList[index]
                                      //             ['ctime']
                                      //         .toString(),
                                      // style:
                                      //     TextStyle(fontSize: 10, color: natuaraldark)),
                                      trailing: Text(
                                          '${DateFormat('yMMMMd').format(DateTime.fromMillisecondsSinceEpoch(notificationProvider.userMessageList[index]['ctime']))}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: secondaryTextColor,
                                          )),
                                      // trailing: Text(
                                      //     notificationProvider.userMessageList[index]
                                      //             ['ctime']
                                      //         .toString(),
                                      //     style: TextStyle(
                                      //         fontSize: 10, color: natuaraldark)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
      ])),
    );
  }

  Color getLinkColor(value) {
    var defaultColor = Colors.white;

    if (value == _messageType) {
      defaultColor = linkColor;
    }

    return defaultColor;
  }

  Future _buildBottomSheet(
      BuildContext context, notificationProvider, auth, setState) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: bottombuttoncolour,
        context: context,
        builder: (builder) {
          return Container(
            padding: EdgeInsets.only(top: 20),
            color: bottombuttoncolour,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '0';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "0",
                    });
                  },
                  child: Text(
                    'All Notifications',
                    style: TextStyle(color: getLinkColor('0')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '1';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "1",
                    });
                  },
                  child: Text(
                    'System MSG',
                    style: TextStyle(color: getLinkColor('1')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '2';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "2",
                    });
                  },
                  child: Text(
                    'Deposit/Withdraw',
                    style: TextStyle(color: getLinkColor('2')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '3';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "3",
                    });
                  },
                  child: Text(
                    'Safety MSG',
                    style: TextStyle(color: getLinkColor('3')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '4';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "4",
                    });
                  },
                  child: Text(
                    'KYC MSG',
                    style: TextStyle(color: getLinkColor('4')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '7';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "7",
                    });
                  },
                  child: Text(
                    'OTC message',
                    style: TextStyle(color: getLinkColor('7')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '8';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "8",
                    });
                  },
                  child: Text(
                    'Mining Pool',
                    style: TextStyle(color: getLinkColor('8')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '9';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "9",
                    });
                  },
                  child: Text(
                    'Loan MSG',
                    style: TextStyle(color: getLinkColor('9')),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    bottom: 30,
                    left: 15,
                    right: 15,
                  ),
                  child: LyoButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: 'Cancel',
                    active: true,
                    isLoading: false,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
