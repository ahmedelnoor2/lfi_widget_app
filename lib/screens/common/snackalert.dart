import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

getBgColor(type) {
  var color = Colors.blue;

  switch (type) {
    case SnackTypes.errors:
      color = errorColor;
      break;
    case SnackTypes.success:
      color = successColor;
      break;
    case SnackTypes.warning:
      color = warningColor;
      break;
  }

  return color;
}

snackAlert(ctx, type, message) {
  ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
  return ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      backgroundColor: getBgColor(type),
      content: Text(
        '$message',
        style: TextStyle(
          color: type == SnackTypes.warning ? Colors.black : whiteTextColor,
        ),
      ),
      action: SnackBarAction(
        label: 'Close',
        textColor: type == SnackTypes.warning ? Colors.black : whiteTextColor,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    ),
  );
}
