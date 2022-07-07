
import 'package:flutter/material.dart';

import 'package:lyotrade/screens/security/forgot/widget/custom_text_field.dart';
import 'package:lyotrade/screens/security/forgot/widget/error_dialog.dart';
import 'package:lyotrade/screens/security/forgot/widget/loading_dialog.dart';

import '../../../utils/Colors.utils.dart';



class Forgotemailform extends StatefulWidget {
  const Forgotemailform({Key? key}) : super(key: key);

  @override
  _ForgotemailformState createState() => _ForgotemailformState();
}



class _ForgotemailformState extends State<Forgotemailform>
{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();



  formValidation()
  {
    if(emailController.text.isNotEmpty )
    {
      //login
      loginNow();
    }
    else
    {
      showDialog(
        context: context,
        builder: (c)
        {
          return ErrorDialog(
            message: "Please write Email.",
          );
        }
      );
    }
  }


  loginNow() async
  {
    showDialog(
        context: context,
        builder: (c)
        {
          return LoadingDialog(
            message: "Checking Credentials",
          );
        }
    );

   
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
         SizedBox(height: 50,),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  data: Icons.password,
                  controller: emailController,
                  hintText: "Email",
                  isObsecre: false,
                ),
                
              ],
            ),
          ),
          Container(
            width: 380,
            child: ElevatedButton(
              child: const Text(
                "Next",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
              ),
              style: ElevatedButton.styleFrom(
              primary: bluechartColor,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              ),
              onPressed: ()
              {
                formValidation();
              },
            ),
          ),
          const SizedBox(height: 30,),
        ],
      ),
    );
  }
}
