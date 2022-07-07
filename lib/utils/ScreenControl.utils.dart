import 'dart:io';

import 'package:flutter/material.dart';

Future<bool> onAndroidBackPress(context) async {
  return (await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to exit an App'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => exit(0),
              child: const Text('Yes'),
            ),
          ],
        ),
      )) ??
      false;
}
