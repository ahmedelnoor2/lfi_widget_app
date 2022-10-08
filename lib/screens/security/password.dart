import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
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
  final TextEditingController _initialPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _authCodeController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();
  final TextEditingController _phoneVerificationCode = TextEditingController();

  late Timer _timer;
  int _start = 90;
  bool _startTimer = false;

  bool _currentPassView = true;
  bool _newPassView = true;
  bool _confirmPassView = true;

  bool _processAjax = false;

  String _currentCoutnry = '${countries[0]['code']}';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mobileNumber.dispose();
    _initialPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _phoneVerificationCode.dispose();
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
      'operationType': 5,
      'smsType': '0',
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

  Future<void> updatePassword() async {
    setState(() {
      _processAjax = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var postData = (auth.googleAuth && auth.userInfo['mobileNumber'].isEmpty)
        ? {
            "googleCode": _authCodeController.text,
            "loginPword": _initialPasswordController.text,
            "newLoginPword": _newPasswordController.text
          }
        : {
            "googleCode": _authCodeController.text,
            "smsAuthCode": _smsCodeController.text,
            "loginPword": _initialPasswordController.text,
            "newLoginPword": _newPasswordController.text
          };

    await auth.updatePassword(context, postData);
    setState(() {
      _processAjax = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var auth = Provider.of<Auth>(context, listen: true);

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
                Container(
                  padding: EdgeInsets.only(bottom: width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: const Icon(Icons.password),
                      ),
                      Text(
                        'Modify login password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'It is forbidden to withdraw coins within 48 hours after modifying the email.',
                    style: TextStyle(
                      color: orangeBGColor,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5, bottom: 10),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        style: BorderStyle.solid,
                        width: 0.3,
                        color: Color(0xff5E6292),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter current password';
                              }
                              return null;
                            },
                            obscureText: _currentPassView,
                            controller: _initialPasswordController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: TextStyle(
                                fontSize: 14,
                              ),
                              hintText: "Current Password",
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _currentPassView = !_currentPassView;
                              });
                            },
                            child: _currentPassView
                                ? Icon(
                                    Icons.visibility,
                                    size: 18,
                                    color: secondaryTextColor,
                                  )
                                : Icon(
                                    Icons.visibility_off,
                                    size: 18,
                                    color: secondaryTextColor,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5, bottom: 10),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        style: BorderStyle.solid,
                        width: 0.3,
                        color: Color(0xff5E6292),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter new password';
                              }
                              return null;
                            },
                            obscureText: _newPassView,
                            controller: _newPasswordController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: TextStyle(
                                fontSize: 14,
                              ),
                              hintText: "New Password",
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _newPassView = !_newPassView;
                              });
                            },
                            child: _newPassView
                                ? Icon(
                                    Icons.visibility,
                                    size: 18,
                                    color: secondaryTextColor,
                                  )
                                : Icon(
                                    Icons.visibility_off,
                                    size: 18,
                                    color: secondaryTextColor,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5, bottom: 10),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        style: BorderStyle.solid,
                        width: 0.3,
                        color: Color(0xff5E6292),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter confirm password';
                              } else if (value != _newPasswordController.text) {
                                return 'Password missmatch';
                              }
                              return null;
                            },
                            obscureText: _confirmPassView,
                            controller: _confirmPasswordController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: TextStyle(
                                fontSize: 14,
                              ),
                              hintText: "Confirm Password",
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _confirmPassView = !_confirmPassView;
                              });
                            },
                            child: _confirmPassView
                                ? Icon(
                                    Icons.visibility,
                                    size: 18,
                                    color: secondaryTextColor,
                                  )
                                : Icon(
                                    Icons.visibility_off,
                                    size: 18,
                                    color: secondaryTextColor,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5, bottom: 10),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        style: BorderStyle.solid,
                        width: 0.3,
                        color: Color(0xff5E6292),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter auth code';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            controller: _authCodeController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: TextStyle(
                                fontSize: 14,
                              ),
                              hintText: 'Google verification code',
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () async {
                                ClipboardData? data = await Clipboard.getData(
                                  Clipboard.kTextPlain,
                                );
                                _authCodeController.text = '${data!.text}';
                              },
                              child: Icon(
                                Icons.copy,
                                size: 18,
                                color: secondaryTextColor,
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                (auth.userInfo['mobileNumber'].isNotEmpty)
                    ? Container(
                        padding: EdgeInsets.only(top: 5, bottom: 10),
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              style: BorderStyle.solid,
                              width: 0.3,
                              color: Color(0xff5E6292),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter sms auth code';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  controller: _smsCodeController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                    ),
                                    hintText: 'SMS verification code',
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: !_startTimer
                                    ? InkWell(
                                        onTap: () {
                                          setState(() {
                                            _start = 90;
                                          });
                                          startTimer();
                                        },
                                        child: Text(
                                          'Click to send',
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                auth.userInfo['mobileNumber'].isNotEmpty
                    ? Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _startTimer
                              ? Text(
                                  '${_start}s Get it again',
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                  ),
                                )
                              : Container(),
                        ),
                      )
                    : Container(),
                LyoButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      updatePassword();
                    }
                  },
                  text: 'Change',
                  active: true,
                  isLoading: _processAjax,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
