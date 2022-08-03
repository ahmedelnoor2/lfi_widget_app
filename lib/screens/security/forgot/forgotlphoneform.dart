import 'package:flutter/material.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';

import '../../../utils/Colors.utils.dart';

class Forgotphoneform extends StatefulWidget {
  const Forgotphoneform({Key? key}) : super(key: key);

  @override
  _ForgotphoneformState createState() => _ForgotphoneformState();
}

class _ForgotphoneformState extends State<Forgotphoneform> {
  final GlobalKey<FormState> _formLoginKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Mobilr Number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        // border: OutlineInputBorder(),
                        labelText: 'Mobile verification code',
                        suffixIcon: GestureDetector(
                          onTap: () async {},
                          child: Container(
                            child: Text(
                              'Click to send',
                              style: TextStyle(
                                color: selecteditembordercolour,
                              ),
                            ),
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(3.0),
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: width * 0.93,
            child: ElevatedButton(
              child: const Text(
                "Next",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: selectboxcolour,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              ),
              onPressed: () {
                if (_formLoginKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  snackAlert(context, SnackTypes.warning, 'Processing...');
                  Navigator.pushNamed(context, '/createpassword');
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
}