import 'package:flutter/material.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

class Announcement extends StatefulWidget {
  const Announcement({Key? key}) : super(key: key);

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: 10),
                height: 16,
                child: Image.asset('assets/img/announcement.png'),
              ),
              Text(
                'LYO Credit is now listed on Coingecko',
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryTextColor,
                ),
              )
            ],
          ),
          GestureDetector(
            child: Image.asset('assets/img/list.png'),
          )
        ],
      ),
    );
  }
}
