import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import 'package:lyotrade/utils/AppConstant.utils.dart';

Widget depositQrSkull(context) {
  width = MediaQuery.of(context).size.width;

  return SkeletonAvatar(
    style: SkeletonAvatarStyle(
      shape: BoxShape.rectangle,
      width: width * 0.5,
      height: width * 0.3,
    ),
  );
}

Widget depositAddressSkull(context) {
  width = MediaQuery.of(context).size.width;

  return SizedBox(
    width: width * 0.75,
    child: SkeletonLine(
      style: SkeletonLineStyle(
        height: 15,
        width: width,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
