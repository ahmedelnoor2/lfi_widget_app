import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

Future<bool> onAndroidBackPress(context) async {
  return (await showDialog(
        context: context,
        builder: (context) => AlertDialog(
    backgroundColor: Colors.white,
          titleTextStyle: TextStyle(),
          title: const Text('Exit APP',style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w700),),
          content: const Text('Do you want to exit an App?',style: TextStyle(color: Colors.black),),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  
                color: buttonBGColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(5, 5),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
             GestureDetector(
              onTap: () {
                 exit(0);
              },
              child: Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                color: buttonBGColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(5, 5),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          
          ],
        ),
      )) ??
      false;
}
