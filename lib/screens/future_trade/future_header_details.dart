import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/future_market.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class FutureHeaderDetails extends StatefulWidget {
  const FutureHeaderDetails({Key? key}) : super(key: key);

  @override
  State<FutureHeaderDetails> createState() => _FutureHeaderDetailsState();
}

class _FutureHeaderDetailsState extends State<FutureHeaderDetails>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  final TextEditingController _leverageLevelField = TextEditingController();

  late Timer _timer;
  String _filterType = '';
  var time = DateTime.now();
  DateTime? _timeRange;
  String _countDown = '00:00:00';

  final List _marginModels = [
    {
      'marginModel': 1,
      'name': 'Cross',
      'details':
          'Cross mode: All positions use the whole cross account balance to avoid to be liquidated. If liquidation happens,cross positions and cross balance will be lost.',
    },
    {
      'marginModel': 2,
      'name': 'Isolated',
      'details':
          'Isolated mode:Some balance is allocated to the isolated account. When isolated balance is below maintenance margin, the isolated positions will be liquidated. In this mode, Margin balance can be increased or decreased.',
    },
  ];

  @override
  void initState() {
    _timeRange = DateTime(
      time.year,
      time.month,
      time.day,
      0,
      0,
      0,
      0,
      0,
    );
    startTimer();
    super.initState();
  }

  @override
  void dispose() async {
    _timer.cancel();
    _leverageLevelField.dispose();
    super.dispose();
  }

  void getCountDown(hour) {
    if (hour >= 0 && hour <= 7) {
      var _lastTime = DateTime.now();
      var _remainingDateTime =
          DateTime(time.year, time.month, time.day, 7, 59, 59).subtract(
              Duration(
                  hours: _lastTime.hour,
                  minutes: _lastTime.minute,
                  seconds: _lastTime.second));
      _countDown =
          '${_remainingDateTime.hour}:${_remainingDateTime.minute}:${_remainingDateTime.second}';
    } else if (hour >= 8 && hour <= 15) {
      var _lastTime = DateTime.now();
      var _remainingDateTime =
          DateTime(time.year, time.month, time.day, 15, 59, 59).subtract(
              Duration(
                  hours: _lastTime.hour,
                  minutes: _lastTime.minute,
                  seconds: _lastTime.second));
      _countDown =
          '${_remainingDateTime.hour}:${_remainingDateTime.minute}:${_remainingDateTime.second}';
    } else if (hour >= 16) {
      var _lastTime = DateTime.now();
      var _remainingDateTime =
          DateTime(time.year, time.month, time.day, 23, 59, 59).subtract(
              Duration(
                  hours: _lastTime.hour,
                  minutes: _lastTime.minute,
                  seconds: _lastTime.second));
      _countDown =
          '${_remainingDateTime.hour}:${_remainingDateTime.minute}:${_remainingDateTime.second}';
    }
  }

  void startTimer() {
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);
    setState(() {
      _leverageLevelField.text =
          '${futureMarket.userConfiguration['nowLevel'] ?? ''}';
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        getCountDown(time.hour);
      },
    );
  }

  Future<void> updateMarginMode(marginModelId) async {
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    await futureMarket.updateUserMarginModel(context, auth, {
      'contractId': futureMarket.activeMarket['id'],
      'marginModel': marginModelId,
    });
    await futureMarket.getUserConfiguration(
        context, auth, futureMarket.activeMarket['id']);
  }

  Future<void> updateLeverageLevel(nowLevel) async {
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    await futureMarket.updateLeverageLevel(context, auth, {
      'contractId': futureMarket.activeMarket['id'],
      'nowLevel': nowLevel,
    });
    await futureMarket.getUserConfiguration(
        context, auth, futureMarket.activeMarket['id']);
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: true);
    var futureMarket = Provider.of<FutureMarket>(context, listen: true);

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    auth.isAuthenticated
                        ? showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return marginMode(
                                    context,
                                    futureMarket,
                                    setState,
                                  );
                                },
                              );
                            },
                          )
                        : snackAlert(
                            context,
                            SnackTypes.warning,
                            'Login to trade',
                          );
                  },
                  child: Container(
                      padding: EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xff292C51),
                        ),
                        color: Color(0xff292C51),
                        borderRadius: BorderRadius.all(
                          Radius.circular(2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${futureMarket.userConfiguration['marginModel'] == 1 ? 'Cross' : 'Isolated'}',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: secondaryTextColor,
                          ),
                        ],
                      )),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    auth.isAuthenticated
                        ? showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return leverageLevel(
                                    context,
                                    futureMarket,
                                    setState,
                                  );
                                },
                              );
                            },
                          )
                        : Navigator.pushNamed(context, '/authentication');
                  },
                  child: Container(
                      padding: EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xff292C51),
                        ),
                        color: Color(0xff292C51),
                        borderRadius: BorderRadius.all(
                          Radius.circular(2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${futureMarket.userConfiguration['nowLevel'] ?? double.parse(futureMarket.activeMarket['maxLever'])}x',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: secondaryTextColor,
                          ),
                        ],
                      )),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    // auth.isAuthenticated
                    //     ? showModalBottomSheet<void>(
                    //         context: context,
                    //         builder: (BuildContext context) {
                    //           return StatefulBuilder(
                    //             builder: (BuildContext context,
                    //                 StateSetter setState) {
                    //               return transferAsset(
                    //                 context,
                    //                 public,
                    //                 setState,
                    //               );
                    //             },
                    //           );
                    //         },
                    //       )
                    //     : Navigator.pushNamed(context, '/authentication');
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 4,
                      bottom: 4,
                      left: 6,
                      right: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xff292C51),
                      ),
                      color: Color(0xff292C51),
                      borderRadius: BorderRadius.all(
                        Radius.circular(2),
                      ),
                    ),
                    child: Text(
                      'N',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Funding / 8H',
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryTextColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      futureMarket.marketInfo.isEmpty
                          ? '--%'
                          : '${(double.parse('${futureMarket.marketInfo['currentFundRate']}') * 100).toStringAsFixed(4)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: futureMarket.marketInfo.isEmpty
                            ? Colors.white
                            : double.parse(
                                        '${futureMarket.marketInfo['currentFundRate']}') >=
                                    0
                                ? greenIndicator
                                : redIndicator,
                      ),
                    ),
                    Text(
                      '/$_countDown',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget marginMode(context, futureMarket, setState) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(10),
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Margin Mode',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  size: 20,
                ),
              )
            ],
          ),
          TabBar(
            onTap: (value) {
              // print(value);
              setState(() {
                _tabController.index = value;
              });
            },
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            tabs: _marginModels
                .map<Tab>((model) => Tab(text: '${model['name']}'))
                .toList(),
            controller: _tabController,
          ),
          SizedBox(
            height: height * 0.4,
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: width,
                      child: Text(
                        'Cross mode: All positions use the whole cross account balance to avoid to be liquidated. If liquidation happens,cross positions and cross balance will be lost.',
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          futureMarket.userConfiguration['marginModel'] == 1
                              ? null
                              : () {
                                  updateMarginMode(1);
                                  Navigator.pop(context);
                                },
                      child: Text('Switch to Cross Mode'),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: width,
                      child: Text(
                        'Isolated mode:Some balance is allocated to the isolated account. When isolated balance is below maintenance margin, the isolated positions will be liquidated. In this mode, Margin balance can be increased or decreased.',
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          futureMarket.userConfiguration['marginModel'] == 2
                              ? null
                              : () {
                                  updateMarginMode(2);
                                  Navigator.pop(context);
                                },
                      child: Text('Switch to Isolated Mode'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget leverageLevel(context, futureMarket, setState) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(10),
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${futureMarket.activeMarket['symbol']} Contract Leverage Level',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  size: 20,
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xff292C51),
              ),
              color: Color(0xff292C51),
              borderRadius: BorderRadius.all(
                Radius.circular(2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _leverageLevelField.text =
                          '${int.parse(_leverageLevelField.text) - 1}';
                    });
                  },
                  child: Icon(
                    Icons.remove,
                    color: Color(0xff5E6292),
                  ),
                ),
                SizedBox(
                  width: width * 0.5,
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _leverageLevelField.text = '${int.parse(value)}';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Leverage level required to update.';
                      }
                      return null;
                    },
                    controller: _leverageLevelField,
                    style: TextStyle(fontSize: 16),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      errorStyle: TextStyle(height: 0),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 16,
                      ),
                      hintText:
                          "Leverage Level ${futureMarket.userConfiguration['nowLevel']}",
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _leverageLevelField.text =
                          '${int.parse(_leverageLevelField.text) + 1}';
                    });
                  },
                  child: Icon(
                    Icons.add,
                    color: Color(0xff5E6292),
                  ),
                ),
              ],
            ),
          ),
          SfSlider(
            min: double.parse('${futureMarket.userConfiguration['minLevel']}'),
            max: double.parse('${futureMarket.userConfiguration['maxLevel']}'),
            value: _leverageLevelField.text.isEmpty
                ? 1.0
                : double.parse(_leverageLevelField.text),
            interval: 31,
            showTicks: true,
            showLabels: true,
            enableTooltip: true,
            onChanged: (dynamic value) {
              setState(() {
                _leverageLevelField.text =
                    '${int.parse('${value.toStringAsFixed(0)}')}';
              });
            },
          ),
          Container(
            padding: EdgeInsets.only(top: 15),
            child: Row(
              children: [
                Text('Max holding amount is about ',
                    style: TextStyle(fontSize: 15)),
                Text(
                  '${futureMarket.userConfiguration['leverCeiling']['${_leverageLevelField.text}']} Cont.',
                  style: TextStyle(fontSize: 15, color: Colors.amber),
                )
              ],
            ),
          ),
          Container(
            width: width,
            padding: EdgeInsets.only(top: 10),
            child: ElevatedButton(
              onPressed: () {
                updateLeverageLevel(_leverageLevelField.text);
                Navigator.pop(context);
              },
              child: Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}
