import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Country.utils.dart';
import 'package:provider/provider.dart';

class Phone extends StatefulWidget {
  static const routeName = '/phone_number';
  const Phone({Key? key}) : super(key: key);

  @override
  State<Phone> createState() => _PhoneState();
}

class _PhoneState extends State<Phone> {
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
    print(mobVeri);
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
                const Text('Link the mobile phone'),
                FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: const InputDecoration(
                        // labelStyle: textStyle,
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                        hintText: 'Please select expense',
                        // border: OutlineInputBorder(
                        //     borderRadius: BorderRadius.circular(5.0)),
                      ),
                      isEmpty: countries[0]['country'] == 0,
                      child: DropdownButtonHideUnderline(
                        child: FittedBox(
                          child: DropdownButton<String>(
                            isExpanded: false,
                            value: _currentCoutnry,
                            isDense: true,
                            onChanged: (newValue) {
                              print(newValue);
                              setState(() {
                                _currentCoutnry = '$newValue';
                              });
                            },
                            items: countries.map((value) {
                              return DropdownMenuItem<String>(
                                value: '${value['code']}',
                                child: Text(
                                    '${value['country']} ${value['code']}'),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile number';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Mobile number',
                  ),
                  controller: _mobileNumber,
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone verification code';
                    }
                    return null;
                  },
                  autofocus: false,
                  decoration: InputDecoration(
                    // border: OutlineInputBorder(),

                    hintText: 'Phone verification code',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffix: TextButton(
                      onPressed: _startTimer
                          ? null
                          : () {
                              setState(() {
                                _start = 90;
                              });
                              startTimer();
                              print('Send code');
                            },
                      child: Text(
                        _startTimer
                            ? '${_start}s Get it again'
                            : 'Click to send',
                        style: TextStyle(color: linkColor),
                      ),
                    ),
                  ),
                  controller: _phoneVerificationCode,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15),
                  width: width * 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20)),
                    onPressed: () {
                      print('Connect');
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        confirmEmailVeriCode();
                      }
                    },
                    child: const Text('Connect'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
