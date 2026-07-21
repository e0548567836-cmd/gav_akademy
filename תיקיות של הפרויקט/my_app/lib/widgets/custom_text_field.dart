import 'package:flutter/material.dart';
import '../constants.dart';

/// A reusable text field widget with optional password visibility support.
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final TextInputType keyboardType;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        filled: true,
        fillColor: kInputFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: kPrimaryColor,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
      ),
    );
  }
}

/// A reusable widget that displays a greeting with an optional user name.
class GreetingHeader extends StatelessWidget {
  final String title;
  final String userName;
  final bool showDot;

  const GreetingHeader({
    super.key,
    required this.title,
    required this.userName,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final name = userName.isNotEmpty ? ', $userName${showDot ? '.' : ''}' : '';
    return Text(
      '$title$name',
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F3C88),
      ),
    );
  }
}
