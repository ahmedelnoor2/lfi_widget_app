import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';

webPortalURL() async {
  if (kIsWeb) {
    return html.window.open('https://www.lyotrade.com/en_US/', "_self");
  } else {}
}
