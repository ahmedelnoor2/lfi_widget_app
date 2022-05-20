import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:provider/provider.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({
    Key? key,
    String? this.token,
    String? this.operationType,
    this.toggleEmailVerification,
    bool? this.emailVerification,
    String? this.currentCoutnry,
    bool? this.isMobile,
  }) : super(key: key);

  final token;
  final operationType;
  final toggleEmailVerification;
  final emailVerification;
  final currentCoutnry;
  final isMobile;

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  final _formEmailVeriKey = GlobalKey<FormState>();

  final TextEditingController _emailVeirficationCode = TextEditingController();

  late Timer _timer;
  int _start = 90;
  bool _startTimer = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailVeirficationCode.dispose();
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
    print(widget.isMobile);
    var auth = Provider.of<Auth>(context, listen: false);

    if (widget.emailVerification) {
      await auth.sendEmailValidCode(context, {
        'token': widget.token,
        'email': '',
        'operationType': widget.operationType,
      });
    } else if (widget.isMobile) {
      await auth.sendMobileValidCode(context, {
        'token': widget.token,
        'operationType': '25',
        'smsType': '0',
      });
    } else {
      await auth.sendMobileValidCode(context, {
        'token': widget.token,
        'countryCode': widget.currentCoutnry,
        'operationType': 1,
        'smsType': '0',
      });
    }
  }

  Future<String> confirmEmailVeriCode(context) async {
    var auth = Provider.of<Auth>(context, listen: false);

    if (widget.operationType == '4' || widget.operationType == '25') {
      if (widget.isMobile) {
        String mobileVeri = await auth.confirmLoginCode(context, {
          'smsCode': _emailVeirficationCode.text,
          'token': widget.token,
        });
        print(mobileVeri);
        return mobileVeri;
      } else {
        String emailVeri = await auth.confirmLoginCode(context, {
          'emailCode': _emailVeirficationCode.text,
          'token': widget.token,
        });
        print(emailVeri);
        return emailVeri;
      }
    } else {
      if (widget.emailVerification) {
        String emailVeri = await auth.confirmEmailCode(context, {
          'emailCode': _emailVeirficationCode.text,
          'token': widget.token,
        });
        print(emailVeri);
        return emailVeri;
      } else {
        String mobileVeri = await auth.confirmMobileVerification(context, {
          'smsCode': _emailVeirficationCode.text,
          'token': widget.token,
        });
        print(mobileVeri);
        return mobileVeri;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);

    return Container(
      padding: EdgeInsets.only(top: height * 0.03),
      height: height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: const Text(
                  'Security Verification',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            width: width * 0.85,
            child: Form(
              key: _formEmailVeriKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ${widget.emailVerification ? 'Email' : 'SMS'} verification code';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: auth.googleAuth
                          ? 'Google verification code'
                          : '${(widget.emailVerification || !widget.isMobile) ? 'Email' : 'SMS'} verification code',
                      suffix: auth.googleAuth
                          ? TextButton(
                              onPressed: () async {
                                ClipboardData? data = await Clipboard.getData(
                                  Clipboard.kTextPlain,
                                );
                                _emailVeirficationCode.text = '${data!.text}';
                              },
                              child: const Icon(Icons.paste),
                            )
                          : TextButton(
                              onPressed: _startTimer
                                  ? null
                                  : () {
                                      setState(() {
                                        _start = 90;
                                      });
                                      startTimer();
                                      print('Send code');
                                    },
                              child: Text(_startTimer
                                  ? '${_start}s Get it again'
                                  : 'Click to send'),
                            ),
                    ),
                    controller: _emailVeirficationCode,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: width * 0.85,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20)),
              onPressed: () async {
                if (!auth.googleAuth) {
                  _timer.cancel();
                }
                if (_formEmailVeriKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  if (widget.emailVerification) {
                    String verificationResponse =
                        await confirmEmailVeriCode(context);
                    if (verificationResponse == '0') {
                      // Navigator.pop(context);
                      Navigator.pushNamed(context, '/dashboard');
                    } else {
                      widget.toggleEmailVerification();
                    }
                  } else {
                    String verificationResponse =
                        await confirmEmailVeriCode(context);
                    if (verificationResponse == '0') {
                      // Navigator.pop(context);
                      Navigator.pushNamed(context, '/dashboard');
                    } else {
                      widget.toggleEmailVerification();
                    }
                  }
                }
              },
              child: const Text('Verify'),
            ),
          ),
        ],
      ),
    );
  }
}
