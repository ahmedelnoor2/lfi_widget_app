import 'dart:async';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/captcha.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:flutter_aliyun_captcha/flutter_aliyun_captcha.dart';
// import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:slider_captcha/slider_capchar.dart';
import 'package:webviewx/webviewx.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  var uuid = const Uuid();
  var _channel;
  WebViewXController? _controller;
  static final AliyunCaptchaController _captchaController =
      AliyunCaptchaController();
  bool _enableLogin = true;

  final _formLoginKey = GlobalKey<FormState>();

  final String mobileNumber = '';
  final String loginPword = '';
  bool _readPassword = true;
  String _sessionId = '';

  String _verificationType = '';

  late TextEditingController _mobileNumber;
  late TextEditingController _loginPword;

  @override
  void initState() {
    setState(() {
      _sessionId = uuid.v1();
    });
    _mobileNumber = TextEditingController();
    _loginPword = TextEditingController();
    checkVerificationMethod();
    if (kIsWeb) {
      connectWebSocket();
    }
    super.initState();
  }

  @override
  void dispose() {
    _mobileNumber.dispose();
    _loginPword.dispose();
    if (_channel != null) {
      _channel.sink.close();
    }
    super.dispose();
  }

  void checkVerificationMethod() {
    var public = Provider.of<Public>(context, listen: false);

    if (public.publicInfo.isNotEmpty) {
      setState(() {
        _verificationType = public.publicInfo['switch']['verificationType'];
      });
    }
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

  void toggleLoginButton(value) {
    setState(() {
      _enableLogin = value;
    });
  }

  Future<void> getCaptchaData() async {
    var auth = Provider.of<Auth>(context, listen: false);
    // await auth.getCaptcha();
    // print(auth.captchaData);
    widget.onLogin({
      'mobileNumber': _mobileNumber.text,
      'loginPword': _loginPword.text,
    }, auth.captchaData);
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
        _verificationType == '1'
            ? kIsWeb
                ? Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: width,
                      padding: EdgeInsets.only(left: 10, top: 10, right: 10),
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
                    captchaController: _captchaController,
                  )
            : Container(),
        Container(
          padding: EdgeInsets.only(top: 20),
          child: LyoButton(
            text: 'Login',
            active: (_enableLogin || kIsWeb),
            isLoading: auth.isLoginloader,
            activeColor: linkColor,
            activeTextColor: Colors.black,
            onPressed: () {
              if (_formLoginKey.currentState!.validate()) {
                setState(() {
                  _enableLogin = false;
                });
                getCaptchaData();
              } else {
                _captchaController.refresh({});
                _captchaController.reset();
              }
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {
                snackAlert(context, SnackTypes.warning, 'Coming Soon...');
                // Navigator.pushNamed(context, '/forgotForgotpassword');
                // _callPlatformIndependentJsMethod();
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
