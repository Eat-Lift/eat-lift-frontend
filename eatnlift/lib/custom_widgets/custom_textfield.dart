import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final int maxLines;
  final bool isNumeric;
  final bool allowDecimal;
  final bool centerText;
  final int maxLength;
  final String? unit;
  final IconData? icon;

  const CustomTextfield({
    super.key,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.maxLines = 1,
    this.isNumeric = false,
    this.allowDecimal = false,
    this.centerText = false,
    this.maxLength = 0,
    this.unit,
    this.icon,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(fontWeight: FontWeight.bold),
      controller: widget.controller,
      maxLines: widget.maxLines,
      obscureText: widget.obscureText,
      textAlign: widget.centerText ? TextAlign.center : TextAlign.left,
      keyboardType: widget.isNumeric
          ? (widget.allowDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number)
          : TextInputType.text,
      inputFormatters: [
        if (widget.isNumeric)
          widget.allowDecimal
              ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
              : FilteringTextInputFormatter.digitsOnly,
        if (widget.maxLength > 0) LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 3,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 3,
          ),
        ),
        fillColor: Colors.grey.shade200,
        filled: true,
        hintText: widget.controller.text.isEmpty && widget.unit != null
            ? "${widget.hintText} (${widget.unit})"
            : widget.hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        suffixText: widget.controller.text.isNotEmpty ? widget.unit : '',
        suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
        suffixIcon: widget.icon != null && (widget.hintText == null || widget.hintText!.isEmpty)
            ? Icon(widget.icon, color: Colors.grey[500], size: 20)
            : null,
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }
}