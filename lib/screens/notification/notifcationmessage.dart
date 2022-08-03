import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/notification_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
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

  @override
  void initState() {
    getnotification();
    super.initState();
  }

  Future<void> getnotification() async {
    var notificationProvider =
        Provider.of<Notificationprovider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    await notificationProvider.getnotification(context, auth);
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
                GestureDetector(
                  onTap: (() {
                    _buildBottomSheet(context);
                  }),
                  child: Container(
                    height: 50,
                    width: 70,
                    child: Image.asset('assets/img/icon.png'),
                  ),
                ),
              ],
            )
          ],
        ),
        Divider(
          thickness: 1,
        ),
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

                                print(notificationProvider.selectedItems);
                              } else {
                                notificationProvider.userMessageList
                                    .map((e) => notificationProvider
                                        .selectedItems
                                        .remove(e))
                                    .toList();
                                print(notificationProvider.selectedItems);
                              }
                            });
                          }),
                      Text("Select All"),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        height: 35,
                        width: 50,
                        child: Image.asset('assets/img/deleteicon.png'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        notificationProvider.isLoading
            ? Center(child: CircularProgressIndicator())
            : Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notificationProvider.userMessageList.length,
                  itemBuilder: (context, index) {
                    var item = notificationProvider.userMessageList[index];
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
                          endActionPane:  ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (c) async {
                                  print(item['id']);
                                
                                  notificationProvider.deletebyidnotification(context,auth,item['id']).whenComplete(() {

                                  setState(() {
                                    notificationProvider.getnotification(context, auth);
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
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
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
                                        .removeWhere((val) => val == item);
                                    print(notificationProvider.selectedItems);
                                    notificationProvider.notifyListeners();
                                  }
                                },
                                onLongPress: () {
                                  if (!notificationProvider.selectedItems
                                      .contains(item)) {
                                    notificationProvider.selectedItems
                                        .add(item);
                                    print(notificationProvider.selectedItems);
                                    notificationProvider.notifyListeners();
                                  }
                                },
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selectboxcolour,
                                  ),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: notificationProvider.selectedItems
                                              .contains(index)
                                          ? Image.asset(
                                              'assets/img/select.png',
                                              width: 20,
                                              fit: BoxFit.fill,
                                            )
                                          : Text(
                                              notificationProvider
                                                      .userMessageList[index]
                                                  ['messageContent'][0],
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                ),
                                title: Text(
                                  notificationProvider.userMessageList[index]
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
                                    notificationProvider.userMessageList[index]
                                            ['ctime']
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 10, color: natuaraldark)),
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

  Future _buildBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: bottombuttoncolour,
        context: context,
        builder: (builder) {
          return Container(
            color: bottombuttoncolour,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 5,
                ),
                Text(
                  'All Notifications',
                  style:
                      TextStyle(color: selecteditembordercolour, fontSize: 14),
                ),
                Text(
                  'System MSG',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'Deposit/Withdraw',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'Safety MSG',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'KYC MSG',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'OTC message',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'Mining Pool',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'Loan MSG',
                  style: TextStyle(fontSize: 14),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 90,
                    height: 57,
                    child: ElevatedButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: bottomsheetcolor,
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontStyle: FontStyle.normal),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          );
        });
  }
}
