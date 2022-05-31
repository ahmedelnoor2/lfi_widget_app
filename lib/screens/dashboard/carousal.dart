import 'package:flutter/material.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Carousal extends StatefulWidget {
  const Carousal({Key? key}) : super(key: key);

  @override
  State<Carousal> createState() => _CarousalState();
}

class _CarousalState extends State<Carousal> {
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(
        bottom: 10,
      ),
      child: CarouselSlider(
        options: CarouselOptions(
          height: height * 0.12,
          viewportFraction: 1,
          enlargeCenterPage: false,
          autoPlay: true,
        ),
        items: [1, 2, 3].map((i) {
          return Builder(
            builder: (BuildContext context) {
              return SizedBox(
                width: width,
                child: Image.asset('assets/img/timeline.png'),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
