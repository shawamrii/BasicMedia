import 'package:flutter/material.dart';

class LuxuryTheme {
  // Define luxury color palette
  static const Color gold = Color(0xFFD4AF37);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color dark = Color(0xFF212121);

  // Define luxury text theme
  static final TextTheme luxuryTextTheme = TextTheme(
    headline1: TextStyle(
      fontFamily: 'ElegantFont', // Replace with your custom font
      fontSize: 36,
      color: gold,
    ),
    // Add other text styles here
  );

  // Define luxury button style
  static final ButtonStyle luxuryButtonStyle = ElevatedButton.styleFrom(
    primary: gold,
    onPrimary: dark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  );

  // Define luxury AppBar style
  static final AppBarTheme luxuryAppBarTheme = AppBarTheme(
    color: dark,
    elevation: 0,
    titleTextStyle: luxuryTextTheme.headline1,
  );

// Add other style elements as needed
}
