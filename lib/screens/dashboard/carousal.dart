import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:webviewx/webviewx.dart';
import 'package:url_launcher/url_launcher.dart';

class Carousal extends StatefulWidget {
  const Carousal({Key? key}) : super(key: key);

  @override
  State<Carousal> createState() => _CarousalState();
}

class _CarousalState extends State<Carousal> {
  late WebViewXController webviewController;
  final List _sliderFrames = [
    {
      "file": {"link": "frame_1.jpg"},
      "link": "/crypto_loan",
    },
    {
      "file": {"link": "frame_2.jpg"},
      "link": "/staking",
    },
    {
      "file": {"link": "frame_3.jpg"},
      "link": "https://wallet.lyofi.com",
    },
    {
      "file": {"link": "frame_4.jpg"},
      "link": "https://t.me/lyoswapbot",
    },
    {
      "file": {"link": "frame_5.jpg"},
      "link": "https://docs.lyotrade.com/introduction/what-is-lyotrade",
    },
  ];

  void _launchUrl(_url) async {
    final Uri url = Uri.parse(_url);
    try {
      if (!await launchUrl(url)) {
        if (_url == '/crypto_loan') {
          snackAlert(context, SnackTypes.warning, 'Coming Soon...');
        } else {
          Navigator.pushNamed(context, _url);
        }
      }
    } catch (e) {
      if (_url == '/crypto_loan') {
        snackAlert(context, SnackTypes.warning, 'Coming Soon...');
      } else {
        Navigator.pushNamed(context, _url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);

    List sliders = [];
    if (public.banners.isEmpty) {
      sliders = _sliderFrames;
    } else {
      sliders = public.banners;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 110,
          viewportFraction: 1,
          enableInfiniteScroll: true,
          enlargeCenterPage: true,
          autoPlay: true,
        ),
        items: sliders.map(
          (slider) {
            // var slider = _sliderFrames[i];
            return Builder(
              builder: (BuildContext context) {
                return InkWell(
                  onTap: () {
                    _launchUrl(
                      '${slider['link']}',
                    );
                  },
                  child: Container(
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        style: BorderStyle.solid,
                        width: 0.3,
                        color: Color(0xff5E6292),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: public.banners.isEmpty
                          ? Image.asset(
                              'assets/img/${slider['file']['link']}',
                              fit: BoxFit.fill,
                            )
                          : Image.network(
                              '${slider['file']['link']}',
                              fit: BoxFit.fill,
                            ),
                    ),
                  ),
                );
              },
            );
          },
        ).toList(),
      ),
    );
  }
}
