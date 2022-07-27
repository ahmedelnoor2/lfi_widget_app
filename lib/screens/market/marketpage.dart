
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lyotrade/screens/market/pages/favourite_page.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

class MarketPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  var _pages = [
    FavouritePage(),
    FavouritePage(),
    FavouritePage(),
    
  ];

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
    
      body: Container(
     
        child: Column(
        
          children: [
           PreferredSize(

          preferredSize: Size.fromHeight(40),
          child:Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              
              isScrollable: true,
              controller: _tabController,
              labelColor: whiteTextColor,
              indicatorColor: selecteditembordercolour,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 1.75,
              indicatorPadding: EdgeInsets.symmetric(horizontal: 14.0),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: _size.width / 28.0,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: _size.width / 28.0,
              ),
              tabs: [
                Container(
                  width: _size.width * .2,
                  child: Tab(
                    text: 'USDT',
                  ),
                ),
                Container(
                  width: _size.width * .15,
                  child: Tab(
                    text: 'BTC',
                  ),
                ),
                Container(
                  width: _size.width * .15,
                  child: Tab(
                    text: 'ETH',
                  ),
                ),
                
                
              ],
            ),
          ),
        ),
             Divider(thickness: 1,height: 1),

             
            _buildTopBar(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _pages.map((Widget tab) {
                  return tab;
                }).toList(),
              ),
            ),
           
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(context) {
    final _size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'COIN',
              style: TextStyle(
                fontSize: _size.width / 30.0,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Price(USDT)',
                  style: TextStyle(
                    fontSize: _size.width / 30.0,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w400,
                  ),
                ),
               
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '24 h Change',
                  style: TextStyle(
                    fontSize: _size.width / 30.0,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w400,
                  ),
                ),
               
              ],
            ),
          ),
        ],
      ),
    );
  }
}
