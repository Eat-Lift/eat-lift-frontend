import 'package:flutter/material.dart';

import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/messages_box.dart';

import 'new_password.dart';

import '../../services/api_user_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ResetPasswordPageState createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final emailController = TextEditingController();

  Map<String, dynamic> response = {};

  void resetPassword(BuildContext context) async {

    response = {};

    if (emailController.text.isEmpty) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Es requereix el correu electrònic");
      } else {
        response['errors'] = ["Es requereix el correu electrònic"];
      }
      setState(() {});
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("El correu electrònic no és vàlid");
      } else {
        response['errors'] = ["El correu electrònic no és vàlid"];
      }
      setState(() {});
      return;
    }

    final apiService = ApiUserService();
    final result = await apiService.resetPassword(
      emailController.text,
    );

    if (result["success"]){
      if (context.mounted){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NewPasswordPage(email: emailController.text)),
        );
      }
    }

    setState(() {
        response = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text("Recuperar contrasenya"),   
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RelativeSizedBox(height: 10),

              const Icon(
                Icons.lock,
                size: 100,
              ),

              const RelativeSizedBox(height: 5),

              SizedBox(
                width: 330,
                child: Text(
                  "Introdueix el correu electrònic associat al teu compte",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const RelativeSizedBox(height: 5),

              CustomTextfield(
                controller: emailController,
                hintText: "Correu electrònic",
                obscureText: false,
              ),

              const RelativeSizedBox(height: 2),

              CustomButton(
                text: "Recuperar Contrasenya",
                onTap: () => resetPassword(context),
              ),

              RelativeSizedBox(height: 5),

              if (response.isNotEmpty && !response["success"]) ...[
                MessagesBox(
                  messages: response["errors"],
                  height: 6,
                  color: Colors.red,
                ),

                RelativeSizedBox(height: 25)
              ]
              else ...[
                RelativeSizedBox(height: 25)
              ]
            ],
          ),
        ),
      ),
    );
  }
}