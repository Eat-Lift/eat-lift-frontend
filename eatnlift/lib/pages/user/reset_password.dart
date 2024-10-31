import 'package:flutter/material.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/password_textfield.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/relative_sizedbox.dart';

class ResetPasswordPage extends StatelessWidget {
  ResetPasswordPage({super.key});

  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final repeatNewPasswordController = TextEditingController();

  void resetPassword() {}

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

              const RelativeSizedBox(height: 5),

              SizedBox(
                width: 330, // Set the desired width
                child: Text(
                  "Introdueix el codi que has rebut en el correu electrònic per poder reestablir la contrasenya del teu compte",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),

              const RelativeSizedBox(height: 5),

              CustomTextfield(
                controller: codeController,
                hintText: "Correu electrònic",
                obscureText: false,
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
                onTap: resetPassword,
              ),

              const RelativeSizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}