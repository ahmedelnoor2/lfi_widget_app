import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class Announcement extends StatefulWidget {
  const Announcement({Key? key}) : super(key: key);

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);

    return Container(
      padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
      child: CarouselSlider(
        options: CarouselOptions(
          scrollDirection: Axis.vertical,
          height: 15,
          viewportFraction: 1,
          enableInfiniteScroll: true,
          enlargeCenterPage: true,
          autoPlay: true,
        ),
        items: public.noticeInfo.map((notice) {
          // var slider = _sliderFrames[i];
          return Builder(
            builder: (BuildContext context) {
              return InkWell(
                onTap: () async {
                  public.setSelectedAnnouncement(notice);
                  Navigator.pushNamed(context, '/announcement_details');
                },
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
                          '${notice['title']}',
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
            },
          );
        }).toList(),
      ),
    );
  }
}
