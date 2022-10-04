import 'package:flutter/material.dart';

Widget noData(text) {
  return Container(
    padding: EdgeInsets.only(top: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Text(text)],
    ),
  );
}
