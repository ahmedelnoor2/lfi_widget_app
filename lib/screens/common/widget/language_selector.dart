import 'package:flutter/material.dart';
import 'package:lyotrade/providers/language_provider.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class LanguageSelector extends StatelessWidget {
  final bool? isActive;
  final String? language;
  final String? imagePath;
  final String? id;
  LanguageSelector(
      {required this.isActive, this.language, this.imagePath, this.id});
  @override
  Widget build(BuildContext context) {
    var languageprovider = Provider.of<LanguageChange>(context, listen: true);
    return InkWell(
      child:Container(
        margin: EdgeInsets.only(bottom: 10.0),
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        width: double.infinity,
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(169, 176, 185, 0.42),
              spreadRadius: 0,
              blurRadius: 8,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: cardcolor,
                radius: 25.0,
                child: Text(
                  imagePath.toString(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                this.language!,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Color.fromRGBO(34, 40, 60, 1),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
            Container(
                child: isActive!
                    ? Icon(
                        Icons.check_circle,
                        size: 30,
                        color: bluechartColor,
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
