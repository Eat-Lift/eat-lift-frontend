import 'package:eatnlift/pages/user/login.dart';
import 'package:flutter/material.dart';

import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/password_textfield.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/messages_box.dart';

import '../../services/api_user_service.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;

  const NewPasswordPage({
    required this.email,
    super.key
  });

  @override
  NewPasswordPageState createState() => NewPasswordPageState();
}
class NewPasswordPageState extends State<NewPasswordPage> {
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final repeatNewPasswordController = TextEditingController();

  Map<String, dynamic> response = {};

  void newPassword(BuildContext context) async {
    bool emptyField = false;
    bool wrongField = false;

    response = {};

    if (newPasswordController.text.isEmpty) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Es requereix la nova contrasenya");
      } else {
        response['errors'] = ["Es requereix la nova contrasenya"];
      }
      emptyField = true;
    }
    if (repeatNewPasswordController.text.isEmpty) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Es requereix la confirmació de la nova contrasenya");
      } else {
        response['errors'] = ["Es requereix la confirmació de la nova contrasenya"];
      }
      emptyField = true;
    }
    if (codeController.text.isEmpty) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Es requereix el codi de recuperació");
      } else {
        response['errors'] = ["Es requereix el codi de recuperació"];
      }
      emptyField = true;
    }

    if (emptyField) {
      setState(() {});
      return;
    }

    if (newPasswordController.text != repeatNewPasswordController.text) {
      response["success"] = false;
      wrongField = true;
      if (response.containsKey('errors')) {
        response['errors'].add("Les contrasenyes no coincideixen");
      } else {
        response['errors'] = ["Les contrasenyes no coincideixen"];
      }
    }

    if (!RegExp(r'^\d{6}$').hasMatch(codeController.text)) {
      response["success"] = false;
      wrongField = true;
      if (response.containsKey('errors')) {
        response['errors'].add("El codi ha de ser un número de 6 dígits");
      } else {
        response['errors'] = ["El codi ha de ser un número de 6 dígits"];
      }
    }

    if (wrongField) {
      setState(() {});
      return;
    }

    final apiService = ApiUserService();
    final result = await apiService.newPassword(
      codeController.text,
      newPasswordController.text,
      widget.email
    );

    setState(() {
        response = result;
    });

    if (result["success"]) {
      if (context.mounted) {
        Future.delayed(const Duration(seconds: 5), () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text("Nova contrasenya"),   
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RelativeSizedBox(height: 1),

              const Icon(
                Icons.lock,
                size: 100,
              ),

              const RelativeSizedBox(height: 5),

              SizedBox(
                width: 330,
                child: Text(
                  "Introdueix el codi que has rebut en el correu electrònic per poder reestablir la contrasenya del teu compte",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const RelativeSizedBox(height: 3),

              CustomTextfield(
                controller: codeController,
                hintText: "Codi de recuperació",
                obscureText: false,
                maxLength: 6,
                isNumeric: true,
              ),

              const RelativeSizedBox(height: 0.5),

              PasswordTextfield(
                controller: newPasswordController,
                hintText: "Nova contrasenya",
                obscureText: true,
              ),

              const RelativeSizedBox(height: 0.5),

              PasswordTextfield(
                controller: repeatNewPasswordController,
                hintText: "Repeteix la nova contrasenya",
                obscureText: true,
              ),

              const RelativeSizedBox(height: 2),

              CustomButton(
                text: "Recuperar Contrasenya",
                onTap: () => newPassword(context),
              ),

              const RelativeSizedBox(height: 5),

              if (response.isNotEmpty && !response["success"]) ...[
                MessagesBox(
                  messages: response["errors"],
                  height: 20,
                  color: Colors.red,
                ),
              ]
              else if (response.isNotEmpty && response["success"]) ...[
                MessagesBox(
                  messages: response["messages"],
                  height: 6,
                  color: Colors.green,
                ),
                RelativeSizedBox(height: 10)
              ]
              else ...[
                RelativeSizedBox(height: 10)
              ]
            ],
          ),
        ),
      ),
    );
  }
}