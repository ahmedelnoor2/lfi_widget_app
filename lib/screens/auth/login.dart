import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/captcha.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:flutter_aliyun_captcha/flutter_aliyun_captcha.dart';

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
  static final AliyunCaptchaController _captchaController =
      AliyunCaptchaController();
  bool _enableLogin = false;
  final _formLoginKey = GlobalKey<FormState>();

  final String mobileNumber = '';
  final String loginPword = '';
  bool _readPassword = true;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Sign In to access your account',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
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
                obscureText: _readPassword,
                decoration: InputDecoration(
                  // border: OutlineInputBorder(),
                  labelText: 'Password',
                  suffix: SizedBox(
                    width: 20,
                    height: 20,
                    child: IconButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        setState(() {
                          _readPassword = !_readPassword;
                        });
                      },
                      icon: Icon(
                        _readPassword ? Icons.visibility : Icons.visibility_off,
                        size: 20,
                      ),
                    ),
                  ),
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
          captchaController: _captchaController,
        ),
        SizedBox(
          width: width * 1,
          child: ElevatedButton(
            onPressed: _enableLogin
                ? () {
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
                      }, _captchaController);
                    } else {
                      _captchaController.refresh({});
                      _captchaController.reset();
                    }
                  }
                : null,
            child: const Text('Login'),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {
              Navigator.pushNamed(context, '/forgotForgotpassword');
              },
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  color: linkColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
