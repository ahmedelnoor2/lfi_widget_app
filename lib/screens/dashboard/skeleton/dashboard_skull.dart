import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import 'package:lyotrade/utils/AppConstant.utils.dart';

Widget liveFeedSkull(context) {
  height = MediaQuery.of(context).size.height;
  width = MediaQuery.of(context).size.width;
  var list = List<int>.generate(3, (i) => i + 1);

  return Column(
    children: [
      Container(
        height: height * 0.125,
        padding: EdgeInsets.all(width * 0.05),
        child: SizedBox(
          child: Container(
            padding: EdgeInsets.only(right: width * 0.01),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: width * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: list
                        .map(
                          (e) => SizedBox(
                            height: height * 0.07,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SkeletonLine(
                                  style: SkeletonLineStyle(
                                      height: 10,
                                      width: width * 0.25,
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                SkeletonLine(
                                  style: SkeletonLineStyle(
                                      height: 15,
                                      width: width * 0.25,
                                      borderRadius: BorderRadius.circular(8)),
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
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Widget assetsInfoSkull(context) {
  var list = List<int>.generate(7, (i) => i + 1);

  return SizedBox(
    child: Card(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: width * 0.025,
              right: width * 0.025,
              left: width * 0.025,
            ),
            child: Column(
              children: list
                  .map(
                    (e) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: width * 0.05),
                          width: width * 0.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  shape: BoxShape.circle,
                                  width: width * 0.10,
                                  height: width * 0.10,
                                ),
                              ),
                              SkeletonLine(
                                style: SkeletonLineStyle(
                                  height: 15,
                                  width: width * 0.6,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
