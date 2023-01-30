import 'package:flutter/material.dart';

var mainBackgroundColor = const Color(0x001a1d3f);

MaterialColor kToDark = const MaterialColor(
  0xffe55f48, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
  const <int, Color>{
    50: const Color(0xffce5641), //10%
    100: const Color(0xffb74c3a), //20%
    200: const Color(0xffa04332), //30%
    300: const Color(0xff89392b), //40%
    400: const Color(0xff733024), //50%
    500: const Color(0xff5c261d), //60%
    600: const Color(0xff451c16), //70%
    700: const Color(0xff2e130e), //80%
    800: const Color(0xff170907), //90%
    900: const Color(0xff000000), //100%
  },
);

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

var errorColor = Colors.red;
var successColor = Colors.green;
var warningColor = Colors.amber;

var whiteTextColor = Colors.white;
var whitebgColor = Colors.white;
var blackTextColor = Colors.black;
var secondaryTextColor = Color(0xffBABABA);
var natuaraldark = Color(0xff747584);

var secondaryTextColor400 = Color(0xff5E6292);

var greenIndicator = Color(0xff46D88B);
var redIndicator = Color(0xffD84646);
var redPercentageIndicator = Color.fromARGB(77, 216, 70, 70);
var greenPercentageIndicator = Color.fromARGB(77, 70, 216, 138);
var linkColor = Color.fromARGB(255, 1, 254, 246);
var onboardText=Color(0xFF5E6292);
var geryTextColor = Color(0xFF39434a);
var buttonBGColor = Color(0xFF10255c);
var tabBarindicatorColor = Color(0xFF305dc3);
var textFieldBGColor = Color(0xFFf4f4f4);
var textFieldTextColor = Color(0xFFbcbcbc);
var greyTextColor = Color(0xFF929191);
var greyDarkTextColor = Color(0xFF646e7c);
var greyDarkHeaderTextColor = Color(0xFF303745);
var greyBorderColor = Color(0xFFe2e2e2);
var greenBTNBGColor = Color(0xFF2fbd85);
var pinkBTNBGColor = Color(0xFFf54760);
var dotedlineColor = Color(0xFFb3b3b3);
var bodyBGColor = Color(0xFFfefefe);
var greyIconColor = Color(0xFF111010);
var greyIconColor1 = Color(0xFF8a8a8a);
var greyIconColor2 = Color(0xFFd3d3d3);
var greyCopyLinkTextColor = Color(0xFF838383);

/// chartColors
var bluechartColor = Color(0xFF1f6cd6);
var bluelightchartColor = Color(0xFF85c4fd);
var yellowchartColor = Color(0xFFfcd434);
var greenlightchartColor = Color(0xFF46D88B);
var greychartColor = Color(0xFF7e90a4);
var greyinfoBGColor = Color(0xFFe4e5e9);
var greyTextColor1 = Color(0xFF919190); //
var backArrowColor = Color(0xFF141414); //
var dottedBorderColor = Color(0xFF9c9c9c); //
var darkgreyColor = Color(0xFF6d6d6d); //
var selecteditembordercolour = Color(0XFF01FEF5);
var tileseletedcoloue = Color(0XFF024274D);
var bottomsheetcolor = Color(0XFF0272946);
// Icon Colors
var orangeBGColor = Color(0xFFFF9000);

//button colour

var buttoncolour = Color(0xFF5E6292);
var selectboxcolour = Color(0xFF383C6F);

var seconadarytextcolour = Color(0xFF5E6292);
var bottombuttoncolour = Color(0XFF01D2042);

var invitationcodecolour = Color(0XFF292B4B);
var listcolor = Color(0xFF2B2E54);
var listselectcolor = Color(0xFF484D87);
var listcolorinner = Color(0xFF3B3F72);
var neturalcolor = Color(0xFFF6F9FC);
var cardcolor = Color(0xFF292C51);
var marketcharcolor1=Color(0xff3F4374);
var marketcharcolor2=Color(0xff3F4374);
var tradechallengbtn=Color(0xff018EF0);

/// trade challenge colour//
var tradegreen=Color(0xff199B56);
 var icongreen=Color(0xff00C7A1);
 var trade_txtColour=Color(0xff4C515E);
 var clipcolor=Color(0xffE1E5F2);
 var tradelistcolor=Color(0xffF7CB1C);
// Referral
var clipCircle = {
  'in_1': Color(0xffF6B708),
  'out_1': Color(0xffFBF317),
  'in_2': Color(0xffD87C5D),
  'out_2': Color(0xffF5BA95),
  'in_3': Color(0xff9DA8B0),
  'out_3': Color(0xffE5E5E5),
};
