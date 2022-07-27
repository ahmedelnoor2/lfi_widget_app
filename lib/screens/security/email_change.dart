import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import 'package:lyotrade/providers/auth.dart';
import 'package:provider/provider.dart';

class EmailChange extends StatefulWidget {
  static const routeName = '/email_change';
  const EmailChange({Key? key}) : super(key: key);

  @override
  State<EmailChange> createState() => _EmailChangeState();
}

class _EmailChangeState extends State<EmailChange> {
  final _formKey = GlobalKey<FormState>();
  final _formFieldKey = GlobalKey<FormFieldState>();
  final TextEditingController _emailAddress = TextEditingController();
  final TextEditingController _emailVerification = TextEditingController();
  final TextEditingController _newEmailAddress = TextEditingController();
  final TextEditingController _newEmailVerification = TextEditingController();
  final TextEditingController _securityVerification = TextEditingController();

  bool _processing = false;

  late Timer _timer;
  int _start = 90;
  bool _startTimer = false;

  late Timer _timerNew;
  int _startNew = 90;
  bool _startTimerNew = false;

  late Timer _timerSecur;
  int _startSecur = 90;
  bool _startTimerSecur = false;

  @override
  void initState() {
    // getGoogleAuth();
    super.initState();
  }

  @override
  void dispose() {
    _emailVerification.dispose();
    _newEmailAddress.dispose();
    _newEmailVerification.dispose();
    _securityVerification.dispose();
    super.dispose();
  }

  void startTimer(type) {
    setState(() {
      if (type == 'email') {
        _startTimer = true;
      } else if (type == 'new-email') {
        _startTimerNew = true;
      } else if (type == 'security') {
        _startTimerSecur = true;
      }
    });

    sendVerificationCode(type);
    if (type == 'email') {
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
    } else if (type == 'new-email') {
      const oneSecNew = Duration(seconds: 1);
      _timerNew = Timer.periodic(
        oneSecNew,
        (Timer timer) {
          if (_startNew == 0) {
            setState(() {
              setState(() {
                _startTimerNew = false;
              });
              _timerNew.cancel();
            });
          } else {
            setState(() {
              _startNew--;
            });
          }
        },
      );
    } else if (type == 'security') {
      const oneSecSecur = Duration(seconds: 1);
      _timerSecur = Timer.periodic(
        oneSecSecur,
        (Timer timer) {
          if (_startSecur == 0) {
            setState(() {
              setState(() {
                _startTimerSecur = false;
              });
              _timerSecur.cancel();
            });
          } else {
            setState(() {
              _startSecur--;
            });
          }
        },
      );
    }
  }

  Future<void> sendVerificationCode(type) async {
    var auth = Provider.of<Auth>(context, listen: false);

    if (type == 'email') {
      await auth.sendEmailValidCode(context, {
        "token": "",
        "email": "",
        "operationType": 15,
      });
    } else if (type == 'new-email') {
      await auth.sendEmailValidCode(context, {
        "token": "",
        "email": _emailAddress.text.isNotEmpty
            ? _emailAddress.text
            : _newEmailAddress.text,
        "operationType": 2,
      });
    } else if (type == 'security') {
      await auth.sendMobileValidCode(context, {
        "operationType": 15,
        "code": "",
        "mobile": "",
        "smsType": "0",
      });
    }
  }

  Future<void> emailUpdate() async {
    setState(() {
      _processing = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    await auth.emailUpdate(context, {
      'email': _newEmailAddress.text,
      'emailOldValidCode': _emailVerification.text,
      'emailNewValidCode': _newEmailVerification.text,
      'googleCode':
          auth.userInfo['googleStatus'] == 1 ? _securityVerification.text : '',
      'smsValidCode':
          auth.userInfo['googleStatus'] == 0 ? _securityVerification.text : '',
    });
    setState(() {
      _processing = false;
    });
  }

  Future<void> bindNewEmail() async {
    setState(() {
      _processing = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    await auth.bindNewEmail(context, {
      'email': _emailAddress.text,
      'emailValidCode': _emailVerification.text,
      'googleCode': "",
      'smsValidCode': ""
    });
    await auth.getUserInfo(context);
    setState(() {
      _processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);

    return Scaffold(
      appBar: appBar(context, null),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: width * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 5),
                      child: const Icon(Icons.email),
                    ),
                    Text(
                      auth.userInfo['email'].isEmpty
                          ? 'Connect e-mail'
                          : 'Modify e-mail',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              auth.userInfo['email'].isEmpty
                  ? Container()
                  : Text(
                      'It is forbidden to withdraw coins within 48 hours after modifying the email.',
                      style: TextStyle(
                        color: orangeBGColor,
                      ),
                    ),
              Container(
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    auth.userInfo['email'].isEmpty
                        ? TextFormField(
                            key: _formFieldKey,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email address';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'E-mail address',
                            ),
                            controller: _emailAddress,
                          )
                        : Container(),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email verification code';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'E-mail verification code',
                          suffix: TextButton(
                            onPressed: _startTimer
                                ? null
                                : () {
                                    setState(() {
                                      _start = 90;
                                    });
                                    if (auth.userInfo['email'].isEmpty) {
                                      startTimer('new-email');
                                    } else {
                                      startTimer('email');
                                    }
                                  },
                            child: Text(_startTimer
                                ? '${_start}s Get it again'
                                : 'Click to send'),
                          )),
                      controller: _emailVerification,
                    ),
                    auth.userInfo['email'].isEmpty
                        ? Container()
                        : TextFormField(
                            key: _formFieldKey,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter new email address';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'New e-mail address',
                            ),
                            controller: _newEmailAddress,
                          ),
                    auth.userInfo['email'].isEmpty
                        ? Container()
                        : TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter new email verification code';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                labelText: 'New e-mail verification code',
                                suffix: TextButton(
                                  onPressed: _startTimerNew
                                      ? null
                                      : () {
                                          if (_formFieldKey.currentState!
                                              .validate()) {
                                            setState(() {
                                              _startNew = 90;
                                            });
                                            startTimer('new-email');
                                          }
                                        },
                                  child: Text(_startTimerNew
                                      ? '${_startNew}s Get it again'
                                      : 'Click to send'),
                                )),
                            controller: _newEmailVerification,
                          ),
                    auth.userInfo['email'].isEmpty
                        ? Container()
                        : TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email verification code';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: auth.googleAuth
                                  ? 'Google verification code'
                                  : 'SMS verification code',
                              suffix: auth.googleAuth
                                  ? TextButton(
                                      onPressed: () async {
                                        ClipboardData? data =
                                            await Clipboard.getData(
                                          Clipboard.kTextPlain,
                                        );
                                        _securityVerification.text =
                                            '${data!.text}';
                                      },
                                      child: const Icon(Icons.paste),
                                    )
                                  : TextButton(
                                      onPressed: _startTimerSecur
                                          ? null
                                          : () {
                                              setState(() {
                                                _startSecur = 90;
                                              });
                                              startTimer('security');
                                            },
                                      child: Text(_startTimerSecur
                                          ? '${_startSecur}s Get it again'
                                          : 'Click to send'),
                                    ),
                            ),
                            controller: _securityVerification,
                          ),
                  ],
                ),
              ),
              Container(
                width: width * 0.9,
                padding: EdgeInsets.only(bottom: width * 0.1),
                child: ElevatedButton(
                  onPressed: _processing
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            if (auth.userInfo['email'].isEmpty) {
                              bindNewEmail();
                            } else {
                              emailUpdate();
                            }
                          }
                        },
                  child: const Text('Connect'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
