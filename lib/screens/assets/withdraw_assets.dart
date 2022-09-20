import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/screens/assets/common/networks.dart';
import 'package:lyotrade/screens/assets/common/qr_scanner.dart';
import 'package:lyotrade/screens/common/alert.dart';
import 'package:lyotrade/screens/common/drawer.dart';
import 'package:lyotrade/screens/common/header.dart';

import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Coins.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';

class WithdrawAssets extends StatefulWidget {
  static const routeName = '/withdraw_assets';
  const WithdrawAssets({Key? key}) : super(key: key);

  @override
  State<WithdrawAssets> createState() => _WithdrawAssetsState();
}

class _WithdrawAssetsState extends State<WithdrawAssets> {
  final _formVeriKey = GlobalKey<FormState>();
  final _formEmailVeriKey = GlobalKey<FormState>();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _emailVeirficationCode = TextEditingController();
  final TextEditingController _smsVeirficationCode = TextEditingController();
  final TextEditingController _googleVeirficationCode = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var cameras = [];

  bool _openQrScanner = false;
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  String _defaultNetwork = 'USDTBSC';
  String _coinShowName = 'EUSDT';
  String _defaultCoin = 'USDT';
  List _allNetworks = [];
  bool _verifyAddress = false;
  bool _validateEmailProcess = false;

  late Timer _timer;
  int _start = 90;
  bool _startTimer = false;

  late Timer _timerSms;
  int _startSms = 90;
  bool _startTimerSms = false;

