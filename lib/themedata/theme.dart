// luxury_ui_widgets.dart
import 'package:flutter/material.dart';

// ───────────────────────────────────────────── Luxury Theme
class LuxuryTheme {
  static const Color gold   = Color(0xFFD4AF37);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color dark   = Color(0xFF212121);

  static final TextTheme text = TextTheme(
    headline1: const TextStyle(
      fontFamily: 'ElegantFont', // eigene Schrift einbinden
      fontSize: 32,
      color: gold,
      fontWeight: FontWeight.w600,
    ),
    bodyText2: TextStyle(color: silver, fontSize: 16),
  );

  static final ButtonStyle button = ElevatedButton.styleFrom(
    foregroundColor: dark,
    backgroundColor: gold,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  );

  static final AppBarTheme appBar = AppBarTheme(
    backgroundColor: dark,
    elevation: 0,
    titleTextStyle: text.headline1,
    iconTheme: const IconThemeData(color: gold),
  );
}

// ───────────────────────────────────────────── Luxury Widgets
class LuxuryAppBar extends AppBar {
  LuxuryAppBar({super.key, required String title})
      : super(
          title: Text(title),
          centerTitle: true,
          backgroundColor: LuxuryTheme.dark,
          elevation: 0,
        );
}

class LuxuryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const LuxuryButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: LuxuryTheme.button,
        onPressed: onPressed,
        child: Text(label),
      );
}

class LuxuryTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  const LuxuryTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: LuxuryTheme.silver.withOpacity(.7)),
            filled: true,
            fillColor: LuxuryTheme.dark.withOpacity(.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: LuxuryTheme.gold),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: LuxuryTheme.gold, width: 2),
            ),
          ),
        ),
      );
}
