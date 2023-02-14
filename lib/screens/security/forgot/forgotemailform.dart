import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliyun_captcha/flutter_aliyun_captcha.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/captcha.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webviewx/webviewx.dart';

import '../../../utils/Colors.utils.dart';

class Forgotemailform extends StatefulWidget {
  const Forgotemailform({Key? key}) : super(key: key);

  @override
  _ForgotemailformState createState() => _ForgotemailformState();
}

class _ForgotemailformState extends State<Forgotemailform> {
  final GlobalKey<FormState> _formLoginKey = GlobalKey<FormState>();

  final TextEditingController _gauthController = TextEditingController();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _smscontroller = TextEditingController();

  Map _captchaVerification = {};
  late Timer _timer;
  int _start = 90;
  bool _startTimer = false;
  var uuid = const Uuid();
  var _channel;
  String _verificationType = '';
  WebViewXController? _controller;
  static final AliyunCaptchaController _captchaController =
      AliyunCaptchaController();
  bool _enableLogin = true;
  String _sessionId = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      _sessionId = uuid.v1();
    });
    if (kIsWeb) {
      connectWebSocket();
    }
    checkVerificationMethod();
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
      setState(() {
        _captchaVerification = data['data'];
      });
    }
  }

  @override
  void dispose() {
    _gauthController.dispose();
    _emailcontroller.dispose();
    _smscontroller.dispose();
    if (_channel != null) {
      _channel.sink.close();
    }
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _startTimer = true;
    });
    emailValidCode();
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _startTimer = false;
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

  Future<void> forgotPasswordStepOne() async {
    var auth = Provider.of<Auth>(context, listen: false);
    await auth.forgotPasswordStepOne(context, {
      'token': true,
      'verificationType': _verificationType,
      'email': _emailcontroller.text,
      'csessionid': kIsWeb
          ? _captchaVerification['csessionid']
          : _captchaVerification['sessionId'],
      'sig': _captchaVerification['sig'],
      'token': _captchaVerification['token'],
      "scene": "other"
    });
  }

  Future<void> emailValidCode() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.emailValidCode(context, {
      'operationType': '3',
      'token': auth.forgotStepOne['token'],
    });
  }

  Future<void> forgotPasswordStepTwo() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.resetForgotPasswordStepTwo(context, {
      'certifcateNumber': '',
      'googleCode':
          _gauthController.text.isNotEmpty ? _gauthController.text : '',
      'emailCode': _smscontroller.text,
      'token': auth.forgotStepOne['token'],
    });
    _timer.cancel();
  }

  void toggleLoginButton(value) {
    setState(() {
      _enableLogin = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: true);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 10,
          ),
          Form(
            key: _formLoginKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailcontroller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email address';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      // border: OutlineInputBorder(),
                      labelText: 'Email Address',
                    ),
                  ),
                  auth.forgotStepOne.isNotEmpty
                      ? TextFormField(
                          controller: _smscontroller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email verifiacation code';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              // border: OutlineInputBorder(),
                              labelText: 'Email verification code',
                              suffixIcon: GestureDetector(
                                onTap: _startTimer
                                    ? null
                                    : () {
                                        setState(() {
                                          _start = 90;
                                        });
                                        startTimer();
                                      },
                                child: Container(
                                  child: Text(
                                    _startTimer
                                        ? '${_start}s Get it again'
                                        : 'Click to send',
                                    style: TextStyle(
                                      color: _startTimer
                                          ? secondaryTextColor
                                          : linkColor,
                                    ),
                                  ),
                                  margin: const EdgeInsets.all(15.0),
                                  padding: const EdgeInsets.all(3.0),
                                ),
                              )),
                        )
                      : Container(),
                  auth.forgotStepOne['isGoogleAuth'] == '1'
                      ? TextFormField(
                          controller: _gauthController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter google auth';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Google Auth',
                          ))
                      : Container()
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Container(
              padding: EdgeInsets.all(width * 0.03),
              child: _verificationType == '1'
                  ? kIsWeb
                      ? Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: width,
                            padding:
                                EdgeInsets.only(left: 10, top: 10, right: 10),
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
                            setState(() {
                              _captchaVerification = value;
                            });
                          },
                          captchaController: _captchaController,
                        )
                  : Container(),
            ),
          ),
          Container(
            width: width * 0.93,
            child: LyoButton(
              text: 'Next',
              active: true,
              isLoading: auth.isforgotloader,
              activeColor: linkColor,
              activeTextColor: Colors.black,
              onPressed: () {
                if (_formLoginKey.currentState!.validate()) {
                  if (auth.emailValidredponse['code'] == '0') {
                    forgotPasswordStepTwo().whenComplete(() {
                      if (auth.resetResponseStepTwo['msg'] == 'suc') {
                        Navigator.pushNamed(context, '/createpassword');
                      }
                    });
                  } else {
                    forgotPasswordStepOne();
                  }
                } else {
                  snackAlert(context, SnackTypes.warning,
                      'Please enter Email Address');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptchaView() {
    return WebViewX(
      key: const ValueKey('webviewx'),
      height: height,
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
