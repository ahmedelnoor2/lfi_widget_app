import 'package:flutter/material.dart';

import 'package:lyotrade/screens/common/header.dart';

import 'package:lyotrade/utils/Colors.utils.dart';

class Kycscreen extends StatefulWidget {
  static const routeName = '/Kycscreen_screen';
  @override
  State<StatefulWidget> createState() => _KycscreenState();
}

class _KycscreenState extends State<Kycscreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: hiddenAppBar(),
        body: Column(children: [
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
                    'Kyc',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(thickness: 1, height: 1),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              GestureDetector(
                onTap: (() {
                  Navigator.pushNamed(context, '/personalverification');
                }),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 62,
                  color: selectboxcolour,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Personal Verification',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Text('Complete your KYC..',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: natuaraldark)),
                        ),
                      ]),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: (() {
                  Navigator.pushNamed(context, '/entityverification');
                }),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 62,
                  color: selectboxcolour,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Entity Verification',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Text('Complete your KYC..',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: natuaraldark)),
                        ),
                      ]),
                ),
              ),
            ]),
          )
        ]));
  }
}
