import 'package:flutter/material.dart';

import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/password_textfield.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/wrapped_image.dart';
import '../custom_widgets/relative_sizedbox.dart';
import '../custom_widgets/messages_box.dart';

import 'signin.dart';
import 'user.dart';
import 'recover_password.dart';

import '../services/api_user_service.dart';
import '../services/session_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final SessionStorage sessionStorage = SessionStorage();

  Map<String, dynamic> response = {};

  void logIn(BuildContext context) async {
    bool emptyField = false;

    response = {};

    // Check if any fields are empty
    if (usernameController.text.isEmpty) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Username field must be filled");
      } else {
        response['errors'] = ["Username field must be filled"];
      }
      emptyField = true;
    } 
    if (passwordController.text.isEmpty) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Password field must be filled");
      } else {
        response['errors'] = ["Password field must be filled"];
      }
      emptyField = true;
    }

    if (emptyField) {
      setState(() {});
      return;
    }

    // Perform the registration API call
    final apiService = ApiUserService();
    final result = await apiService.login(
      usernameController.text,
      passwordController.text
    );

    if (result["success"]){
      await sessionStorage.saveSession(result["token"], result["user"]["id"].toString());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserPage()),
      );
    }
    
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
              const Icon(
                Icons.lock,
                size: 100,
              ),

              const RelativeSizedBox(height: 0.5),

              Text(
                "Inicia Sessió",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 24,
                ),
              ),

              response.isNotEmpty ? const RelativeSizedBox(height: 3) : const RelativeSizedBox(height: 5),

              CustomTextfield(
                controller: usernameController,
                hintText: "Nom d'usuari",
                obscureText: false,
              ),

              const RelativeSizedBox(height:0.5),

              PasswordTextfield(
                controller: passwordController,
                hintText: "Contrasenya",
                obscureText: true,
              ),

              const RelativeSizedBox(height: 1),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Has oblidat la teva contrasenya?",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        )
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RecoverPasswordPage()),
                        );
                      }, 
                    ),                  
                  ],
                ),
              ),

              const RelativeSizedBox(height: 1),

              CustomButton(
                text: "Iniciar Sessió",
                onTap: () => logIn(context),
              ),

              if (response.isNotEmpty && !response["success"]) ...[
                const RelativeSizedBox(height: 3),
                MessagesBox(
                  messages: response["errors"],
                  height: 6,
                  color: Colors.red,
                ),
                const RelativeSizedBox(height: 3),
              ]
              else ...[
                const RelativeSizedBox(height: 3),
              ],
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "O continua amb",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              response.isNotEmpty ? const RelativeSizedBox(height: 3) : const RelativeSizedBox(height: 5),
              

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WrappedImage(imageUrl: 'lib/assets/images/google_logo.png'),
                ]
              ),

              response.isNotEmpty ? const RelativeSizedBox(height: 3) : const RelativeSizedBox(height: 3),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Encara no tens un compte?",
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const RelativeSizedBox(width: 2),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Registra't",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SigninPage()),
                      );
                    }, 
                  ),
                ],
              ),

              const RelativeSizedBox(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}
