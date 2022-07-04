import 'package:flutter/material.dart';

import 'package:lyotrade/screens/common/header.dart';

import 'package:lyotrade/utils/Colors.utils.dart';

class EnitityVerification extends StatefulWidget {
  static const routeName = '/entityverification';
  @override
  State<StatefulWidget> createState() => _EnitityVerificationState();
}

class _EnitityVerificationState extends State<EnitityVerification>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: hiddenAppBar(),
        body: SingleChildScrollView(
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
                      'Entity Verification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Divider(thickness: 1, height: 1),
            SizedBox(
              height: 20,
            ),
        
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: selectboxcolour,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'CorporateTier 1',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text('Requirements',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      )),
                                ],
                              ),
                              Container(
                                height: 30,
                                child: ListTile(
                                  trailing: SizedBox.shrink(),
                                  leading: Text(
                                    "• ",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  title: Text('Company Data',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: natuaraldark,
                                      )),
                                ),
                              ),
                              Container(
                                height: 30,
                                child: ListTile(
                                  trailing: SizedBox.shrink(),
                                  leading: Text(
                                    "• ",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  title: Text('UBOs',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: natuaraldark,
                                      )),
                                ),
                              ),
                              Container(
                                height: 30,
                                child: ListTile(
                                  trailing: SizedBox.shrink(),
                                  leading: Text(
                                    "• ",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  title: Text('Shareholder',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: natuaraldark,
                                      )),
                                ),
                              ),
                              ListTile(
                                trailing: SizedBox.shrink(),
                                leading: Text(
                                  "• ",
                                  style: TextStyle(fontSize: 25),
                                ),
                                title: Text('Questionnaire',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, bottom: 8),
                                child: ElevatedButton(
                                  child: Text(
                                    "Start Now",
                                    style: TextStyle(
                                      color: whiteTextColor,
                                    ),
                                  ),
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      primary: bluechartColor,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 10),
                                      textStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                ),
                                Text('Crptyo Limits',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ],
                            ),
                             Container(
                              height: 30,
                              child: ListTile(
                                trailing: Text('',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                                leading: Text(
                                  "• ",
                                  style: TextStyle(fontSize: 25),
                                ),
                                title: Text('Related intersts',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                              ),
                            ),
                            Container(
                              height: 30,
                              child: ListTile(
                                trailing: Text('unlimited',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                                leading: Text(
                                  "• ",
                                  style: TextStyle(fontSize: 25),
                                ),
                                title: Text('Crptyo Deposit Limits',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                              ),
                            ),
                            Container(
                              height: 30,
                              child: ListTile(
                                trailing: Text('100000 USDT Daily',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                                leading: Text(
                                  "• ",
                                  style: TextStyle(fontSize: 25),
                                ),
                                title: Text('Crypto Withdrawal Limits',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                              ),
                            ),
                            ListTile(
                              trailing: Text('unlimited',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: natuaraldark,
                                  )),
                              leading: Text(
                                "• ",
                                style: TextStyle(fontSize: 25),
                              ),
                              title: Text('P2P Transaction Limits',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: natuaraldark,
                                  )),
                            )
                          ],
                        ),
                      ]),
                ),
                SizedBox(
                  height: 10,
                ),
             Container(
                  width: MediaQuery.of(context).size.width,
                  color: selectboxcolour,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'CorporateTier 2',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text('Requirements',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      )),
                                ],
                              ),
                              Container(
                                height: 30,
                                child: ListTile(
                                  trailing: SizedBox.shrink(),
                                  leading: Text(
                                    "• ",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  title: Text('Company Data',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: natuaraldark,
                                      )),
                                ),
                              ),
                              Container(
                                height: 30,
                                child: ListTile(
                                  trailing: SizedBox.shrink(),
                                  leading: Text(
                                    "• ",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  title: Text('UBOs',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: natuaraldark,
                                      )),
                                ),
                              ),
                              Container(
                                height: 30,
                                child: ListTile(
                                  trailing: SizedBox.shrink(),
                                  leading: Text(
                                    "• ",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  title: Text('Shareholder',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: natuaraldark,
                                      )),
                                ),
                              ),
                              ListTile(
                                trailing: SizedBox.shrink(),
                                leading: Text(
                                  "• ",
                                  style: TextStyle(fontSize: 25),
                                ),
                                title: Text('Questionnaire',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, bottom: 8),
                                child: ElevatedButton(
                                  child: Text(
                                    "Start Now",
                                    style: TextStyle(
                                      color: whiteTextColor,
                                    ),
                                  ),
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      primary: bluechartColor,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 10),
                                      textStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                ),
                                Text('Crptyo Limits',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ],
                            ),
                             Container(
                              height: 30,
                              child: ListTile(
                                trailing: Text('',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                                leading: Text(
                                  "• ",
                                  style: TextStyle(fontSize: 25),
                                ),
                                title: Text('Related intersts',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                              ),
                            ),
                            Container(
                              height: 30,
                              child: ListTile(
                                trailing: Text('unlimited',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                                leading: Text(
                                  "• ",
                                  style: TextStyle(fontSize: 25),
                                ),
                                title: Text('Crptyo Deposit Limits',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                              ),
                            ),
                            Container(
                              height: 30,
                              child: ListTile(
                                trailing: Text('30000000 USDT Daily',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                                leading: Text(
                                  "• ",
                                  style: TextStyle(fontSize: 25),
                                ),
                                title: Text('Crypto Withdrawal Limits',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                              ),
                            ),
                            ListTile(
                              trailing: Text('unlimited',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: natuaraldark,
                                  )),
                              leading: Text(
                                "• ",
                                style: TextStyle(fontSize: 25),
                              ),
                              title: Text('P2P Transaction Limits',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: natuaraldark,
                                  )),
                            )
                          ],
                        ),
                      ]),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: selectboxcolour,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'CorporateTier 3',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text('Requirements',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      )),
                                ],
                              ),
                              Container(
                                height: 30,
                                child: ListTile(
                                  trailing: SizedBox.shrink(),
                                  leading: Text(
                                    "• ",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  title: Text('Company Data',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: natuaraldark,
                                      )),
                                ),
                              ),
                              Container(
                                height: 30,
                                child: ListTile(
                                  trailing: SizedBox.shrink(),
                                  leading: Text(
                                    "• ",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  title: Text('UBOs',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: natuaraldark,
                                      )),
                                ),
                              ),
                              Container(
                                height: 30,
                                child: ListTile(
                                  trailing: SizedBox.shrink(),
                                  leading: Text(
                                    "• ",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  title: Text('Shareholder',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: natuaraldark,
                                      )),
                                ),
                              ),
                              ListTile(
                                trailing: SizedBox.shrink(),
                                leading: Text(
                                  "• ",
                                  style: TextStyle(fontSize: 25),
                                ),
                                title: Text('Questionnaire',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, bottom: 8),
                                child: ElevatedButton(
                                  child: Text(
                                    "Start Now",
                                    style: TextStyle(
                                      color: whiteTextColor,
                                    ),
                                  ),
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      primary: bluechartColor,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 10),
                                      textStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                ),
                                Text('Crptyo Limits',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ],
                            ),
                             Container(
                              height: 30,
                              child: ListTile(
                                trailing: Text('',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                                leading: Text(
                                  "• ",
                                  style: TextStyle(fontSize: 25),
                                ),
                                title: Text('Related intersts',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                              ),
                            ),
                            Container(
                              height: 30,
                              child: ListTile(
                                trailing: Text('unlimited',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                                leading: Text(
                                  "• ",
                                  style: TextStyle(fontSize: 25),
                                ),
                                title: Text('Crptyo Deposit Limits',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                              ),
                            ),
                            Container(
                              height: 30,
                              child: ListTile(
                                trailing: Text('5000000 USDT Daily',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                                leading: Text(
                                  "• ",
                                  style: TextStyle(fontSize: 25),
                                ),
                                title: Text('Crypto Withdrawal Limits',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: natuaraldark,
                                    )),
                              ),
                            ),
                            ListTile(
                              trailing: Text('unlimited',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: natuaraldark,
                                  )),
                              leading: Text(
                                "• ",
                                style: TextStyle(fontSize: 25),
                              ),
                              title: Text('P2P Transaction Limits',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: natuaraldark,
                                  )),
                            )
                          ],
                        ),
                      ]),
                ),
                
          ]),
            )
         
         
          ]),
        ));
  }
}
