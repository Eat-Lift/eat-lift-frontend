import 'package:flutter/material.dart';
import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/password_textfield.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/relative_sizedbox.dart';
import '../custom_widgets/messages_box.dart';
import '../services/api_user_service.dart';

class SigninPage extends StatefulWidget {
  SigninPage({super.key});

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  Map<String, dynamic> errors = {};

  Future<Map<String, dynamic>?> signIn(BuildContext context) async {
    bool emptyField = false;

    errors = {};

    // Check if any fields are empty
    if (usernameController.text.isEmpty) {
      setState(() {
        errors.addAll({"username": ["Username field must be filled"]});
      });
      emptyField = true;
    } 
    if (emailController.text.isEmpty) {
      setState(() {
        errors.addAll({"email": ["Email field must be filled"]});
      });
      emptyField = true;
    }
    if (passwordController.text.isEmpty) {
      setState(() {
        errors.addAll({"password": ["Password field must be filled"]});
      });
      emptyField = true;
    }
    if (repeatPasswordController.text.isEmpty) {
      setState(() {
        if (errors.containsKey('password')) {
          errors['password'].add("Repeat password field must be filled");
        } else {
          errors['password'] = ["Repeat password field must be filled"];
        }
      });
      emptyField = true;
    }

    if (emptyField) return null;

    // Check if the email format is valid
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
      setState((){
        errors.addAll({"email": ["Entera a valid email adress"]});
      });
      return null;
    }

    // Check if passwords match
    if (passwordController.text != repeatPasswordController.text) {
      setState((){
        errors.addAll({"password": ["Passwords do not match"]});
      });
      return null;
    }

    // Perform the registration API call
    final apiService = ApiUserService();
    final result = await apiService.signIn(
      usernameController.text,
      emailController.text,
      passwordController.text,
    );

    // Update errors state
    setState(() {
      errors = result;
    });

    return result;
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

              MessagesBox(
                messages: errors,
                height: 20,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}