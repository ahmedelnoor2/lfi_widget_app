import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/future_market.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/screens/future_trade/common/leverage_level.dart';
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

  int _activePositionMode = 1;
  final List _positionModes = [
    {
      'positionMode': 1,
      'name': 'Netting Mode',
      'details': 'Only buy or sell side position exists in netting mode',
    },
    {
      'positionMode': 2,
      'name': 'Hadging Mode',
      'details': 'Both buy and sell side position can exist in hedging mode',
    },
  ];

  int _activeContractUnit = 1;
  List _contractUnit = [
    {
      'mode': 1,
      'name': 'Cont.',
    },
    {
      'mode': 2,
      'name': 'BTC',
    },
  ];

  int _activeStopOrderPref = 14;
  final List _stopOrderPreferences = [
    {
      'mode': 4,
      'name': '4 Hour',
    },
    {
      'mode': 7,
      'name': '7 Days',
    },
    {
      'mode': 14,
      'name': '14 Days',
    },
    {
      'mode': 30,
      'name': '30 Days',
    },
  ];

  bool _secondOrderConfirmation = true;

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
    setUserConfigurations();
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

  void setUserConfigurations() {
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);

    if (futureMarket.userConfiguration.isNotEmpty) {
      setState(() {
        _activeContractUnit = futureMarket.userConfiguration['coUnit'];
        _activeStopOrderPref = futureMarket.userConfiguration['expireTime'];
        _secondOrderConfirmation =
            futureMarket.userConfiguration['pcSecondConfirm'] == 0
                ? false
                : true;
        _activePositionMode = futureMarket.userConfiguration['positionModel'];
        _contractUnit = [
          {
            'mode': 1,
            'name': 'Cont.',
          },
          {
            'mode': 2,
            'name': '${futureMarket.activeMarket['base']}',
          },
        ];
      });
    }
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
    setUserConfigurations();
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
    setUserConfigurations();
  }

  Future<void> updateUserConfig() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var futureMarket = Provider.of<FutureMarket>(context, listen: false);

    if (auth.isAuthenticated) {
      Map formData = {
        'coUnit': _activeContractUnit,
        'contractId': futureMarket.activeMarket['id'],
        'expireTime': _activeStopOrderPref,
        'pcSecondConfirm': _secondOrderConfirmation ? 1 : 0,
        'positionModel': _activePositionMode,
      };
      await futureMarket.updateUserConfigs(context, auth, formData);
      await futureMarket.getUserConfiguration(
          context, auth, futureMarket.activeMarket['id']);
      setUserConfigurations();
    }
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
                                    _leverageLevelField,
                                    updateLeverageLevel,
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
                            '${futureMarket.userConfiguration['nowLevel'] ?? double.parse('${futureMarket.activeMarket['maxLever'] ?? 0.0}')}x',
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
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return preferenceUpdate(
                              context,
                              futureMarket,
                              setState,
                            );
                          },
                        );
                      },
                    );
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

  Widget preferenceUpdate(context, futureMarket, setState) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(
        top: 10,
        right: 10,
        left: 10,
        bottom: 30,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preferences',
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
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Position Mode:'),
              Text(
                'Note: Can not change when any position or order exists',
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              )
            ],
          ),
          Divider(),
          Column(
            children: _positionModes
                .map(
                  (positionMode) => Container(
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xff292C51),
                      ),
                      // color: Color(0xff292C51),
                      borderRadius: BorderRadius.all(
                        Radius.circular(2),
                      ),
                    ),
                    child: ListTile(
                      title: Text('${positionMode['name']}'),
                      leading: Radio<int>(
                        value: positionMode['positionMode'],
                        groupValue: _activePositionMode,
                        onChanged: (value) {
                          setState(() {
                            _activePositionMode = value!;
                          });
                        },
                      ),
                      subtitle: Text('${positionMode['details']}'),
                    ),
                  ),
                )
                .toList(),
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'Contract Unit:',
                  style: TextStyle(
                    color: secondaryTextColor,
                  ),
                ),
              ),
              Row(
                children: _contractUnit
                    .map(
                      (contractUnit) => Row(
                        children: [
                          Radio<int>(
                            value: contractUnit['mode'],
                            groupValue: _activeContractUnit,
                            onChanged: (value) {
                              setState(() {
                                _activeContractUnit = value!;
                              });
                            },
                          ),
                          Text('${contractUnit['name']}'),
                        ],
                      ),
                    )
                    .toList(),
              )
            ],
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stop orders preference:',
                style: TextStyle(
                  color: secondaryTextColor,
                ),
              ),
              Wrap(
                children: _stopOrderPreferences
                    .map(
                      (stopOrderPreference) => Row(
                        children: [
                          Radio<int>(
                            value: stopOrderPreference['mode'],
                            groupValue: _activeStopOrderPref,
                            onChanged: (value) {
                              setState(() {
                                _activeStopOrderPref = value!;
                              });
                            },
                          ),
                          Text('${stopOrderPreference['name']}'),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm before place order:',
                style: TextStyle(
                  color: secondaryTextColor,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Second Confirmation of order'),
                  Switch(
                    value: _secondOrderConfirmation,
                    onChanged: (value) {
                      setState(() {
                        _secondOrderConfirmation = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          Divider(),
          SizedBox(
            width: width,
            child: ElevatedButton(
              onPressed: () {
                updateUserConfig();
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
