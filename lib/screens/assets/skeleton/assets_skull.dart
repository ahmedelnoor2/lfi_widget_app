import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import 'package:lyotrade/utils/AppConstant.utils.dart';

Widget assetsSkull(context) {
  width = MediaQuery.of(context).size.width;
  var list = List<int>.generate(3, (i) => i + 1);

  return ListView.builder(
    padding: EdgeInsets.zero,
    itemCount: list.length,
    itemBuilder: (BuildContext context, int index) {
      return Card(
        child: Container(
          padding: EdgeInsets.all(width * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: width * 0.02),
                          child: SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                              shape: BoxShape.circle,
                              width: width * 0.1,
                            ),
                          ),
                        ),
                        SkeletonLine(
                          style: SkeletonLineStyle(
                              height: 25,
                              width: width * 0.2,
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: width * 0.035),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: width * 0.18,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLine(
                            style: SkeletonLineStyle(
                                height: 12,
                                width: width * 0.1,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          SkeletonLine(
                            style: SkeletonLineStyle(
                                height: 18,
                                width: width * 0.2,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          SkeletonLine(
                            style: SkeletonLineStyle(
                                height: 12,
                                width: width * 0.1,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: width * 0.18,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLine(
                            style: SkeletonLineStyle(
                                height: 12,
                                width: width * 0.1,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          SkeletonLine(
                            style: SkeletonLineStyle(
                                height: 18,
                                width: width * 0.2,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          SkeletonLine(
                            style: SkeletonLineStyle(
                                height: 12,
                                width: width * 0.1,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: width * 0.18,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SkeletonLine(
                            style: SkeletonLineStyle(
                                height: 12,
                                width: width * 0.1,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          SkeletonLine(
                            style: SkeletonLineStyle(
                                height: 18,
                                width: width * 0.2,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          SkeletonLine(
                            style: SkeletonLineStyle(
                                height: 12,
                                width: width * 0.1,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
