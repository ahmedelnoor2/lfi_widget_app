import 'package:flutter/material.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

class LyoButton extends StatelessWidget {
  const LyoButton({
    Key? key,
    this.text,
    this.active,
    this.activeColor = const Color(0xff5E6292),
    this.activeTextColor = Colors.white,
    this.isLoading = false,
    required VoidCallback? this.onPressed,
  }) : super(key: key);

  final text;
  final active;
  final isLoading;
  final onPressed;
  final activeColor;
  final activeTextColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          // color: Color(0xff5E6292),
          color: (!active || isLoading) ? Color(0xff292C51) : activeColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            // style: BorderStyle.solid,
            width: 0,
            // color: Color(0xff5E6292),
            color: (!active || isLoading) ? Colors.transparent : activeColor,
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  height: 25,
                  width: 25,
                )
              : Text(
                  '$text',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: !active ? secondaryTextColor : activeTextColor,
                  ),
                ),
        ),
      ),
    );
  }
}
