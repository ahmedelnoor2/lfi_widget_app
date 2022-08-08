import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/staking.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class AllStake extends StatefulWidget {
  const AllStake({Key? key}) : super(key: key);

  @override
  State<AllStake> createState() => _AllStakeState();
}

class _AllStakeState extends State<AllStake> {
  final _formStakeKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  String _filterType = 'Processing';
  bool _isAgree = false;
  String _activeStakeId = '';
  String _prospectiveEarnings = "0";

  @override
  void initState() {
    getAllStakes();
    super.initState();
  }

  @override
  void dispose() async {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> getAllStakes() async {
    var public = Provider.of<Public>(context, listen: false);
    await public.getStakeLists();
    List _currentProcessing = [];
    for (var stake in public.stakeLists) {
      if (_filterType == 'Processing') {
        if (stake['status'] == 1) {
          _currentProcessing.add(stake);
        }
      }
    }
    if (_currentProcessing.isEmpty) {
      setState(() {
        _filterType = 'All';
      });
      snackAlert(
          context, SnackTypes.warning, 'Active projects are not availalbe');
    }
  }

  Future<void> getStakeInfo(stakeId) async {
    var public = Provider.of<Public>(context, listen: false);
    await public.getStakeInfo(stakeId);
  }

  // void calculateProspectiveEarnings(stake, value) {
  //   double.parse('${stake['gainRate']}');
  //   setState(() {
  //     _prospectiveEarnings =
  //         (((((720 / 360) * double.parse('${stake['gainRate']}')) / 100) *
  //                     double.parse(value)) +
  //                 double.parse(value))
  //             .toStringAsFixed(4);
  //   });

  //   // ((((720 / 360) * 24) / 100) * 1);
  // }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var public = Provider.of<Public>(context, listen: true);

    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 100,
            child: PopupMenuButton(
              child: Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.only(top: 2, bottom: 2, left: 4, right: 2),
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
                    Text(
                      _filterType,
                      style: TextStyle(fontSize: 14),
                    ),
                    Icon(
                      Icons.expand_more,
                      color: secondaryTextColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
              onSelected: (value) {
                setState(() {
                  _filterType = '$value';
                });
              },
              itemBuilder: (ctx) => [
                _buildPopupMenuItem('All'),
                _buildPopupMenuItem('Pending'),
                _buildPopupMenuItem('Processing'),
                _buildPopupMenuItem('Finished'),
              ],
            ),
          ),
        ),
        SizedBox(
          height: height * 0.76,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: public.stakeLists.length,
            itemBuilder: (BuildContext context, int index) {
              var stake = public.stakeLists[index];
              if (_filterType == 'Processing') {
                if (stake['status'] == 1) {
                  return _stakeItem(public, stake);
                } else {
                  return Container();
                }
              } else if (_filterType == 'Pending') {
                if (stake['status'] == 2) {
                  return _stakeItem(public, stake);
                } else {
                  return Container();
                }
              } else if (_filterType == 'Finished') {
                if (stake['status'] == 3) {
                  return _stakeItem(public, stake);
                } else {
                  return Container();
                }
              } else {
                return _stakeItem(public, stake);
              }
            },
          ),
        ),
      ],
    );
  }

  PopupMenuItem _buildPopupMenuItem(String title) {
    return PopupMenuItem(
      value: title,
      child: Row(
        children: [
          Text(title),
        ],
      ),
    );
  }

  Widget _stakeItem(public, stake) {
    var auth = Provider.of<Auth>(context, listen: true);
    var staking = Provider.of<Staking>(context, listen: true);

    return Column(
      children: [
        Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.only(right: 5),
                  child: CircleAvatar(
                    radius: 14,
                    child: Image.network('${stake['logo']}'),
                  ),
                ),
                Text(
                  public.publicInfoMarket.isEmpty
                      ? '--'
                      : '${public.publicInfoMarket['market']['coinList'][stake['gainCoin']]['longName']}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 5),
                    child: Text(
                      'Annualized returns',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ),
                  Text(
                    '${stake['gainRate']}%',
                    style: TextStyle(color: greenIndicator),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 5),
                    child: Text(
                      'Locking process',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ),
                  Text(
                    '${stake['progress']}',
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 5),
                    child: Text(
                      'Locking period',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ),
                  Text(
                    '${stake['lockDay']} Days',
                  ),
                ],
              ),
            ),
            // Container(
            //   padding: EdgeInsets.only(top: 10, bottom: 5),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Text(
            //       'Duration',
            //       style: TextStyle(
            //         color: secondaryTextColor,
            //         fontSize: 12,
            //       ),
            //     ),
            //   ),
            // ),
            // _selectAmountPecentage(stake),
          ],
        ),
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: width * 0.45,
                height: 30,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: linkColor,
                    ),
                  ),
                  onPressed: () async {
                    public.getStakeInfo(stake['id']);
                    staking.getActiveStakeInfo(context, auth, stake['id']);
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return _stakeDetails(
                              context,
                              stake,
                              setState,
                            );
                          },
                        );
                      },
                    );
                  },
                  child: Text(
                    'Details',
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.45,
                height: 30,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isAgree = false;
                      _activeStakeId = '${stake['id']}';
                    });
                    staking.getActiveStakeInfo(context, auth, stake['id']);
                    if (stake['status'] == 1) {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return _activeStakeDetails(
                                context,
                                stake,
                                setState,
                              );
                            },
                          );
                        },
                      );
                    } else {
                      snackAlert(
                        context,
                        SnackTypes.warning,
                        'This project is expired',
                      );
                    }
                    // setState(() {
                    //   _isBuy = true;
                    // });
                    // setAvailalbePrice();
                  },
                  child: Text(
                    'Stake Now',
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }

  Widget _selectAmountPecentage(stake) {
    return Container(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.only(right: 5),
            child: Text(
              'Locking Period',
              style: TextStyle(color: secondaryTextColor),
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  print('Select preceision');
                },
                child: Container(
                  width: width * 0.30,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff292C51),
                    ),
                    color: Color(0xff292C51),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '${stake['lockDay']} Days',
                      style: TextStyle(
                        // color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Column(
          //   children: [
          //     GestureDetector(
          //       onTap: () {
          //         print('Select preceision');
          //       },
          //       child: Container(
          //         width: width * 0.22,
          //         padding: EdgeInsets.all(4),
          //         decoration: BoxDecoration(
          //           border: Border.all(
          //             color: Color(0xff292C51),
          //           ),
          //           color: Color(0xff292C51),
          //           borderRadius: BorderRadius.all(
          //             Radius.circular(2),
          //           ),
          //         ),
          //         child: Align(
          //           alignment: Alignment.center,
          //           child: Text(
          //             '60 Days',
          //             style: TextStyle(
          //               color: secondaryTextColor,
          //               fontSize: 12,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // Column(
          //   children: [
          //     GestureDetector(
          //       onTap: () {
          //         print('Select preceision');
          //       },
          //       child: Container(
          //         width: width * 0.22,
          //         padding: EdgeInsets.all(4),
          //         decoration: BoxDecoration(
          //           border: Border.all(
          //             color: Color(0xff292C51),
          //           ),
          //           color: Color(0xff292C51),
          //           borderRadius: BorderRadius.all(
          //             Radius.circular(2),
          //           ),
          //         ),
          //         child: Align(
          //           alignment: Alignment.center,
          //           child: Text(
          //             '90 Days',
          //             style: TextStyle(
          //               color: secondaryTextColor,
          //               fontSize: 12,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // Column(
          //   children: [
          //     GestureDetector(
          //       onTap: () {
          //         print('Select preceision');
          //       },
          //       child: Container(
          //         width: width * 0.22,
          //         padding: EdgeInsets.all(4),
          //         decoration: BoxDecoration(
          //           border: Border.all(
          //             color: Color(0xff292C51),
          //           ),
          //           color: Color(0xff292C51),
          //           borderRadius: BorderRadius.all(
          //             Radius.circular(2),
          //           ),
          //         ),
          //         child: Align(
          //           alignment: Alignment.center,
          //           child: Text(
          //             '120 Days',
          //             style: TextStyle(
          //               color: secondaryTextColor,
          //               fontSize: 12,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _activeStakeDetails(context, stake, setState) {
    height = MediaQuery.of(context).size.height;
    var staking = Provider.of<Staking>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 20,
        right: 10,
        left: 10,
      ),
      child: Form(
        key: _formStakeKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Process',
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
            staking.activeStakeInfo.isNotEmpty
                ? Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 20),
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(right: 10),
                                        child: CircleAvatar(
                                          radius: 20,
                                          child: Image.network(
                                            '${staking.activeStakeInfo['logo']}',
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${staking.activeStakeInfo['gainCoinName']}',
                                        style: TextStyle(fontSize: 25),
                                      ),
                                    ],
                                  ),
                                  VerticalDivider(
                                    thickness: 1,
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${staking.activeStakeInfo['name']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${staking.activeStakeInfo['gainRate']}%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: linkColor,
                                        ),
                                      ),
                                      Text(
                                        'Annualized returns',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              OutlinedButton(
                                onPressed: () {},
                                child: Text('Notice'),
                              )
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Locking process',
                            style: TextStyle(
                              color: secondaryTextColor,
                            ),
                          ),
                          Text(
                            'Total locking amount',
                            style: TextStyle(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: width,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          // border: Border.all(
                          //   color: Color(0xff292C51),
                          // ),
                          color: Color(0xff292C51),
                        ),
                        child: LinearProgressIndicator(
                          value: double.parse(
                                  '${staking.activeStakeInfo['progress'].replaceAll('%', '')}') /
                              100,
                          semanticsLabel: 'Linear progress indicator',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${staking.activeStakeInfo['progress']}',
                          ),
                          Text(
                            '${staking.activeStakeInfo['buyAmountMax']} ${staking.activeStakeInfo['gainCoinName']}',
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Locked quantity'),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Text(
                                    '${staking.activeStakeInfo['totalAmount']}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: linkColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${staking.activeStakeInfo['gainCoin']}',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Locked Quantity (Minimum quantity per lock ${staking.activeStakeInfo['buyAmountMin']} USDT; Maximum cumulative lock quantity ${staking.activeStakeInfo['buyAmountMax']} USDT)',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 5),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              style: BorderStyle.solid,
                              width: 0.3,
                              color: Color(0xff5E6292),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: width * 0.69,
                                child: TextFormField(
                                  onChanged: (value) {
                                    double.parse('${stake['gainRate']}');
                                    setState(() {
                                      if (value.isNotEmpty) {
                                        setState(() {
                                          _prospectiveEarnings = (((((720 /
                                                                  360) *
                                                              double.parse(
                                                                  '${stake['gainRate']}')) /
                                                          100) *
                                                      double.parse(value)) +
                                                  double.parse(value))
                                              .toStringAsFixed(4);
                                        });
                                      } else {
                                        setState(() {
                                          _prospectiveEarnings = "0";
                                        });
                                      }
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter amount';
                                    }
                                    return null;
                                  },
                                  controller: _amountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                    ),
                                    hintText: "Enter Amount to Stake",
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 10),
                                    child: GestureDetector(
                                      onTap: () async {
                                        _amountController.text =
                                            '${double.parse(staking.activeStakeInfo['balance']).toStringAsFixed(2)}';
                                        double.parse('${stake['gainRate']}');
                                        setState(() {
                                          if (_amountController
                                              .text.isNotEmpty) {
                                            setState(() {
                                              _prospectiveEarnings = (((((720 /
                                                                      360) *
                                                                  double.parse(
                                                                      '${stake['gainRate']}')) /
                                                              100) *
                                                          double.parse(
                                                              _amountController
                                                                  .text)) +
                                                      double.parse(
                                                          _amountController
                                                              .text))
                                                  .toStringAsFixed(4);
                                            });
                                          } else {
                                            setState(() {
                                              _prospectiveEarnings = "0";
                                            });
                                          }
                                        });
                                      },
                                      child: Text(
                                        'ALL',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: linkColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 5),
                                child: Text(
                                  'Available Balance ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ),
                              Text(
                                '${staking.activeStakeInfo['balance'] ?? '--'} ${staking.activeStakeInfo['gainCoin'] ?? '--'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: linkColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 5),
                        width: width,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(50, 160, 165, 181),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              style: BorderStyle.solid,
                              width: 0.3,
                              // color: Colors.,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              '${staking.activeStakeInfo['lockDay'] ?? '--'} days prospective earnings: $_prospectiveEarnings ${staking.activeStakeInfo['gainCoin']}',
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${staking.activeStakeInfo['info']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isAgree,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isAgree = value!;
                                });
                              },
                            ),
                            Text(
                              'I am fully aware of the project risks',
                            ),
                          ],
                        ),
                      ),
                      LyoButton(
                        onPressed: _isAgree
                            ? () {
                                if (_formStakeKey.currentState!.validate()) {
                                  if (double.parse(_amountController.text) <=
                                      0) {
                                    showAlert(
                                      context,
                                      Icon(Icons.warning_amber),
                                      'Form Error',
                                      [Text('Amount is invalid')],
                                      'Ok',
                                    );
                                  } else {
                                    staking.createStakingOrder(context, auth, {
                                      'projectId': _activeStakeId,
                                      'amount':
                                          double.parse(_amountController.text),
                                      'returnUrl':
                                          'https://www.lyotrade.com/en_US/freeStaking/$_activeStakeId',
                                    });
                                  }
                                }
                              }
                            : null,
                        text: 'Agree to PoS',
                        isLoading: false,
                        active: true,
                        activeColor: linkColor,
                        activeTextColor: Colors.black,
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _stakeDetails(context, stake, setState) {
    height = MediaQuery.of(context).size.height;
    var public = Provider.of<Public>(context, listen: true);
    var staking = Provider.of<Staking>(context, listen: true);

    // List _marginCoins = _defaultMarginPair.split('/');

    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 20,
        right: 10,
        left: 10,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Process',
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
          public.stakeInfo.isNotEmpty
              ? Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 10),
                                      child: CircleAvatar(
                                        radius: 20,
                                        child: Image.network(
                                          '${public.stakeInfo['logo']}',
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${public.stakeInfo['gainCoinName']}',
                                      style: TextStyle(fontSize: 25),
                                    ),
                                  ],
                                ),
                                VerticalDivider(
                                  thickness: 1,
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${public.stakeInfo['name']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${public.stakeInfo['gainRate']}%',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: linkColor,
                                      ),
                                    ),
                                    Text(
                                      'Annualized returns',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            OutlinedButton(
                              onPressed: () {},
                              child: Text('Notice'),
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Locking process',
                          style: TextStyle(
                            color: secondaryTextColor,
                          ),
                        ),
                        Text(
                          'Total locking amount',
                          style: TextStyle(
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: width,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        // border: Border.all(
                        //   color: Color(0xff292C51),
                        // ),
                        color: Color(0xff292C51),
                      ),
                      child: LinearProgressIndicator(
                        value: double.parse(
                                '${public.stakeInfo['progress'].replaceAll('%', '')}') /
                            100,
                        semanticsLabel: 'Linear progress indicator',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${public.stakeInfo['progress']}',
                        ),
                        Text(
                          '${public.stakeInfo['buyAmountMax']} ${public.stakeInfo['gainCoinName']}',
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Locked quantity'),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 5),
                                child: Text(
                                  '${staking.activeStakeInfo.isNotEmpty ? staking.activeStakeInfo['totalAmount'] : public.stakeInfo['totalAmount']}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: linkColor,
                                  ),
                                ),
                              ),
                              Text(
                                'LYO',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cumulative grantings'),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 5),
                                child: Text(
                                  '${staking.activeStakeInfo.isNotEmpty ? staking.activeStakeInfo['totalGainAmount'] : public.stakeInfo['totalGainAmount']}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: linkColor,
                                  ),
                                ),
                              ),
                              Text(
                                'LYO',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Earned'),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 5),
                                child: Text(
                                  '${staking.activeStakeInfo.isNotEmpty ? staking.activeStakeInfo['totalUserGainAmount'] : public.stakeInfo['totalUserGainAmount']}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: linkColor,
                                  ),
                                ),
                              ),
                              Text(
                                'LYO',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 15),
                      child: Text(
                        '${public.stakeInfo['info']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                )
              : Container()
        ],
      ),
    );
  }
}
