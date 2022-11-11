import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

class ResponsiveLayout extends StatelessWidget {
  final Widget computer;

  const ResponsiveLayout({
    required this.computer,
  });

  static final int largeTabletLimit = 550;

  static bool isComputer(BuildContext context) =>
      MediaQuery.of(context).size.width >= largeTabletLimit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return computer;
      },
    );
  }
}

webPortalURL() async {
  return html.window.open('https://www.lyotrade.com/en_US/',"_self");
}