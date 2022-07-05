import 'package:flutter/material.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:provider/provider.dart';
import 'package:webviewx/webviewx.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class ProcessPayment extends StatefulWidget {
  static const routeName = '/process_payment';
  const ProcessPayment({Key? key}) : super(key: key);

  @override
  State<ProcessPayment> createState() => _ProcessPaymentState();
}

class _ProcessPaymentState extends State<ProcessPayment> {
  WebViewXController? _controller;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var payments = Provider.of<Payments>(context, listen: true);

    return Scaffold(
      appBar: AppBar(),
      body: WebViewX(
        key: const ValueKey('webviewx'),
        height: height,
        width: width,
        initialContent: '${payments.changenowTransaction['redirect_url']}',
        initialSourceType: SourceType.url,
        onWebViewCreated: (controller) => _controller = controller,
        onPageStarted: (src) =>
            debugPrint('A new page has started loading: $src\n'),
        onPageFinished: (src) =>
            debugPrint('The page has finished loading: $src\n'),
      ),
    );
  }
}
