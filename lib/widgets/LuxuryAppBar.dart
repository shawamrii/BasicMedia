import 'package:flutter/material.dart';
import '../themedata/theme.dart';

class LuxuryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  LuxuryAppBar({required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: LuxuryTheme.luxuryTextTheme.headline1),
      backgroundColor: LuxuryTheme.dark,
      actions: actions,
      // Add more customizations as needed
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
