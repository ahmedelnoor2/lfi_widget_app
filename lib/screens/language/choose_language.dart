import 'package:flutter/material.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/screens/common/widget/language_selector.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class ChooseLanguage extends StatefulWidget {
  static const routeName = '/chooseLanguage';

  @override
  _ChooseLanguageState createState() => _ChooseLanguageState();
}

Future<void> changelanguage(context) async {
  var languageprovider = Provider.of<LanguageChange>(context, listen: false);
  var public = Provider.of<Public>(context, listen: false);
  await languageprovider.getlanguageChange(
    context,
  );
}

class _ChooseLanguageState extends State<ChooseLanguage> {
  @override
  Widget build(BuildContext context) {
    var public = Provider.of<Public>(context, listen: true);
    var languageprovider = Provider.of<LanguageChange>(context, listen: true);
    // print(public.language);
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  "Choose the Language",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w600,
                    color: textFieldTextColor,
                  ),
                ),
                SizedBox(
                  height: 35.0,
                ),
                SizedBox(
                  height: 400,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: public.language.length,
                      itemBuilder: (BuildContext context, int index) {
                        var currentIndex = public.language[index];
                        // print(index);
                        // print(currentIndex);
                        // print(currentIndex);
                        return GestureDetector(
                          onTap: () {
                            setState(() async {
                              snackAlert(context, SnackTypes.warning,
                                  "Processing .....");
                              languageprovider.setlangIndex(index);
                              languageprovider.defaultlanguage =
                                  "lan=${currentIndex['id']}";
                              await changelanguage(context);
                               snackAlert(context, SnackTypes.success,
                                  "Sucessfully Changed .....");
                            });
                          },
                          child: LanguageSelector(
                            isActive: languageprovider.activeIndex == index,
                            language: currentIndex['name'],
                            imagePath: currentIndex['lang_logo'],
                            id: currentIndex['id'],
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LanguageModel {
  final String? language;
  final String? imagePath;

  LanguageModel({this.language, this.imagePath});
}
