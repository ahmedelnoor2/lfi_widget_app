
import 'package:flutter/material.dart';

import 'package:lyotrade/screens/security/forgot/widget/custom_text_field.dart';
import 'package:lyotrade/screens/security/forgot/widget/error_dialog.dart';
import 'package:lyotrade/screens/security/forgot/widget/loading_dialog.dart';



class Forgotloginform extends StatefulWidget {
  const Forgotloginform({Key? key}) : super(key: key);

  @override
  _ForgotloginformState createState() => _ForgotloginformState();
}



class _ForgotloginformState extends State<Forgotloginform>
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
            message: "Please write Phonenumber.",
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
                primary: Colors.cyan,
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
