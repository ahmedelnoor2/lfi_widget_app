import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/providers/topup.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class ConfirmTopup extends StatefulWidget {
  ConfirmTopup({
    Key? key,
    this.topupamount,
  }) : super(key: key);

  var topupamount;

  @override
  State<ConfirmTopup> createState() => _ConfirmTopupState();
}

class _ConfirmTopupState extends State<ConfirmTopup> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var topupProvider = Provider.of<TopupProvider>(context, listen: false);

    return SingleChildScrollView(
      child: Container(
          child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(child: Text('Confirm Top up')),
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
                SizedBox(
                  height: height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(widget.topupamount.toString())],
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Currency',
                      style: TextStyle(color: secondaryTextColor400),
                    ),
                    Text(topupProvider.estimateRate['rate'].toString())
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Payment Method'), Text('Funding wallet')],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [Text('Payment Currency'), Text(' 27.23 USDT ')],
                // ),
                SizedBox(
                  height: height * 0.06,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width * 0.35,
                      child: LyoButton(
                        onPressed: () {},
                        text: 'Cancel',
                        isLoading: false,
                        active: true,
                        activeTextColor: Colors.black,
                      ),
                    ),
                    Container(
                      width: width * 0.55,
                      child: LyoButton(
                        onPressed: () {},
                        text: 'Confirm',
                        isLoading: false,
                        active: true,
                        activeColor: linkColor,
                        activeTextColor: Colors.black,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      )),
    );
  }
}
