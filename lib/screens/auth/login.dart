import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/captcha.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';

class Login extends StatefulWidget {
  const Login({
    Key? key,
    this.onLogin,
    this.onCaptchaVerification,
  }) : super(key: key);

  final onLogin;
  final onCaptchaVerification;

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  bool _enableLogin = false;
  final _formLoginKey = GlobalKey<FormState>();

  final String mobileNumber = '';
  final String loginPword = '';

  late TextEditingController _mobileNumber;
  late TextEditingController _loginPword;

  @override
  void initState() {
    super.initState();
    _mobileNumber = TextEditingController();
    _loginPword = TextEditingController();
  }

  @override
  void dispose() {
    _mobileNumber.dispose();
    _loginPword.dispose();
    super.dispose();
  }

  void toggleLoginButton(value) {
    setState(() {
      _enableLogin = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(width * 0.1),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: const Text(
                'Login to access your account',
              ),
            ),
          ],
        ),
        Form(
          key: _formLoginKey,
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email address';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  // border: OutlineInputBorder(),
                  labelText: 'Email or phone number',
                ),
                controller: _mobileNumber,
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                obscureText: true,
                decoration: const InputDecoration(
                  // border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
                controller: _loginPword,
              ),
            ],
          ),
        ),
        Captcha(
          onCaptchaVerification: (value) {
            toggleLoginButton(true);
            if (value.containsKey('sig')) {
            } else {
              toggleLoginButton(false);
            }
            widget.onCaptchaVerification(value);
          },
        ),
        SizedBox(
          width: width * 1,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20)),
            onPressed: _enableLogin
                ? () {
                    print('Login');
                    if (_formLoginKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      snackAlert(context, SnackTypes.warning, 'Processing...');
                      setState(() {
                        _enableLogin = false;
                      });
                      widget.onLogin({
                        'mobileNumber': _mobileNumber.text,
                        'loginPword': _loginPword.text,
                      });
                    }
                  }
                : null,
            child: const Text('Login'),
          ),
        ),
      ]),
    );
  }
}
