import 'package:flutter/material.dart';

class PasswordTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const PasswordTextfield(
    {super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  PasswordTextfieldState createState() => PasswordTextfieldState();
}

class PasswordTextfieldState extends State<PasswordTextfield> {
  bool _isObscure = true; // Initially, obscure text is true

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText; // Initialize based on the passed obscureText value
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: widget.controller,
        obscureText: _isObscure,
        decoration: InputDecoration(
          suffixIcon: IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
              width: 3,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 3,
            ),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[500])
        ),
      ),
    );
  }
}
