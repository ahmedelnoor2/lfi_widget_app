import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:lyotrade/providers/loan_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import 'package:provider/provider.dart';

class Confirmloan extends StatefulWidget {
  static const routeName = '/confirm_loan';
  const Confirmloan({Key? key}) : super(key: key);

  @override
  State<Confirmloan> createState() => _ConfirmloanState();
}

class _ConfirmloanState extends State<Confirmloan> {
  bool agree = false;

  final TextEditingController _textEditingControllerAddress =
      TextEditingController();
  final TextEditingController _textEditingControllerEmail =
      TextEditingController();
  final TextEditingController _textEditingControllerhistory =
      TextEditingController();

  //  Future<void> doconfirm(loanid,reciveraddres,email) async {
  //   var loanProvider = Provider.of<LoanProvider>(context, listen: false);
  //   await loanProvider.getConfirm(loanid,reciveraddres,email);
  // }
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);

    return Scaffold(
        appBar: hiddenAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        'Confirm Crypto loan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      RaisedButton(
                        color: Colors.transparent,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: buttoncolour,
                                  content: Stack(
                                    children: <Widget>[
                                      Positioned(
                                        right: -40.0,
                                        top: -40.0,
                                        child: InkResponse(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: CircleAvatar(
                                            child: Icon(Icons.close),
                                            backgroundColor: Colors.red,
                                          ),
                                        ),
                                      ),
                                      Form(
                                        // key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              color: blackTextColor,
                                              height: 30,
                                              child:
                                                  Text('Show my loans history'),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text('Your Email'),
                                                Container(
                                                    child: TextField(
                                                  controller:
                                                      _textEditingControllerhistory,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText:
                                                        'example@domain.com',
                                                  ),
                                                  onChanged: (text) {
                                                    setState(() {
                                                      //  fullName = text;
                                                      //you can access nameController in its scope to get
                                                      // the value of text entered as shown below
                                                      //fullName = nameController.text;
                                                    });
                                                  },
                                                )),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: RaisedButton(
                                                color: blackTextColor,
                                                child: Text("Submitß"),
                                                onPressed: () {
                                                  if (_textEditingControllerhistory
                                                      .text.isEmpty) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Please insert email",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  } else {
                                                    loanProvider
                                                        .getLoanHistory(
                                                            _textEditingControllerhistory
                                                                .text
                                                                .trim())
                                                        .whenComplete(() => loanProvider
                                                                        .myloanhistory[
                                                                    'status'] ==
                                                                200
                                                            ? Fluttertoast.showToast(
                                                                msg:
                                                                    "Check your Email",
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .TOP,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    buttoncolour,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0)
                                                            : null);

                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                        child: Text("View All loan"),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      children: [
                        Text('Your loan:'),
                        Text(
                          loanProvider.loanstatus['loan']['expected_amount'] ??
                              '',
                        ),
                        Text('USDT'),
                        Container(
                          child: Text('ETH'),
                          margin: const EdgeInsets.all(15.0),
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent)),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Your deposit'),
                        Text('BTC'),
                        Text(
                          loanProvider.loanstatus['deposit']
                                  ['expected_amount'] ??
                              '',
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Container(
                          child: Text('BTC'),
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [Text('Loan Detail')],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Loan Term'),
                  Text('Unlimited'),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Monthly Interest Amount'),
                  Row(
                    children: [
                      Text(
                        loanProvider.loanestimate['interest_amounts']
                                ['month'] ??
                            'empty',
                      ),
                      Container(
                        child: Text('ETH'),
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent)),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('LTV'), Text('50%')],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Price Down Limit'),
                  Text(
                    loanProvider.loanestimate['down_limit'] + 'BTC/USDT' ??
                        'empty',
                  ),
                ],
              ),
              Divider(),
              Row(
                children: [
                  Text('Your USDT'),
                  Container(
                    child: Text('ETH'),
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent)),
                  ),
                  Text('payout address'),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                  child: TextField(
                controller: _textEditingControllerAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'TX7gY7ts8PpJYcupF4kHpkGazopd9jH8Cs',
                ),
                onChanged: (text) {
                  setState(() {
                    //  fullName = text;
                    //you can access nameController in its scope to get
                    // the value of text entered as shown below
                    //fullName = nameController.text;
                  });
                },
              )),
              Row(
                children: [Text('Your email')],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Container(
                    height: 100,
                    width: 200,
                    child: TextField(
                      controller: _textEditingControllerEmail,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'example@gmail.com',
                      ),
                      onChanged: (text) {
                        setState(() {
                          //  fullName = text;
                          //you can access nameController in its scope to get
                          // the value of text entered as shown below
                          //fullName = nameController.text;
                        });
                      },
                    ),
                  ),
                  Container(
                    child: Text('Verify'),
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent)),
                  )
                ],
              ),
              Row(
                children: [
                  Material(
                    child: Checkbox(
                      value: agree,
                      onChanged: (value) {
                        setState(() {
                          agree = value ?? false;
                        });
                      },
                    ),
                  ),
                  const Text(
                    'I have read and accept terms and conditions loytrade',
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    child: GestureDetector(
                        onTap: (() {
                          Navigator.pop(context);
                        }),
                        child: Text('Back')),
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent)),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        await agree
                            ? loanProvider
                                .getConfirm(
                                    _textEditingControllerAddress.text
                                        .toString(),
                                    _textEditingControllerEmail.text.toString())
                                .whenComplete(() => Fluttertoast.showToast(
                                    msg: "Confirm Your Loan Thanks",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0))
                            : null;
                      },
                      child: const Text('Confirm'))
                ],
              ),
            ],
          ),
        ));
  }
}
