import 'package:flutter/material.dart';

import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/password_textfield.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/messages_box.dart';

import '../../services/api_user_service.dart';
import '../../services/session_storage.dart';

import 'personal_info.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  SigninPageState createState() => SigninPageState();
}

class SigninPageState extends State<SigninPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  final SessionStorage sessionStorage = SessionStorage();

  Map<String, dynamic> response = {};

 void signin(BuildContext context) async {
    bool emptyField = false;
    bool wrongField = false;

    response = {};

    if (usernameController.text.isEmpty) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Es requereix el nom d'usuari");
      } else {
        response['errors'] = ["Es requereix el nom d'usuari"];
      }
      emptyField = true;
    } 
    if (emailController.text.isEmpty) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Es requereix el correu electrònic");
      } else {
        response['errors'] = ["Es requereix el correu electrònic"];
      }
      emptyField = true;
    }
    if (passwordController.text.isEmpty) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Es requereix la contrasenya");
      } else {
        response['errors'] = ["Es requereix la contrasenya"];
      }
      emptyField = true;
    }
    if (repeatPasswordController.text.isEmpty) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Es requereix la confirmació de la contrasenya");
      } else {
        response['errors'] = ["Es requereix la confirmació de la contrasenya"];
      }
    emptyField = true;
    }

    if (emptyField) {
      setState(() {});
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
      response["success"] = false;
      wrongField = true;
      if (response.containsKey('errors')) {
        response['errors'].add("El correu electrònic no és vàlid");
      } else {
        response['errors'] = ["El correu electrònic no és vàlid"];
      }
    }

    if (passwordController.text != repeatPasswordController.text) {
      response["success"] = false;
      wrongField = true;
      if (response.containsKey('errors')) {
        response['errors'].add("Les contrasenyes no coincideixen");
      } else {
        response['errors'] = ["Les contrasenyes no coincideixen"];
      }
    }

    if (wrongField) {
      setState(() {});
      return;
    }

    final apiService = ApiUserService();
    final result = await apiService.signin(
      usernameController.text,
      emailController.text,
      passwordController.text,
    );

    if (result["success"]){
      await sessionStorage.saveSession(result["token"], result["user"]["id"].toString());
      if (context.mounted){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PersonalInfoPage()),
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
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RelativeSizedBox(height: 1),
              const Icon(
                Icons.lock,
                size: 100,
              ),

              const RelativeSizedBox(height: 0.5),

              Text(
                "Registra't",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 24,
                ),
              ),

              const RelativeSizedBox(height: 5),

              CustomTextfield(
                controller: usernameController,
                hintText: "Nom d'usuari",
                obscureText: false,
              ),

              const RelativeSizedBox(height:0.5),

              CustomTextfield(
                controller: emailController,
                hintText: "Correu electrònic",
                obscureText: false,
              ),

              const RelativeSizedBox(height:0.5),

              PasswordTextfield(
                controller: passwordController,
                hintText: "Contrasenya",
                obscureText: true,
              ),

              const RelativeSizedBox(height:0.5),

              PasswordTextfield(
                controller: repeatPasswordController,
                hintText: "Repeteix la contrasenya",
                obscureText: true,
              ),

              const RelativeSizedBox(height: 2),

              CustomButton(
                text: "Registrar-se",
                onTap: () => signin(context),
              ),

              const RelativeSizedBox(height: 2),

              if (response.isNotEmpty && !response["success"]) ...[
                MessagesBox(
                  messages: response["errors"],
                  height: 16,
                  color: Colors.red,
                ),
              ]
              else ...[
                RelativeSizedBox(height: 20)
              ]
            ],
          ),
        ),
      ),
    );
  }
}