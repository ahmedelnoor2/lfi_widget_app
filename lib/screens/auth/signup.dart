import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/screens/common/captcha.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lyotrade/utils/Country.utils.dart';
import 'package:flutter_aliyun_captcha/flutter_aliyun_captcha.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:webviewx/webviewx.dart';

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
  var uuid = const Uuid();
  var _channel;
  WebViewXController? _controller;
  static final AliyunCaptchaController _captchaController =
      AliyunCaptchaController();
  late final TabController _tabController =
      TabController(length: 1, vsync: this);

  bool _enableSignup = true;
  final _formKey = GlobalKey<FormState>();

  String _verificationType = '';

  bool termsAndCondition = false;
  bool _emailSignup = true;
  String _currentCoutnry = '${countries[0]['code']}';

  bool _readPassword = true;
  bool _readConfirmPassword = true;

  String _sessionId = '';

  late TextEditingController _emailOrPhone;
  late TextEditingController _loginPword;
  late TextEditingController _newPassword;
  late TextEditingController _invitedCode;

  @override
  void initState() {
    setState(() {
      _sessionId = uuid.v1();
    });
    if (kIsWeb) {
      connectWebSocket();
    }
    checkVerificationMethod();
    _emailOrPhone = TextEditingController();
    _loginPword = TextEditingController();
    _newPassword = TextEditingController();
    _invitedCode = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    if (_channel != null) {
      _channel.sink.close();
    }
    _emailOrPhone.dispose();
    _loginPword.dispose();
    _newPassword.dispose();
    _invitedCode.dispose();
    super.dispose();
  }

  Future<void> connectWebSocket() async {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://api.m.lyotrade.com:8060/'),
    );

    _channel.sink.add(_sessionId);

    _channel.stream.listen((message) {
      extractStreamData(message);
    });
  }

  void extractStreamData(streamData) async {
    if (streamData != null) {
      final data = jsonDecode(streamData);
      widget.onCaptchaVerification(data['data']);
    }
  }

  void checkVerificationMethod() {
    var auth = Provider.of<Auth>(context, listen: false);
    auth.setGoogleAuth(false);
    var public = Provider.of<Public>(context, listen: false);

    if (public.publicInfo.isNotEmpty) {
      setState(() {
        _verificationType = public.publicInfo['switch']['verificationType'];
      });
    }
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
    var auth = Provider.of<Auth>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: width * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Sign Up to get started',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 16,
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
            // Padding(
            //   padding: EdgeInsets.only(right: 25),
            //   child: Tab(text: ''),
            // ),
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
                      // Column(
                      //   children: [
                      //     FormField<String>(
                      //       builder: (FormFieldState<String> state) {
                      //         return InputDecorator(
                      //           decoration: const InputDecoration(
                      //             errorStyle: TextStyle(
                      //               color: Colors.redAccent,
                      //               fontSize: 12,
                      //             ),
                      //             hintText: 'Please select expense',
                      //           ),
                      //           isEmpty: countries[0]['country'] == 0,
                      //           child: DropdownButtonHideUnderline(
                      //             child: FittedBox(
                      //               child: DropdownButton<String>(
                      //                 isExpanded: false,
                      //                 value: _currentCoutnry,
                      //                 isDense: true,
                      //                 onChanged: (newValue) {
                      //                   setState(() {
                      //                     _currentCoutnry = '$newValue';
                      //                   });
                      //                 },
                      //                 items: countries.map((value) {
                      //                   return DropdownMenuItem<String>(
                      //                     value: '${value['code']}',
                      //                     child: Text(
                      //                         '${value['country']} ${value['code']}'),
                      //                   );
                      //                 }).toList(),
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //     ),
                      //     TextFormField(
                      //       validator: (value) {
                      //         if (value == null || value.isEmpty) {
                      //           return 'Please enter phone number';
                      //         }
                      //         return null;
                      //       },
                      //       keyboardType: TextInputType.number,
                      //       decoration: const InputDecoration(
                      //         labelText: 'Phone Number',
                      //       ),
                      //       controller: _emailOrPhone,
                      //     ),
                      //   ],
                      // ),
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
                  padding: const EdgeInsets.only(top: 5),
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
        _verificationType == '1'
            ? kIsWeb
                ? Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: width,
                      padding: EdgeInsets.only(left: 10, top: 0, right: 10),
                      child: _buildCaptchaView(),
                    ),
                  )
                : Captcha(
                    onCaptchaVerification: (value) {
                      toggleLoginButton(true);
                      if (value.containsKey('sig')) {
                      } else {
                        toggleLoginButton(false);
                      }
                      widget.onCaptchaVerification(value);
                    },
                  )
            : Container(),
        Container(
          padding: EdgeInsets.only(top: 10),
          child: LyoButton(
            text: 'Sign Up',
            active: (_enableSignup && termsAndCondition),
            isLoading: auth.emailSignupLoader,
            activeColor: linkColor,
            activeTextColor: Colors.black,
            onPressed: (_enableSignup && termsAndCondition)
                ? () {
                    if (_formKey.currentState!.validate()) {
                      //snackAlert(context, SnackTypes.warning, 'Processing...');
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
                        }, _captchaController);
                      } else {
                        widget.onRegister({
                          'countryCode': _currentCoutnry,
                          'mobileNumber': _emailOrPhone.text,
                          'loginPword': _loginPword.text,
                          'newPassword': _newPassword.text,
                          'invitedCode': _invitedCode.text,
                          'emailSignup': _emailSignup,
                        }, _captchaController);
                      }
                      setState(() {
                        _enableSignup = true;
                      });
                    } else {
                      _captchaController.reset();
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCaptchaView() {
    return WebViewX(
      key: const ValueKey('webviewx'),
      height: height * 0.09,
      width: width,
      initialContent: '<div></div>',
      initialSourceType: SourceType.html,
      onWebViewCreated: (controller) async {
        _controller = controller;
        await _controller!.loadContent(
            'https://captcha.m.lyotrade.com?userId=$_sessionId',
            SourceType.url);
      },
      onPageStarted: (src) =>
          debugPrint('A new page has started loading: $src\n'),
      onPageFinished: (src) =>
          debugPrint('The page has finished loading: $src\n'),
    );
  }
}
