import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import 'package:lyotrade/utils/AppConstant.utils.dart';

Widget assetsSkull(context) {
  width = MediaQuery.of(context).size.width;
  var list = List<int>.generate(7, (i) => i + 1);

  return ListView.builder(
    padding: EdgeInsets.zero,
    itemCount: list.length,
    itemBuilder: (BuildContext context, int index) {
      return Container(
        padding: EdgeInsets.only(
          bottom: 8,
          left: 5,
          right: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: width * 0.33,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 8),
                    child: SkeletonAvatar(
                      style: SkeletonAvatarStyle(
                        shape: BoxShape.circle,
                        width: 24,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: SkeletonLine(
                          style: SkeletonLineStyle(
                              height: 10,
                              width: width * 0.15,
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      SkeletonLine(
                        style: SkeletonLineStyle(
                            height: 10,
                            width: width * 0.15,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              width: width * 0.27,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SkeletonLine(
                  style: SkeletonLineStyle(
                      height: 10,
                      width: width * 0.15,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            SizedBox(
              width: width * 0.22,
              child: Align(
                  alignment: Alignment.center,
                  child: SkeletonLine(
                    style: SkeletonLineStyle(
                        height: 10,
                        width: width * 0.15,
                        borderRadius: BorderRadius.circular(8)),
                  )),
            ),
            SizedBox(
              width: width * 0.10,
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 5),
                      child: SkeletonLine(
                        style: SkeletonLineStyle(
                            height: 10,
                            width: width * 0.15,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                          height: 10,
                          width: width * 0.15,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
          ],
        ),
      );
    },
  );
}

Widget marketFeedSkull(context) {
  width = MediaQuery.of(context).size.width;
  var list = List<int>.generate(3, (i) => i + 1);

  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: EdgeInsets.only(left: 5, bottom: 5),
        child: Text(
          'Markets',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(
        height: width * 0.26,
        width: width,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: list.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                print('object');
              },
              child: Container(
                width: width * 0.32,
                padding: EdgeInsets.all(5),
                child: SkeletonLine(
                  style: SkeletonLineStyle(
                    height: width * 0.26,
                    width: width * 0.30,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget priceSkull(context) {
  width = MediaQuery.of(context).size.width;

  return SizedBox(
    width: width * 0.1,
    child: SkeletonLine(
      style: SkeletonLineStyle(
        height: 10,
        width: width,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
