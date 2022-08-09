import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';

import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class personalverification extends StatefulWidget {
  static const routeName = '/personalverification';
  @override
  State<StatefulWidget> createState() => _personalverificationState();
}

class _personalverificationState extends State<personalverification>
    with SingleTickerProviderStateMixin {
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    getKycTierList();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> getKycTierList() async {
    setState(() {
      _processing = true;
    });

    var auth = Provider.of<Auth>(context, listen: false);
    await auth.getPersonalKycTiers(context, {'type': '0'});

    setState(() {
      _processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);

    print(auth.personalKycTiers['userInfoList']);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: _processing
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 20),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.chevron_left),
                            ),
                          ),
                          Text(
                            'Personal Verification',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children: auth.personalKycTiers['list']
                          .map<Widget>(
                            (kycTier) => Card(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                width: width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${kycTier['levelName']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(),
                                    Text(
                                      'Requirements',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                        bottom: 5,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: kycTier[
                                                'requirementsReferenceStrList']
                                            .map<Widget>(
                                              (requirement) => Container(
                                                padding:
                                                    EdgeInsets.only(bottom: 5),
                                                child: Text(
                                                  '* $requirement',
                                                  style: TextStyle(
                                                      color:
                                                          secondaryTextColor),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Crypto Deposit Limit'),
                                              Text(
                                                'Unlimited',
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Crypto Withdrawal Limit'),
                                              Text(
                                                '${kycTier['withdrawLimitAmount']} ${kycTier['withdrawLimitSymbol']} Daily',
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('P2P Transaction Limits'),
                                              Text(
                                                'Unlimited',
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    LyoButton(
                                      onPressed: () {},
                                      text: 'Start Now',
                                      active: true,
                                      isLoading: false,
                                    ),
                                  ],
                                ),
                              ),
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
}
