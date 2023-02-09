import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Country.utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
    var languageprovider = Provider.of<LanguageChange>(context, listen: true);


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
                  title:  Text(languageprovider.getlanguage['setting_detail']['option1']['title']??'Notification'),
                  subtitle: Text(
                languageprovider.getlanguage['setting_detail']['option1']['text']??    'Turn on receive notfications in my application',
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
              // Card(
              //   child: ListTile(
              //     leading: const Icon(Icons.language),
              //     title: const Text('Language choice'),
              //   ),
              // ),
              // Card(
              //   child: ListTile(
              //     leading: const Icon(Icons.color_lens),
              //     title: const Text('light/dark mode'),
              //     trailing: Switch(
              //       value: isNotification,
              //       onChanged: (val) async {
              //         if (auth.isAuthenticated) {
              //           setState(() {
              //             isNotification = val;
              //           });
              //           final prefs = await SharedPreferences.getInstance();
              //           await prefs.setBool('isnotification', isNotification);
              //           print('check notifcation');

              //           print(prefs.getBool('isnotification'));
              //         } else {
              //           Navigator.pushNamed(context, '/authentication');
              //         }
              //       },
              //     ),
              //   ),
              // ),
              Card(
                child: ListTile(
                  onTap: (() {
                    _launchHelpSupport();
                  }),
                  leading: const Icon(Icons.support),
                  title:  Text(languageprovider.getlanguage['setting_detail']['option1']['option2']['title']??'Help Center / Support'),
                ),
              ),
              Card(
                child: ListTile(
                  onTap: (() {
                    _launchPrivacy();
                  }),
                  leading: const Icon(Icons.policy),
                  title:  Text(languageprovider.getlanguage['setting_detail']['option1']['option3']['title']??'Privacy Policy'),
                ),
              ),
              Card(
                child: ListTile(
                  onTap: (() {
                    _launchTermsAndConditons();
                  }),
                  leading: const Icon(Icons.book),
                  title:  Text(languageprovider.getlanguage['setting_detail']['option1']['option4']['title']??'Terms And Conditions'),
                ),
              ),
              Card(
                child: ListTile(
                  onTap: (() {
                    snackAlert(context, SnackTypes.success,
                        'Cache cleared successfully');
                  }),
                  leading: const Icon(Icons.cached),
                  title:  Text(languageprovider.getlanguage['setting_detail']['option1']['option5']['title']??'Clear Cache'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _launchHelpSupport() async {
    const url = 'https://support.lyotrade.com/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchPrivacy() async {
    const url = 'https://docs.lyotrade.com/terms/privacy-policy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchTermsAndConditons() async {
    const url = 'https://docs.lyotrade.com/terms/terms-of-use';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
