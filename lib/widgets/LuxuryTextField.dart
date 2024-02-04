import 'package:flutter/material.dart';

import '../themedata/theme.dart';

class LuxuryTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final bool obscureText;
  final int? minLines;
  final int? maxLines;
  final String? Function(String?)? validator; // This is used by TextFormField

  LuxuryTextField({
    required this.hintText,
    required this.controller,
    this.onChanged,
    this.obscureText = false,
    this.minLines,
    this.maxLines = 1,
    this.validator, // Make sure to pass this to TextFormField
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField( // Changed from TextField to TextFormField
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: LuxuryTheme.silver),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: LuxuryTheme.gold),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: LuxuryTheme.gold, width: 2),
        ),
      ),
      style: TextStyle(color: LuxuryTheme.dark),
      onChanged: onChanged,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: obscureText ? 1 : maxLines,
      validator: validator, // Now this will work as TextFormField supports validator
    );
  }
}
