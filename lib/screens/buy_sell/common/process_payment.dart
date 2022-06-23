import 'package:flutter/material.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:provider/provider.dart';

import 'package:webview_flutter/webview_flutter.dart';

class ProcessPayment extends StatefulWidget {
  static const routeName = '/process_payment';
  const ProcessPayment({Key? key}) : super(key: key);

  @override
  State<ProcessPayment> createState() => _ProcessPaymentState();
}

class _ProcessPaymentState extends State<ProcessPayment> {
  @override
  Widget build(BuildContext context) {
    var payments = Provider.of<Payments>(context, listen: true);

    return Scaffold(
      appBar: AppBar(),
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: '${payments.changenowTransaction['redirect_url']}',
        onPageStarted: (String url) {
          print('Page started loading: $url');
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
        },
        // gestureNavigationEnabled: true,
      ),
    );
  }
}
