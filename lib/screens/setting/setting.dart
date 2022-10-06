import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Country.utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/Colors.utils.dart';

class Setting extends StatefulWidget {
  static const routeName = '/setting';
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool isNotification = false;
  @override
  void initState() {
    super.initState();
  }

  //  @override
  // void dispose() {
  //   timer?.cancel();
  //   super.dispose();
  // }

  // loaddata() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   print(prefs.getBool('isnotification'));
  //   if(prefs.getBool('isnotification')==true){
  //    timer =
  //       Timer.periodic(Duration(seconds: 30), (Timer t) {
  //         print('calling');

  //          getnotification();

  //    });

  //   }else{
  //     var notificationProvider =
  //       Provider.of<Notificationprovider>(context, listen: false);
  //       setState(() {
  //         notificationProvider.isLoading=false;
  //       });
  //       if (timer != null) {
  //         timer!.cancel();
  //       }
  //     print(" not turn on not calling");
  //   }

  // }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    var auth = Provider.of<Auth>(context, listen: true);

    return Scaffold(
      appBar: appBar(context, null),
      body: SizedBox(
        width: width,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notification'),
                  subtitle: Text(
                    'Turn on receive notfications in my application',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Switch(
                    value: isNotification,
                    onChanged: (val) async {
                      if (auth.isAuthenticated) {
                        setState(() {
                          isNotification = val;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isnotification', isNotification);
                        print('check notifcation');

                        print(prefs.getBool('isnotification'));
                      } else {
                        Navigator.pushNamed(context, '/authentication');
                      }
                    },
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language choice'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('light/dark mode'),
                  trailing: Switch(
                    value: isNotification,
                    onChanged: (val) async {
                      if (auth.isAuthenticated) {
                        setState(() {
                          isNotification = val;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isnotification', isNotification);
                        print('check notifcation');

                        print(prefs.getBool('isnotification'));
                      } else {
                        Navigator.pushNamed(context, '/authentication');
                      }
                    },
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.support),
                  title: const Text('Help center/support'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.policy),
                  title: const Text('Privacy policy'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.book),
                  title: const Text('Terms and conditions'),
                ),
              ),
              Card(
                child: ListTile(
                  onTap: (() {
                    snackAlert(context,SnackTypes.success, 'Cache Clear SucessFully');
                  }),
                  leading: const Icon(Icons.cached),
                  title: const Text('Clear cache'),
                 
                 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
