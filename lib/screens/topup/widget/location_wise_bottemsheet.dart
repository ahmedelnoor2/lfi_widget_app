import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/providers/topup.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class LocationWiseBottomsheet extends StatefulWidget {
  const LocationWiseBottomsheet({Key? key}) : super(key: key);

  @override
  State<LocationWiseBottomsheet> createState() =>
      _LocationWiseBottomsheetState();
}

class _LocationWiseBottomsheetState extends State<LocationWiseBottomsheet> {
  @override
  Widget build(BuildContext context) {
    var topupProvider = Provider.of<TopupProvider>(context, listen: true);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      width: width,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Select State',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: topupProvider
                  .toActiveNetWorkprovider['geographicalRechargePlans'].length,
              itemBuilder: (context, index) {
                var currentindex = topupProvider
                        .toActiveNetWorkprovider['geographicalRechargePlans']
                    [index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          
                          topupProvider.setactivestate(currentindex);
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(17.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 40.0,
                                ),
                                child: Text(
                                  currentindex['locationName'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xff00315C),
                                      fontSize: 14.0,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600),
                                  // textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
