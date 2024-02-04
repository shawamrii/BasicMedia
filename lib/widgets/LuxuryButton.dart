import 'package:flutter/material.dart';
import '../themedata/theme.dart';

class LuxuryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color; // Add this line

  LuxuryButton({required this.label, required this.onPressed, this.color}); // Update this line

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: color ?? LuxuryTheme.gold, // Use color if provided, else default to a theme color
        onPrimary: LuxuryTheme.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
