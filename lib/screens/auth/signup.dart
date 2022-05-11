import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/screens/common/captcha.dart';
import 'package:url_launcher/url_launcher.dart';

class Signup extends StatefulWidget {
  const Signup({
    Key? key,
    this.onRegister,
    this.onCaptchaVerification,
  }) : super(key: key);

  final onRegister;
  final onCaptchaVerification;

  @override
  State<Signup> createState() => _Signup();
}

class _Signup extends State<Signup> {
  bool _enableSignup = false;
  final _formKey = GlobalKey<FormState>();

  bool termsAndCondition = false;
  
  late TextEditingController _email;
  late TextEditingController _loginPword;
  late TextEditingController _newPassword;
  late TextEditingController _invitedCode;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _loginPword = TextEditingController();
    _newPassword = TextEditingController();
    _invitedCode = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _loginPword.dispose();
    _newPassword.dispose();
    _invitedCode.dispose();
    super.dispose();
  }

  void toggleLoginButton(value) {
    setState(() {
      _enableSignup = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(width * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: const Text(
                    'Signup',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: const Text(
                  'Signup to get started',
                ),
              ),
            ], 
          ),
          Form(
            key: _formKey,
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
                    labelText: 'Email address',
                  ),
                  controller: _email,
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
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter confirm password';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    // border: OutlineInputBorder(),
                    labelText: 'Confirm the password',
                  ),
                  controller: _newPassword,
                ),
                TextField(
                  decoration: const InputDecoration(
                    // border: OutlineInputBorder(),
                    labelText: 'Invitation code (optional)',
                  ),
                  controller: _invitedCode,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: termsAndCondition,
                        onChanged: (bool? value) {
                          setState(() {
                            termsAndCondition = value!;
                          });
                        },
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (
                            await canLaunchUrl(
                              Uri(
                                scheme: 'https',
                                host: 'www.lyotrade.com',
                                path: 'en_US/cms/agreement'
                              )
                            )
                          ) {
                              await launchUrl(
                                Uri(
                                  scheme: 'https',
                                  host: 'www.lyotrade.com',
                                  path: 'en_US/cms/agreement'
                                )
                              );
                          } else {
                            // can't launch url, there is some error
                            throw "Could not launch https://www.lyotrade.com/en_US/cms/agreement";
                          }
                        },
                        child: Text(
                          'I have read and agreed LYOTRADE',
                          style: TextStyle(
                            color: Colors.blue[300]
                          ),
                        ),
                      ),
                    ],
                  ),
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
                textStyle: const TextStyle(fontSize: 20)
              ),
              onPressed: (_enableSignup && termsAndCondition) ? () {
                print('sign up');
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  snackAlert(context, SnackTypes.warning, 'Processing...');
                  setState(() {
                    _enableSignup = false;
                  });
                  widget.onRegister({
                    'email': _email.text,
                    'loginPword': _loginPword.text,
                    'newPassword': _newPassword.text,
                    'invitedCode': _invitedCode.text,
                  });
                }
              } : null,
              child: const Text('Sign Up'),
            ),
          ),
        ],
      ),
    );
  }
}
