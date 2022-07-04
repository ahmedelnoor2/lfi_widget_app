import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/referal/pages/commision_record.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Country.utils.dart';
import 'package:provider/provider.dart';

import 'forgotloginform.dart';

class Forgotpassword extends StatefulWidget {
  static const routeName = '/forgotForgotpassword';
  const Forgotpassword({Key? key}) : super(key: key);

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final _formKey = GlobalKey<FormState>();

  var _pages = [Forgotloginform(), EmailMethod()];

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: appBar(context, null),
      body: Column(
        children: [
          Container(
            child: Expanded(
              child: Column(
                children: [
                  PreferredSize(
                    preferredSize: Size.fromHeight(40),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TabBar(
                        isScrollable: true,
                        controller: _tabController,
                        labelColor: whiteTextColor,
                        indicatorColor: selecteditembordercolour,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 1.0,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: _size.width / 28.0,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: _size.width / 28.0,
                        ),
                        tabs: [
                          Container(
                            width: _size.width * .4,
                            child: Tab(
                              text: 'Phone Number',
                            ),
                          ),
                          Container(
                            width: _size.width * .4,
                            child: Tab(
                              text: 'Email Address',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(thickness: 1, height: 1),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: _pages.map((
                        Widget tab,
                      ) {
                        return tab;
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Login Button Method Widget
Widget PhoneMethod() {
  return Column(
    children: [
      SizedBox(
        height: 40,
      ),
      Container(
          padding: EdgeInsets.all(10.0),
          child: TextField(
            autocorrect: true,
            decoration: InputDecoration(
              hintText: 'Phone Number',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
          )),
      SizedBox(height: 50),
      Container(
        width: 380,
        child: ElevatedButton(
          child: Text(
            "Next",
            style: TextStyle(
              color: whiteTextColor,
            ),
          ),
          onPressed: () {},
          style: ElevatedButton.styleFrom(
              primary: bluechartColor,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    ],
  );
}

// Login Button Method Widget
Widget EmailMethod() {
  return Column(
    children: [
      SizedBox(
        height: 40,
      ),
      Container(
          padding: EdgeInsets.all(10.0),
          child: TextField(
            autocorrect: true,
            decoration: InputDecoration(
              hintText: 'Email',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
          )),
      SizedBox(height: 50),
      Container(
        width: 380,
        child: ElevatedButton(
          child: Text(
            "Next",
            style: TextStyle(
              color: whiteTextColor,
            ),
          ),
          onPressed: () {},
          style: ElevatedButton.styleFrom(
              primary: bluechartColor,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    ],
  );
}
