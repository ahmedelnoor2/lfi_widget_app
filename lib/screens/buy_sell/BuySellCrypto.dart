import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BuySellCrypto extends StatefulWidget {
  static const routeName = '/buy_sell_crypto';
  const BuySellCrypto({Key? key}) : super(key: key);

  @override
  State<BuySellCrypto> createState() => _BuySellCryptoState();
}

class _BuySellCryptoState extends State<BuySellCrypto> {
  late WebViewController _webViewController;
  final String _address = 'myaddress';
  final String _uri =
      'https://changenow.io/embeds/exchange-widget/v2/widget.html?FAQ=true&amount=1500&&fiatMode=true&backgroundColor=1A1D3F&darkMode=true&from=eur&horizontal=false&lang=en-US&link_id=38e0f8626aee4b&locales=true&logo=false&primaryColor=0269ef&to=btc&toTheMoon=false';

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: hiddenAppBar(),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 20),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.chevron_left),
                    ),
                  ),
                  Text(
                    'Exchange Crypto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // SizedBox(
          //   height: height * 0.87,
          //   child: WebView(
          //     //window.document.addEventListener("message", (event) => { Toaster.postMessage("Test message" + event.data ) });
          //     initialUrl: Uri.dataFromString(
          //       '<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><meta http-equiv="X-UA-Compatible" content="ie=edge"></head><body style="background-color:1A1D3F;"><iframe allowfullscreen id="myframe1" frameBorder="0" height="${height * 0.7}" width="${width * 0.965}" src="$_uri"></iframe><script defer type="text/javascript" src="https://changenow.io/embeds/exchange-widget/v2/stepper-connector.js"></script><script>document.addEventListener("DOMContentLoaded", function() {var elmnt = document.getElementsByName("recipient_wallet")[0]; var btTn = document.getElementsByClassName("exchange-form-btn_vertical"); });</script></body></html>',
          //       mimeType: 'text/html',
          //     ).toString(),
          //     // initialUrl: _uri,
          //     gestureNavigationEnabled: true,
          //     debuggingEnabled: true,
          //     backgroundColor: Color.fromARGB(255, 26, 29, 63),
          //     javascriptMode: JavascriptMode.unrestricted,
          //     javascriptChannels: <JavascriptChannel>{
          //       _toasterJavascriptChannel(context),
          //     },
          //     onWebViewCreated: (WebViewController controller) {
          //       setState(() {
          //         _webViewController = controller;
          //       });
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
