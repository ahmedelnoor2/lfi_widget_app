import 'package:flutter/material.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';

class PixProcessPayment extends StatefulWidget {
  static const routeName = '/pix_process_payment';
  const PixProcessPayment({Key? key}) : super(key: key);

  @override
  State<PixProcessPayment> createState() => _PixProcessPaymentState();
}

class _PixProcessPaymentState extends State<PixProcessPayment>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('data'),
    );
  }
}
