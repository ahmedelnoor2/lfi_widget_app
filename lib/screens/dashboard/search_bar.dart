import 'package:flutter/material.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    Key? key,
    this.handleDrawer,
  }) : super(key: key);

  final handleDrawer;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var _currentRoute = ModalRoute.of(context)!.settings.name;

    return Container(
      padding: EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Navigator.pushNamed(context, '/authentication');
                  if (_currentRoute == '/' || _currentRoute == '/dashboard') {
                    widget.handleDrawer();
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: CircleAvatar(
                  child: Image.asset('assets/img/user.png'),
                  radius: 12,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 20),
                child: SizedBox(
                  width: width * 0.63,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xff292C51),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: Image.asset('assets/img/search.png'),
                        ),
                        Text(
                          'Search LYO',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Image.asset(
                  'assets/img/scanner.png',
                  width: 24,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10),
                child: GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    'assets/img/notification.png',
                    width: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
