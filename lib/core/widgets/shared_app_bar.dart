import 'package:flutter/material.dart';

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color backgroundColor;
  final Color titleColor;
  final double elevation;
  final bool automaticallyImplyLeading;
  final double titleFontSize;
  final double titleLetterSpacing;
  final FontWeight titleFontWeight;

  const SharedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.backgroundColor = const Color(0xFFF8FAFC),
    this.titleColor = const Color(0xFF1E293B),
    this.elevation = 0,
    this.automaticallyImplyLeading = true,
    this.titleFontSize = 20,
    this.titleLetterSpacing = 0.0,
    this.titleFontWeight = FontWeight.w900,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: titleFontWeight,
          fontSize: titleFontSize,
          color: titleColor,
          letterSpacing: titleLetterSpacing,
        ),
      ),
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: elevation,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
