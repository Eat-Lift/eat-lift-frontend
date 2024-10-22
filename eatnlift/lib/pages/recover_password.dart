import 'package:flutter/material.dart';
import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/relative_sizedbox.dart';
import 'reset_password.dart';

class RecoverPasswordPage extends StatelessWidget {
  RecoverPasswordPage({super.key});

  final emailController = TextEditingController();

  void recoverPassword() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
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
                width: 330, // Set the desired width
                child: Text(
                  "Si has perdut la teva contrasenya, pots recuperar-la introduint el correu eletrònic associat al teu compte. S'enviarà un amb un codi i instruccions per poder reestablir-la",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.justify,
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                  );
                },
              ),

              const RelativeSizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}