import 'package:flutter/material.dart';
import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/password_textfield.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/wrapped_image.dart';
import '../custom_widgets/relative_sizedbox.dart';
import 'recover_password.dart';
import 'signin.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void logIn() {}

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
                "Inicia Sessió",
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
                onTap: logIn,
              ),

              const RelativeSizedBox(height: 5),

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

              const RelativeSizedBox(height: 5),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WrappedImage(imageUrl: 'lib/assets/images/google_logo.png'),
                ]
              ),

              const RelativeSizedBox(height: 5),

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
