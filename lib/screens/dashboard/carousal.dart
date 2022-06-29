import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:webviewx/webviewx.dart';
import 'package:url_launcher/url_launcher.dart';

class Carousal extends StatefulWidget {
  const Carousal({Key? key}) : super(key: key);

  @override
  State<Carousal> createState() => _CarousalState();
}

class _CarousalState extends State<Carousal> {
  late WebViewXController webviewController;
  List _sliderFrames = [
    {
      "link": "frame_1.jpg",
      "path": "/crypto_loan",
    },
    {
      "link": "frame_2.jpg",
      "path": "/staking",
    },
    {
      "link": "frame_3.jpg",
      "path": "/lyowallet",
    },
    {
      "link": "frame_4.jpg",
      "path": "/dex_swap",
    },
    {
      "link": "frame_5.jpg",
      "path": "/faq",
    },
  ];

  void _launchUrl(_url) async {
    final Uri url = Uri.parse(_url);
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return CarouselSlider(
      options: CarouselOptions(
        height: height * 0.12,
        viewportFraction: 1,
        // aspectRatio: 0,
        enableInfiniteScroll: true,
        enlargeCenterPage: true,
        autoPlay: true,
      ),
      items: _sliderFrames.map((slider) {
        // var slider = _sliderFrames[i];

        return Builder(
          builder: (BuildContext context) {
            return InkWell(
              onTap: () {
                if (slider['path'] == '/faq') {
                  _launchUrl(
                      'https://docs.lyotrade.com/introduction/what-is-lyotrade');
                  // js.context.callMethod('open', [
                  //   'https://docs.lyotrade.com/introduction/what-is-lyotrade'
                  // ]);
                  // showModalBottomSheet<void>(
                  //   isScrollControlled: true,
                  //   context: context,
                  //   builder: (BuildContext context) {
                  //     return StatefulBuilder(
                  //       builder:
                  //           (BuildContext context, StateSetter setState) {
                  //         return Scaffold(
                  //           appBar: hiddenAppBarWithDefaultHeight(),
                  //           body: WebViewX(
                  //             width: width,
                  //             height: height * 0.8,
                  //             initialContent:
                  //                 'https://docs.lyotrade.com/introduction/what-is-lyotrade',
                  //             initialSourceType: SourceType.url,
                  //             onWebViewCreated: (controller) =>
                  //                 webviewController = controller,
                  //           ),
                  //         );
                  //       },
                  //     );
                  //   },
                  // );
                } else if (slider['path'] == '/lyowallet') {
                  _launchUrl('https://wallet.lyofi.com');
                } else {
                  Navigator.pushNamed(context, '${slider['path']}');
                }
              },
              child: SizedBox(
                width: width,
                child: Image.asset('assets/img/${slider['link']}'),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
