import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';

import 'package:lyotrade/screens/security/forgot/forgotemailform.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'forgotlphoneform.dart';

class Forgotpassword extends StatefulWidget {
  static const routeName = '/forgotForgotpassword';
  const Forgotpassword({Key? key,}) : super(key: key);

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword>
    with SingleTickerProviderStateMixin {
  String _versionNumber = '0.0';
  TabController? _tabController;
  final _formKey = GlobalKey<FormState>();

  var _pages = [
    Forgotemailform(),
    Forgotphoneform(),
  ];

  @override
  void initState() {
    super.initState();
    checkVersion();
    _tabController = new TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    );
  }

  Future<void> checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _versionNumber = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          height: height,
          padding: EdgeInsets.only(top: width * 0.2),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10),
                height: height * 0.20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        auth.setForgotStepOne({});
                        auth.setEmailValidResponse({});
                        auth.setSmsValidResponse({});
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10, right: 30),
                      child: Column(
                        children: [
                          const Image(
                            image: AssetImage('assets/img/logo_s.png'),
                            width: 100,
                          ),
                          Text('v$_versionNumber'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: width * 0.03),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  bottom: 0, left: width * 0.05),
                              child: const Text(
                                'Reset password',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  bottom: 0, left: width * 0.05),
                              child: Text(
                                'It is forbidden to withdraw coins within 48\nhours after resetting the login password',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TabBar(
                        onTap: (index) {
                          setState(() {});
                        },
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                            width: 2,
                            color: linkColor,
                          ),
                          insets: EdgeInsets.only(
                              left: width * 0.05, right: 25, bottom: 4),
                        ),
                        isScrollable: true,
                        labelPadding:
                            EdgeInsets.only(left: width * 0.05, right: 0),
                        tabs: const [
                          Padding(
                            padding: EdgeInsets.only(right: 25),
                            child: Tab(text: 'Email'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 25),
                            child: Tab(text: 'Mobile Phone'),
                          ),
                        ],
                        controller: _tabController,
                      ),
                      Expanded(
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
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
        ),
      ),
    );
  }
}

// // Login Button Method Widget
// Widget PhoneMethod() {
//   return Column(
//     children: [
//       SizedBox(
//         height: 40,
//       ),
//       Container(
//           padding: EdgeInsets.all(10.0),
//           child: TextField(
//             autocorrect: true,
//             decoration: InputDecoration(
//               hintText: 'Phone Number',
//               hintStyle: TextStyle(color: Colors.grey),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                 borderSide: BorderSide(color: Colors.grey, width: 1),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                 borderSide: BorderSide(color: Colors.grey, width: 1),
//               ),
//             ),
//           )),
//       SizedBox(height: 50),
//       Container(
//         width: 380,
//         child: ElevatedButton(
//           child: Text(
//             "Next",
//             style: TextStyle(
//               color: whiteTextColor,
//             ),
//           ),
//           onPressed: () {},
//           style: ElevatedButton.styleFrom(
//               primary: bluechartColor,
//               padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
//               textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ),
//       ),
//     ],
//   );
// }

// // Login Button Method Widget
// Widget EmailMethod() {
//   return Column(
//     children: [
//       SizedBox(
//         height: 40,
//       ),
//       Container(
//           padding: EdgeInsets.all(10.0),
//           child: TextField(
//             autocorrect: true,
//             decoration: InputDecoration(
//               hintText: 'Email',
//               hintStyle: TextStyle(color: Colors.grey),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                 borderSide: BorderSide(color: Colors.grey, width: 1),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                 borderSide: BorderSide(color: Colors.grey, width: 1),
//               ),
//             ),
//           )),
//       SizedBox(height: 50),
//       Container(
//         width: 380,
//         child: ElevatedButton(
//           child: Text(
//             "Next",
//             style: TextStyle(
//               color: whiteTextColor,
//             ),
//           ),
//           onPressed: () {},
//           style: ElevatedButton.styleFrom(
//               primary: bluechartColor,
//               padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
//               textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ),
//       ),
//     ],
//   );
// }