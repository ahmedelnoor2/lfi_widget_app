import 'package:flutter/material.dart';

class Hotlinks extends StatefulWidget {
  const Hotlinks({Key? key}) : super(key: key);

  @override
  State<Hotlinks> createState() => _HotlinksState();
}

class _HotlinksState extends State<Hotlinks> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Image.asset(
                    'assets/img/new_listing.png',
                    width: 28,
                  ),
                ),
                Text(
                  'New Listing',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Image.asset(
                    'assets/img/refer.png',
                    width: 28,
                  ),
                ),
                Text(
                  'Referral',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Image.asset(
                    'assets/img/deposit_pig.png',
                    width: 28,
                  ),
                ),
                Text(
                  'Deposit',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Image.asset(
                    'assets/img/bot.png',
                    width: 28,
                  ),
                ),
                Text(
                  'Trading Bot',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Image.asset(
                    'assets/img/applications.png',
                    width: 28,
                  ),
                ),
                Text(
                  'More',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
