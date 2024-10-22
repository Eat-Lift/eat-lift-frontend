import 'package:flutter/material.dart';
import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/password_textfield.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/relative_sizedbox.dart';

class SigninPage extends StatelessWidget {
  SigninPage({super.key});

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  void signIn() {}

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
                onTap: signIn,
              ),

              const RelativeSizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}