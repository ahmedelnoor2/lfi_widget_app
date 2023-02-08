import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/widget/language_selector.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class ChooseLanguage extends StatefulWidget {
  static const routeName = '/chooseLanguage';

  @override
  _ChooseLanguageState createState() => _ChooseLanguageState();
}

List<LanguageModel> languages = [
  LanguageModel(
    language: "English",
    imagePath: "assets/img/england.png",
  ),
  LanguageModel(
    language: "Spanish",
    imagePath: "assets/img/spain.png",
  ),
  LanguageModel(
    language: "German",
    imagePath: "assets/img/germany.png",
  ),
  LanguageModel(
    language: "Korean",
    imagePath: "assets/img/korea.png",
  ),
  LanguageModel(
    language: "Polish",
    imagePath: "assets/img/poland.png",
  ),
  LanguageModel(
    language: "Italian",
    imagePath: "assets/img/italy.png",
  ),
];

class _ChooseLanguageState extends State<ChooseLanguage> {
  int _activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    var public = Provider.of<Public>(context, listen: true);
    print(public.publicInfo['lan']['lanList']);
    print(languages);
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
                ...languages.map((language) {
                //  print(language);
                  int _currentIndex = languages.indexOf(language);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeIndex = _currentIndex;
                      
                      });
                    },
                    child: LanguageSelector(
                      isActive: _activeIndex == _currentIndex,
                      language: language.language,
                      imagePath: language.imagePath,
                    ),
                  );
                }).toList(),
                AnimatedCrossFade(
                  crossFadeState: _activeIndex == 0
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: Duration(milliseconds: 450),
                  firstChild: Container(
                    height: 50,
                  ),
                  secondChild: LyoButton(
                    text: "Continue",
                    active: true,
                    onPressed: () {
                      // Navigator.of(context).push(
                      //   // MaterialPageRoute(
                      //   //   builder: (BuildContext context) {
                      //   //    // return Dashboard();
                      //   //   },
                      //   // ),
                      // );
                    },
                  ),
                )
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