  @override
  void initState() {
    getDigitalBalance();
    Future.delayed(const Duration(seconds: 0), () async {
      cameras = await availableCameras();
      checkUserAuthMethods();
    });
    super.initState();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _emailVeirficationCode.dispose();
    _smsVeirficationCode.dispose();
    _googleVeirficationCode.dispose();
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

  void startMobileTimer() {
    setState(() {
      _startTimerSms = true;
    });
    sendSmsVerificationCode();
    const oneSec = Duration(seconds: 1);
    _timerSms = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _startTimerSms = false;
            _timerSms.cancel();
          });
        } else {
          setState(() {
            _startSms--;
          });
        }
      },
    );
  }

  Future<void> sendSmsVerificationCode() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.sendMobileValidCode(context, {
      'token': '',
      'operationType': '10',
      'smsType': '0',
    });
  }

  Future<void> sendVerificationCode() async {
    var auth = Provider.of<Auth>(context, listen: false);

    await auth.sendEmailValidCode(context, {
      'token': '',
      'email': '',
      'operationType': '17',
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    if (controller != null) {
      controller!.resumeCamera();
    }
  }

  Future<void> getDigitalBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getAccountBalance(context, auth, "");
    getCoinCosts(_defaultCoin);
  }

  Future<void> getCoinCosts(netwrkType) async {
    setState(() {
      _defaultCoin = netwrkType;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);

    if (public.publicInfoMarket['market']['followCoinList'][netwrkType] !=
        null) {
      setState(() {
        _allNetworks.clear();
      });

      public.publicInfoMarket['market']['followCoinList'][netwrkType]
          .forEach((k, v) {
        setState(() {
          _allNetworks.add(v);
          _defaultCoin = netwrkType;
          _defaultNetwork = '${v['name']}';
          _coinShowName = '${v['name']}';
        });
      });
    } else {
      setState(() {
        _allNetworks.clear();
        _allNetworks
            .add(public.publicInfoMarket['market']['coinList'][netwrkType]);
        _defaultCoin = netwrkType;
        _defaultNetwork =
            '${public.publicInfoMarket['market']['coinList'][netwrkType]['name']}';
        _coinShowName =
            '${public.publicInfoMarket['market']['coinList'][netwrkType]['name']}';
      });
    }

    await asset.getCoinCosts(auth, _coinShowName);
    // await asset.getChangeAddress(context, auth, _defaultCoin);

    List _digitialAss = [];
    asset.accountBalance['allCoinMap'].forEach((k, v) {
      if (v['depositOpen'] == 1) {
        _digitialAss.add({
          'coin': k,
          'values': v,
        });
      }
    });
    asset.setDigAssets(_digitialAss);
  }

  Future<void> changeCoinType(netwrk) async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    setState(() {
      _defaultNetwork = netwrk['name'];
      _coinShowName = '${netwrk['name']}';
    });

    await asset.getCoinCosts(auth, netwrk['name']);
    // await asset.getChangeAddress(context, auth, netwrk['showName']);
  }

  Future<void> checkUserAuthMethods() async {
    var auth = Provider.of<Auth>(context, listen: false);
    if (auth.userInfo.isNotEmpty) {
      if (auth.userInfo['googleStatus'] == 0 &&
          auth.userInfo['mobileNumber'].isEmpty) {
        return showAlert(
          context,
          Icon(
            Icons.featured_play_list,
          ),
          'Tips',
          const <Widget>[
            Text(
              'For the security of your account, please open at least one verification method',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            ListTile(
              title: Text(
                'Connect Google verification',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              trailing: Icon(
                Icons.check,
                size: 15,
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Connect mobile phone verification',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              trailing: Icon(
                Icons.check,
                size: 15,
              ),
            ),
            Divider(),
          ],
          'Settings',
        );
      }
    }
  }

  void addressController(text) {
    _addressController.text = text;
  }

  void toggleOpenQrScanner() {
    setState(() {
      _openQrScanner = false;
    });
  }

  Future<void> verifyAddress() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    if (auth.userInfo['googleStatus'] == 0) {
      return showAlert(
        context,
        Icon(
          Icons.featured_play_list,
        ),
        'Tips',
        <Widget>[
          Text(
            'For the security of your account, please open at least one verification method',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          ListTile(
            title: Text(
              'Connect Google verification',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            trailing: Icon(
              Icons.check,
              size: 15,
              color: (auth.userInfo['googleStatus'] == 0)
                  ? secondaryTextColor
                  : greenIndicator,
            ),
          ),
          Divider(),
        ],
        'Settings',
      );
    } else {
      setState(() {
        _validateEmailProcess = true;
        _verifyAddress = true;
      });

      asset.withdrawAddressValidate(context, auth, {
        "address": _addressController.text,
        "coinSymbol": _coinShowName,
      });
      setState(() {
        _verifyAddress = false;
      });
    }
  }

  Future<void> processWithdrawAmount() async {
    setState(() {
      _validateEmailProcess = false;
      _verifyAddress = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    var _postData = {
      "address": _addressController.text,
      "addressId": "",
      "amount": _amountController.text,
      "emailValidCode": _emailVeirficationCode.text,
      "fee": '${asset.getCost['defaultFee']}',
      "googleCode": _googleVeirficationCode.text,
      "symbol": _coinShowName,
      "trustType": 0,
    };
    if (auth.userInfo['mobileNumber'].isNotEmpty) {
      _postData['smsValidCode'] = _smsVeirficationCode.text;
    }

    asset.processWithdrawal(context, auth, _postData);
    getDigitalBalance();
    setState(() {
      _addressController.clear();
      _amountController.clear();
      _verifyAddress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var asset = Provider.of<Asset>(context, listen: true);
    var public = Provider.of<Public>(context, listen: true);

    return Scaffold(
      key: _scaffoldKey,
      appBar: hiddenAppBar(),
      drawer: drawer(
        context,
        width,
        height,
        asset,
        public,
        _searchController,
        getCoinCosts,
      ),
      body: _validateEmailProcess
          ? withdrawAmount(context)
          : GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Form(
                key: _formVeriKey,
                child: _openQrScanner
                    ? QrScanner(
                        addressController: addressController,
                        toggleOpenQrScanner: toggleOpenQrScanner,
                      )
                    : SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(
                            right: 15,
                            left: 15,
                            bottom: 15,
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  bottom: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(right: 20),
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            icon: Icon(Icons.chevron_left),
                                          ),
                                        ),
                                        Text(
                                          'Withdraw',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/transactions');
                                      },
                                      icon: Icon(Icons.history),
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _scaffoldKey.currentState!.openDrawer();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      style: BorderStyle.solid,
                                      width: 0.3,
                                      color: Color(0xff5E6292),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(right: 10),
                                            child: CircleAvatar(
                                              radius: 12,
                                              child: Image.network(
                                                '${public.publicInfoMarket['market']['coinList'][_defaultCoin]['icon']}',
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(right: 5),
                                            child: Text(
                                              '$_defaultCoin',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${public.publicInfoMarket['market']['coinList'][_defaultCoin]['longName']}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.keyboard_arrow_down),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 20, bottom: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Text('Chain name'),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Icon(
                                        Icons.help_outline,
                                        size: 12,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Text('Fee:'),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Text(
                                        '${asset.getCost['defaultFee']}',
                                        style: TextStyle(
                                          color: linkColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Text(_defaultCoin),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(bottom: 10),
                                height: 45,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _allNetworks.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var network = _allNetworks[index];
                                      return GestureDetector(
                                        onTap: () {
                                          _formVeriKey.currentState!.reset();
                                          _addressController.clear();
                                          _amountController.clear();
                                          _emailVeirficationCode.clear();
                                          _smsVeirficationCode.clear();
                                          _googleVeirficationCode.clear();
                                          changeCoinType(network);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.only(right: 10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: (network['name'] ==
                                                      _defaultNetwork)
                                                  ? Color(0xff01FEF5)
                                                  : Color(0xff5E6292),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Container(
                                              width: 62,
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "${network['mainChainName']}",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Wallet Address'),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Text(
                                        'Address List',
                                        style: TextStyle(
                                          color: linkColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5, bottom: 10),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      style: BorderStyle.solid,
                                      width: 0.3,
                                      color: Color(0xff5E6292),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: width * 0.69,
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter wallet address';
                                            }
                                            return null;
                                          },
                                          controller: _addressController,
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            hintStyle: TextStyle(
                                              fontSize: 14,
                                            ),
                                            hintText:
                                                "Scan or paste the address",
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(right: 10),
                                            child: GestureDetector(
                                              onTap: () async {
                                                print('paste');
                                                ClipboardData? data =
                                                    await Clipboard.getData(
                                                        Clipboard.kTextPlain);
                                                _addressController.text =
                                                    '${data!.text}';
                                              },
                                              child: Text(
                                                'Paste',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: linkColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          (kIsWeb || cameras.isEmpty)
                                              ? Container()
                                              : GestureDetector(
                                                  onTap: () async {
                                                    setState(() {
                                                      _openQrScanner = true;
                                                    });
                                                    await controller
                                                        ?.resumeCamera();
                                                  },
                                                  child: Icon(
                                                    Icons.qr_code_scanner,
                                                    color: linkColor,
                                                    size: 20,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Amount'),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5, bottom: 10),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      style: BorderStyle.solid,
                                      width: 0.3,
                                      color: Color(0xff5E6292),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: width * 0.69,
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter amount';
                                            } else if (double.parse(value) >
                                                (double.parse(
                                                        asset.accountBalance[
                                                                    'allCoinMap']
                                                                [_defaultCoin][
                                                            'normal_balance']) -
                                                    double.parse(
                                                        '${asset.getCost['defaultFee']}'))) {
                                              return 'Maximum withdrawal amount is ${truncateTo('${(double.parse(asset.accountBalance['allCoinMap'][_defaultCoin]['normal_balance']) - double.parse('${asset.getCost['defaultFee']}'))}', public.publicInfo['market']['coinList'][_defaultCoin]['showPrecision'] ?? 2)}';
                                            } else if (double.parse(value) <
                                                asset.getCost['withdraw_min']) {
                                              return 'Minimum withdrawal amount is ${asset.getCost['withdraw_min']}';
                                            }
                                            return null;
                                          },
                                          controller: _amountController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                            decimal: true,
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            hintStyle: TextStyle(
                                              fontSize: 14,
                                            ),
                                            hintText:
                                                "Min. withdrawal ${asset.getCost['withdraw_min']} ${asset.getCost['withdrawLimitSymbol']}",
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(right: 10),
                                            child: GestureDetector(
                                              onTap: () async {
                                                _amountController.text = truncateTo(
                                                    '${(double.parse(asset.accountBalance['allCoinMap'][_defaultCoin]['normal_balance']) - double.parse('${asset.getCost['defaultFee']}'))}',
                                                    public.publicInfo['market']
                                                                    ['coinList']
                                                                [_defaultCoin]
                                                            ['showPrecision'] ??
                                                        2);
                                              },
                                              child: Text(
                                                'ALL',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: linkColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  top: 20,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(bottom: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Balances',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${asset.accountBalance['allCoinMap'] != null ? asset.accountBalance['allCoinMap'][_defaultCoin]['total_balance'] : '--'}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(bottom: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Available',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${asset.accountBalance['allCoinMap'] != null ? asset.accountBalance['allCoinMap'][_defaultCoin]['normal_balance'] : '--'}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(bottom: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Freeze',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${asset.accountBalance['allCoinMap'] != null ? asset.accountBalance['allCoinMap'][_defaultCoin]['lock_balance'] : '--'}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              Container(
                                padding: EdgeInsets.only(
                                  top: 5,
                                  bottom: 10,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(bottom: 15),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Tips',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(bottom: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Withdrawable',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                          Text(
                                            '${asset.getCost['can_withdraw_amount']} $_defaultCoin',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(bottom: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '24h Withdrawal Limit',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                          Text(
                                            '${double.parse(asset.getCost['left_withdraw_daily_amount'] ?? '0.00').toStringAsFixed(2)}/${double.parse(asset.getCost['total_withdraw_daily_max_limit'] ?? '0.00').toStringAsFixed(2)} ${asset.getCost.isNotEmpty ? getCoinName(asset.getCost['withdrawLimitSymbol']) : '--'}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(bottom: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    right: 5),
                                                child: Icon(
                                                  Icons.warning,
                                                  size: 15,
                                                  color: orangeBGColor,
                                                ),
                                              ),
                                              Text(
                                                'Max Limit:',
                                                style: TextStyle(
                                                    color: orangeBGColor),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${asset.getCost['withdraw_max']} ${asset.getCost['withdrawLimitSymbol']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
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
              ),
            ),
      bottomNavigationBar: Container(
        height: height * 0.1,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _validateEmailProcess
                ? Container()
                : Container(
                    padding: EdgeInsets.only(bottom: 15),
                    width: width * 0.9,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formVeriKey.currentState!.validate()) {
                          verifyAddress();
                          // showModalBottomSheet<void>(
                          //   context: context,
                          //   isScrollControlled: true,
                          //   builder: (BuildContext context) {
                          //     return StatefulBuilder(
                          //       builder:
                          //           (BuildContext context, StateSetter setState) {
                          //         return Scaffold(
                          //           resizeToAvoidBottomInset: false,
                          //           appBar: hiddenAppBarWithDefaultHeight(),
                          //           body: withdrawAmount(
                          //             context,
                          //             setState,
                          //           ),
                          //         );
                          //       },
                          //     );
                          //   },
                          // );
                        }
                      },
                      child: Text('Withdraw'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget withdrawAmount(
    context,
  ) {
    var auth = Provider.of<Auth>(context, listen: false);

    return Form(
      key: _formEmailVeriKey,
      child: Container(
        height: height,
        padding: EdgeInsets.only(
          top: 10,
          right: 10,
          left: 10,
          bottom: 30,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Process Withdraw',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _validateEmailProcess = false;
                    });
                  },
                  icon: Icon(
                    Icons.close,
                    size: 20,
                  ),
                )
              ],
            ),
            Divider(),
            _verifyAddress
                ? Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : Container(),
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.only(top: 15, bottom: 15, left: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  style: BorderStyle.solid,
                  width: 0.3,
                  color: Color(0xff5E6292),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.49,
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Email verification code';
                        }
                        return null;
                      },
                      controller: _emailVeirficationCode,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: 'Email verification code',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: TextButton(
                      onPressed: _startTimer
                          ? null
                          : () {
                              setState(() {
                                _start = 90;
                              });
                              startTimer();
                            },
                      child: Text(_startTimer
                          ? '${_start}s Get it again'
                          : 'Click to send'),
                    ),
                  ),
                ],
              ),
            ),
            auth.userInfo['mobileNumber'].isEmpty
                ? Container()
                : Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.only(top: 15, bottom: 15, left: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        style: BorderStyle.solid,
                        width: 0.3,
                        color: Color(0xff5E6292),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: width * 0.49,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter SMS verification code';
                              }
                              return null;
                            },
                            controller: _smsVeirficationCode,
                            decoration: InputDecoration(
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
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: TextButton(
                            onPressed: _startTimerSms
                                ? null
                                : () {
                                    setState(() {
                                      _startSms = 90;
                                    });
                                    startMobileTimer();
                                  },
                            child: Text(_startTimerSms
                                ? '${_startSms}s Get it again'
                                : 'Click to send'),
                          ),
                        ),
                      ],
                    ),
                  ),
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.only(top: 15, bottom: 15, left: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  style: BorderStyle.solid,
                  width: 0.3,
                  color: Color(0xff5E6292),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.49,
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter google verification code';
                        }
                        return null;
                      },
                      controller: _googleVeirficationCode,
                      decoration: InputDecoration(
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
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () async {
                        ClipboardData? data = await Clipboard.getData(
                          Clipboard.kTextPlain,
                        );
                        _googleVeirficationCode.text = '${data!.text}';
                      },
                      child: Text(
                        'Paste',
                        style: TextStyle(
                          fontSize: 14,
                          color: linkColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              child: LyoButton(
                text: 'Verify',
                active: true,
                isLoading: false,
                activeColor: linkColor,
                activeTextColor: Colors.black,
                onPressed: () async {
                  if (_formEmailVeriKey.currentState!.validate()) {
                    // if (!auth.googleAuth) {
                    //   _timer.cancel();
                    // }
                    processWithdrawAmount();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
