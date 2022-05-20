import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/screens/common/captcha.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lyotrade/utils/Country.utils.dart';

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

class _Signup extends State<Signup> with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  bool _enableSignup = false;
  final _formKey = GlobalKey<FormState>();

  bool termsAndCondition = false;
  bool _emailSignup = true;
  String _currentCoutnry = '${countries[0]['code']}';

  bool _readPassword = true;
  bool _readConfirmPassword = true;

  late TextEditingController _emailOrPhone;
  late TextEditingController _loginPword;
  late TextEditingController _newPassword;
  late TextEditingController _invitedCode;

  @override
  void initState() {
    _emailOrPhone = TextEditingController();
    _loginPword = TextEditingController();
    _newPassword = TextEditingController();
    _invitedCode = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailOrPhone.dispose();
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
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Sign Up to get started',
                  style: TextStyle(color: secondaryTextColor),
                ),
              ),
            ],
          ),
        ),
        TabBar(
          onTap: (index) {
            setState(() {
              _emailSignup = index == 0 ? true : false;
            });
          },
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 2,
              color: linkColor,
            ),
            insets: const EdgeInsets.only(left: 0, right: 25, bottom: 4),
          ),
          isScrollable: true,
          labelPadding: const EdgeInsets.only(left: 0, right: 0),
          tabs: const [
            Padding(
              padding: EdgeInsets.only(right: 25),
              child: Tab(text: 'Email'),
            ),
            Padding(
              padding: EdgeInsets.only(right: 25),
              child: Tab(text: 'Mobile Phone'),
            ),
          ],
          controller: _tabController,
        ),
        Container(
          padding: const EdgeInsets.only(top: 5),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: width * (_emailSignup ? 0.16 : 0.28),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email address';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                        ),
                        controller: _emailOrPhone,
                      ),
                      Column(
                        children: [
                          FormField<String>(
                            builder: (FormFieldState<String> state) {
                              return InputDecorator(
                                decoration: const InputDecoration(
                                  errorStyle: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                  hintText: 'Please select expense',
                                ),
                                isEmpty: countries[0]['country'] == 0,
                                child: DropdownButtonHideUnderline(
                                  child: FittedBox(
                                    child: DropdownButton<String>(
                                      isExpanded: false,
                                      value: _currentCoutnry,
                                      isDense: true,
                                      onChanged: (newValue) {
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
                                return 'Please enter phone number';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                            ),
                            controller: _emailOrPhone,
                          ),
                        ],
                      ),
                    ],
                  ),
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
                          _readPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                        ),
                      ),
                    ),
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
                  obscureText: _readConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm the password',
                    suffix: SizedBox(
                      width: 20,
                      height: 20,
                      child: IconButton(
                        padding: const EdgeInsets.all(0.0),
                        onPressed: () {
                          setState(() {
                            _readConfirmPassword = !_readConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _readConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                        ),
                      ),
                    ),
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
                  width: width,
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: termsAndCondition,
                        onChanged: (bool? value) {
                          setState(() {
                            termsAndCondition = value!;
                          });
                        },
                      ),
                      SizedBox(
                        width: width * 0.73,
                        child: Wrap(
                          children: [
                            Text(
                              'I agree to the',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 10,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (await canLaunchUrl(Uri(
                                  scheme: 'https',
                                  host: 'docs.lyotrade.com',
                                  path: 'terms/terms-of-use',
                                ))) {
                                  await launchUrl(Uri(
                                    scheme: 'https',
                                    host: 'docs.lyotrade.com',
                                    path: 'terms/terms-of-use',
                                  ));
                                } else {
                                  // can't launch url, there is some error
                                  throw "Could not launch https://docs.lyotrade.com/terms/terms-of-use";
                                }
                              },
                              child: Text(
                                ' LYOTRADE Terms of Use',
                                style: TextStyle(
                                  color: linkColor,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Text(
                              ' and ',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 10,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (await canLaunchUrl(Uri(
                                  scheme: 'https',
                                  host: 'www.lyotrade.com',
                                  path: 'en_US/cms/agreement',
                                ))) {
                                  await launchUrl(Uri(
                                    scheme: 'https',
                                    host: 'www.lyotrade.com',
                                    path: 'en_US/cms/agreement',
                                  ));
                                } else {
                                  // can't launch url, there is some error
                                  throw "Could not launch https://docs.lyotrade.com/terms/privacy-policy";
                                }
                              },
                              child: Text(
                                'Privacy Notice',
                                style: TextStyle(
                                  color: linkColor,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            onPressed: (_enableSignup && termsAndCondition)
                ? () {
                    if (_formKey.currentState!.validate()) {
                      snackAlert(context, SnackTypes.warning, 'Processing...');
                      setState(() {
                        _enableSignup = false;
                      });

                      if (_emailSignup) {
                        widget.onRegister({
                          'email': _emailOrPhone.text,
                          'loginPword': _loginPword.text,
                          'newPassword': _newPassword.text,
                          'invitedCode': _invitedCode.text,
                          'emailSignup': _emailSignup,
                        });
                      } else {
                        widget.onRegister({
                          'countryCode': _currentCoutnry,
                          'mobileNumber': _emailOrPhone.text,
                          'loginPword': _loginPword.text,
                          'newPassword': _newPassword.text,
                          'invitedCode': _invitedCode.text,
                          'emailSignup': _emailSignup,
                        });
                      }
                    }
                  }
                : null,
            child: const Text('Sign Up'),
          ),
        ),
      ],
    );
  }
}
