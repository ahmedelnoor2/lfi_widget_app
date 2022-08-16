
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyotrade/screens/dashboard.dart';

class SpashScreen extends StatefulWidget {
   static const routeName = '/splashScreen';
  const SpashScreen({Key? key}) : super(key: key);

  @override
  State<SpashScreen> createState() => _SpashScreenState();
}

class _SpashScreenState extends State<SpashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }



  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
      Timer(Duration(seconds: 3), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => Dashboard()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width=MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        
    
        constraints: const BoxConstraints.expand(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
             
              padding: EdgeInsets.only(
                top: height * 0.4,
                left: 20,
                right: 20,
              ),
              child: Image.asset('assets/img/logo_s.png',width: width*0.30,),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.only(bottom: height * 0.2),
              child:CircularProgressIndicator(
                color: Colors.blue.shade900,
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
