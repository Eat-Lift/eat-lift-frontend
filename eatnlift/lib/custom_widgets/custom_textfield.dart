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
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final double height;

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
    this.onChanged,
    this.height = 10,
    this.onSubmitted,
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
        hintText: widget.hintText != null
            ? (widget.controller.text.isEmpty && widget.unit != null
                ? "${widget.hintText} (${widget.unit})"
                : widget.hintText)
            : null,
        hintStyle: TextStyle(color: Colors.grey[500]),
        suffixText: widget.controller.text.isNotEmpty ? widget.unit : '',
        suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
        suffixIcon: widget.icon != null
            ? Icon(widget.icon, color: Colors.grey[500], size: 20)
            : null,
        contentPadding: EdgeInsets.symmetric(vertical: widget.height, horizontal: 10),
      ),
      onChanged: (value) {
        setState(() {});
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
      onSubmitted: (value) {
        if (widget.onSubmitted != null){
          widget.onSubmitted!(value);
        }
      },
    );
  }
}