import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/dashboard.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/responsive_layout.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<SliderModel> slides = [];
  int currentIndex = 0;
  PageController? _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = PageController(initialPage: 0);
    slides = getSlides();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void goHomepage(context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/splashScreen', (route) => false);
    //Navigate to home page and remove the intro screen history
    //so that "Back" button wont work.
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (MediaQuery.of(context).size.width >= 550) {
      webPortalURL();
    }
    return MediaQuery.of(context).size.width >= 550
        ? Container()
        : Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50, right: 30),
                  child: InkWell(
                    onTap: () {
                      goHomepage(context);
                    },
                    child: const Text(
                      'Skip',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (value) {
                        setState(() {
                          currentIndex = value;
                        });
                      },
                      itemCount: slides.length,
                      itemBuilder: (context, index) {
                        // contents of slider
                        return Slider(
                          image: slides[index].getImage(),
                          title: slides[index].getTitle(),
                          description: slides[index].getDescription(),
                        );
                      }),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                ),
                currentIndex == slides.length - 1
                    ? Container(
                        height: height,
                        margin: EdgeInsets.all(30),
                        width: double.infinity,
                        color: linkColor,
                        child: LyoButton(
                          text: 'Get Started',
                          active: true,
                          activeColor: linkColor,
                          activeTextColor: Colors.black,
                          onPressed: () {
                            goHomepage(context);
                          },
                        ),
                      )
                    : Container(
                        height: 40,
                      ),
              ],
            ),
          );
  }

  // container created for dots
  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index ? linkColor : seconadarytextcolour,
      ),
    );
  }
}

// ignore: must_be_immutable
// slider declared
class Slider extends StatelessWidget {
  String? image;
  String? title;
  String? description;
  Slider({this.image, this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // image given in slider
          Image(image: AssetImage(image!)),

          Text(title!,
              style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16.0,
                    color: onboardText,
                    fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }
}

class SliderModel {
  String? image;
  String? title;
  String? description;

  // Constructor for variables
  SliderModel({this.title, this.description, this.image});

  void setImage(String getImage) {
    image = getImage;
  }

  void setTitle(String getTitle) {
    title = getTitle;
  }

  void setDescription(String getDescription) {
    description = getDescription;
  }

  String? getImage() {
    return image;
  }

  String? getTitle() {
    return title;
  }

  String? getDescription() {
    return description;
  }
}

// List created
List<SliderModel> getSlides() {
  // ignore: deprecated_member_use
  List<SliderModel> slides = [];
  SliderModel sliderModel = new SliderModel();

  // Item 1
  sliderModel.setImage("assets/img/Group1.png");
  sliderModel.setTitle("Easy Exchange");
  sliderModel.setDescription(
      "LYOTRADE services refers to various services provided to you such as Virtual Spot Wallet, Crypto-Crypto Spot Trading and Exchange services");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  // Item 2
  sliderModel.setImage("assets/img/Group2.png");
  sliderModel.setTitle("Virtual Asset");
  sliderModel.setDescription(
      "A virtual asset service provider that combines international exchanges ecosystem platforms with a robust liquidity system with over 300 partners worldwide.");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  // Item 3
  sliderModel.setImage("assets/img/Group3.png");
  sliderModel.setTitle("Future Trading");
  sliderModel.setDescription(
      "Future Contract is an agreement to buy or sell an asset at a future date for a fixed price. Generally, it is used by traders to lock in profits when trading in volatile markets.");
  slides.add(sliderModel);

  sliderModel = new SliderModel();
  return slides;
}
