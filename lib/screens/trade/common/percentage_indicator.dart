import 'dart:math' as math;
import 'package:flutter/material.dart';

class SemiCircleWidget extends StatelessWidget {
  final double? diameter;
  final double? sweepAngle;
  final Color? color;

  const SemiCircleWidget({
    Key? key,
    this.diameter = 100,
    @required this.sweepAngle,
    @required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MyPainter(sweepAngle, color),
      size: Size(diameter!, diameter!),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter(this.sweepAngle, this.color);
  final double? sweepAngle;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 3.5 // 1.
      ..style = PaintingStyle.stroke // 2.
      ..color = color!; // 3.

    double degToRad(double deg) => deg * (math.pi / 50.01);

    final path = Path()
      ..arcTo(
          // 4.
          Rect.fromCenter(
            center: Offset(size.height / 10, size.width / 10),
            height: 35,
            width: 35,
          ), // 5.
          degToRad(0), // 6.
          degToRad(sweepAngle!), // 7.
          false);

    canvas.drawPath(path, paint); // 8.
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
