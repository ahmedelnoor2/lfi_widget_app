import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliyun_captcha/flutter_aliyun_captcha.dart';
import 'package:k_chart/flutter_k_chart.dart';
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

class Forgotphoneform extends StatefulWidget {
  const Forgotphoneform({Key? key}) : super(key: key);

  @override
  _ForgotphoneformState createState() => _ForgotphoneformState();
}

class _ForgotphoneformState extends State<Forgotphoneform> {
  final GlobalKey<FormState> _formLoginKey = GlobalKey<FormState>();
  final TextEditingController _gauthController = TextEditingController();
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _smscontroller = TextEditingController();

  late Timer _timer;
  int _start = 90;
  bool _startTimer = false;
  Map _captchaVerification = {};
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

  @override
  void dispose() {
    _gauthController.dispose();
    _phonecontroller.dispose();
    _smscontroller.dispose();
    if (_channel != null) {
      _channel.sink.close();
    }
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
      setState(() {
        _captchaVerification = data['data'];
      });
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

  void startTimer() {
    setState(() {
      _startTimer = true;
    });
    smsValidCode();
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

  Future<void> forgotPasswordStepOne() async {
    var auth = Provider.of<Auth>(context, listen: false);
    await auth.forgotPasswordStepOne(context, {
      'token': true,
      'verificationType': _verificationType,
      'mobileNumber': _phonecontroller.text,
      'csessionid': kIsWeb
          ? _captchaVerification['csessionid']
          : _captchaVerification['sessionId'],
      'sig': _captchaVerification['sig'],
      'token': _captchaVerification['token'],
      "scene": "other"
    });
  }

  Future<void> smsValidCode() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.smsValidCode(context, {
      'operationType': '24',
      'smsType': '0',
      'token': auth.forgotStepOne['token'],
    });
  }

  Future<void> forgotPasswordStepTwo() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.resetForgotPasswordStepTwo(context, {
      'certifcateNumber': '123456',
      'googleCode':
          _gauthController.text.isNotEmpty ? _gauthController.text : '',
      'smsCode': _smscontroller.text,
      'token': auth.forgotStepOne['token'],
    });
    _timer.cancel();
  }

  void toggleLoginButton(value) {
    setState(() {
      _enableLogin = value;
    });
  }

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
                    controller: _phonecontroller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Mobile Phone';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      // border: OutlineInputBorder(),
                      labelText: 'Mobile Number',
                    ),
                  ),
                  auth.forgotStepOne.isNotEmpty
                      ? TextFormField(
                          controller: _smscontroller,
                          validator: (value) {
                            // if (value == null || value.isEmpty) {
                            //   return 'Please enter Mobilr Number';
                            // }
                            // return null;
                          },
                          decoration: InputDecoration(
                              // border: OutlineInputBorder(),
                              labelText: 'Mobile verification code',
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
                            // if (value == null || value.isEmpty) {
                            //   return 'Please enter Mobilr Number';
                            // }
                            // return null;
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
              onPressed: () async {
                if (_formLoginKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  if (auth.smsValidredponse['code'] == '0') {
                    forgotPasswordStepTwo().whenComplete(() {
                      if (auth.resetResponseStepTwo['msg'] == 'suc') {
                        Navigator.pushNamed(context, '/createpassword');
                      }
                    });
                  } else {
                    forgotPasswordStepOne();
                  }
                  //snackAlert(context, SnackTypes.warning, 'Processing...');
                  /// Navigator.pushNamed(context, '/createpassword');
                } else {
                  snackAlert(context, SnackTypes.warning,
                      'Please enter Mobile number');
                }
              },
            ),
          ),
          const SizedBox(
            height: 30,
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
