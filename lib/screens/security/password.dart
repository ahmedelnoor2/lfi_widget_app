import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Country.utils.dart';
import 'package:provider/provider.dart';

class Password extends StatefulWidget {
  static const routeName = '/password';
  const Password({Key? key}) : super(key: key);

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileNumber = TextEditingController();
  final TextEditingController _phoneVerificationCode = TextEditingController();

  late Timer _timer;
  int _start = 90;
  bool _startTimer = false;

  String _currentCoutnry = '${countries[0]['code']}';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mobileNumber.dispose();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _startTimer = true;
    });
    sendVerificationCode();
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            setState(() {
              _startTimer = false;
            });
            _timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> sendVerificationCode() async {
    var auth = Provider.of<Auth>(context, listen: false);
    await auth.sendMobileValidCode(context, {
      'countryCode': _currentCoutnry,
      'mobile': _mobileNumber.text,
      'operationType': 2,
      'smsType': '',
    });
  }

  Future<String> confirmEmailVeriCode() async {
    var auth = Provider.of<Auth>(context, listen: false);

    String mobVeri = await auth.confirmMobileCode(context, {
      'countryCode': _currentCoutnry,
      'mobile': _mobileNumber.text,
      'googleCode': '',
      'smsAuthCode': _phoneVerificationCode.text
    });
    return mobVeri;
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: appBar(context, null),
      body: SizedBox(
        width: width,
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Update Password'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
