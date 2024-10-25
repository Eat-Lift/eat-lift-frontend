import 'package:flutter/material.dart';
import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/password_textfield.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/relative_sizedbox.dart';
import '../custom_widgets/messages_box.dart';
import '../services/api_user_service.dart';

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

  Map<String, dynamic> response = {};

 void signIn(BuildContext context) async {
    bool emptyField = false;

    response = {};

    // Check if any fields are empty
    if (usernameController.text.isEmpty) {
      if (response.containsKey('errors')) {
        response['errors'].add("Repeat password field must be filled");
      } else {
        response['errors'] = ["Repeat password field must be filled"];
      }
      emptyField = true;
    } 
    if (emailController.text.isEmpty) {
      if (response.containsKey('errors')) {
        response['errors'].add("Email field must be filled");
      } else {
        response['errors'] = ["Email field must be filled"];
      }
      emptyField = true;
    }
    if (passwordController.text.isEmpty) {
      if (response.containsKey('errors')) {
        response['errors'].add("Password field must be filled");
      } else {
        response['errors'] = ["Password field must be filled"];
      }
      emptyField = true;
    }
    if (repeatPasswordController.text.isEmpty) {
      if (response.containsKey('errors')) {
        response['errors'].add("Repeat password field must be filled");
      } else {
        response['errors'] = ["Repeat password field must be filled"];
      }
    emptyField = true;
    }

    if (emptyField) {
      setState(() {});
      return;
    }

    // Check if the email format is valid
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
      response.addAll({"errors": ["Entera a valid email adress"]});
    }

    // Check if passwords match
    if (passwordController.text != repeatPasswordController.text) {
      response.addAll({"errors": ["Passwords do not match"]});
      return null;
    }

    // Perform the registration API call
    final apiService = ApiUserService();
    final result = await apiService.signIn(
      usernameController.text,
      emailController.text,
      passwordController.text,
    );

    // Update errorrs or success state
    setState(() {
        response = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
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
                onTap: () => signIn(context),
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