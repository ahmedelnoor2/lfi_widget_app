 import 'package:flutter/material.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
 double _letterSpacing = 0.3;
var darkThemeData =ThemeData(
        
              brightness: Brightness.dark,
              appBarTheme: AppBarTheme(
                backgroundColor: Color.fromARGB(255, 26, 29, 63),
              ),
              fontFamily: 'Yantramanav',
              // bottomAppBarTheme: BottomAppBarTheme(
              //   color: Color.fromARGB(255, 26, 29, 63),
              // ),
              // bottomAppBarColor: Color.fromARGB(255, 26, 29, 63),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Color.fromARGB(255, 26, 29, 63),
                selectedItemColor: Color.fromARGB(255, 1, 254, 246),
                unselectedItemColor: secondaryTextColor,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
              ),
              bottomSheetTheme: BottomSheetThemeData(
                backgroundColor: Color.fromARGB(255, 26, 29, 63),
              ),
              primarySwatch:
                  createMaterialColor(Color.fromARGB(255, 1, 254, 246)),
              scaffoldBackgroundColor: Color.fromARGB(255, 26, 29, 63),
              backgroundColor: Color.fromARGB(255, 26, 29, 63),
              textTheme: TextTheme(
                headline1: TextStyle(
                    fontSize: 72.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: _letterSpacing,
                    color: Colors.white),
                headline2: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                headline3: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                headline4: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                headline5: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                headline6: TextStyle(
                  fontSize: 36.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                bodyText2: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                bodyText1: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                subtitle1: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                caption: TextStyle(
                  color: secondaryTextColor,
                  letterSpacing: _letterSpacing,
                ),
                button: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
                overline: TextStyle(
                  color: Colors.white,
                  letterSpacing: _letterSpacing,
                ),
              ),
              drawerTheme: DrawerThemeData(
                backgroundColor: Color.fromARGB(255, 26, 29, 63),
              ),
              cardTheme: CardTheme(
                color: Color.fromARGB(255, 41, 44, 81),
              ),
              iconTheme: IconThemeData().copyWith(color: Colors.white),
              primaryIconTheme: IconThemeData().copyWith(color: Colors.white),
              inputDecorationTheme: InputDecorationTheme(
                  // enabledBorder: UnderlineInputBorder(
                  //   borderSide: BorderSide(
                  //     color: secondaryTextColor,
                  //   ),
                  // ),
                  // focusedBorder: UnderlineInputBorder(
                  //   borderSide: BorderSide(
                  //     color: Color.fromARGB(255, 1, 254, 246),
                  //   ),
                  // ),
                  // border: UnderlineInputBorder(
                  //   borderSide: BorderSide(
                  //     color: Color.fromARGB(255, 1, 254, 246),
                  //   ),
                  // ),
                  // labelStyle: TextStyle(color: Colors.white),
                  ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(0, 35),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );

  
  var lightThemeData  = ThemeData(
      primaryColor: Colors.blue,
      textTheme: new TextTheme(button: TextStyle(color: Colors.black54)),
      brightness: Brightness.light,
      accentColor: Colors.blue
      );