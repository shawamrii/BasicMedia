import 'package:flutter/material.dart';

import '../themedata/theme.dart';

class LuxuryContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  LuxuryContainer({
    required this.child,
    this.padding = const EdgeInsets.all(10),
    this.margin = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: LuxuryTheme.dark,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: LuxuryTheme.gold.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
