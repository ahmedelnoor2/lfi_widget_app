import 'package:flutter/material.dart';

Future<void> showAlert(context, title, message, action) async {
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
                  child: const Icon(
                    Icons.featured_play_list,
                  ),
                ),
                Text(
                  '$title',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
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
