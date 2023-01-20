import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/trade_challenge.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class CheckIn_BottomSheet extends StatefulWidget {
  CheckIn_BottomSheet(
    this.checkInAmount, {
    Key? key,
  }) : super(key: key);

  final dynamic checkInAmount;

  @override
  State<CheckIn_BottomSheet> createState() => _CheckIn_BottomSheetState();
}

class _CheckIn_BottomSheetState extends State<CheckIn_BottomSheet> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDoDailyCheckIN();
  }

  Future<void> getDoDailyCheckIN() async {
    var tradeChallengeProvider =
        Provider.of<TradeChallenge>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
   await tradeChallengeProvider.getDoDailyCheckIn(context, auth);
    await getTaskCenter();
  }

  // get task center //
  Future<void> getTaskCenter() async {
    var tradeChallengeProvider =
        Provider.of<TradeChallenge>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    tradeChallengeProvider.getTaskCenter(context, auth);
  }

  @override
  Widget build(BuildContext context) {
    var tradeChallengeProvider =
        Provider.of<TradeChallenge>(context, listen: true);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return tradeChallengeProvider.isloadingdailyCheckIn
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            height: height * 0.50,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: (() {
                      Navigator.pop(context);
                    }),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.close),
                        //Text(checkInAmount),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Image.asset(
                    'assets/img/checkin.png',
                    width: 150,
                  ),
                ),

                // ignore: prefer_const_constructors
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                        tradeChallengeProvider.dailyCheckIn['msg'] ?? '',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      widget.checkInAmount +
                          tradeChallengeProvider.taskCenter['signInInfo']
                              ['rewardCoin'],
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  width: width * 90,
                  height: height * 0.10,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: tradechallengbtn, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Confirm',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: (() {
                      Navigator.pushNamed(context, '/reward_center');
                    }),
                    child: Center(
                      child: Text(
                        'View Reward ',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
 