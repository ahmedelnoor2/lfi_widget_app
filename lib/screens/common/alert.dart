import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showAlert(context, icon, title, message, action) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 5),
                  child: icon,
                ),
                Text(
                  '$title',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                if (action == 'Exit') {
                  exit(0);
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(
                Icons.close,
                size: 15,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: message,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('$action'),
            onPressed: () {
              if (action == 'Settings') {
                Navigator.pushNamed(context, '/security');
              } else if (action == 'Exit') {
                exit(0);
              } else if (action == 'Cancel Transaction') {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}
