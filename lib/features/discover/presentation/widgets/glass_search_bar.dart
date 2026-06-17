import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/attendee_theme.dart';

class GlassSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const GlassSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            decoration: const InputDecoration(
              icon: Icon(
                Icons.search_rounded,
                color: AttendeeTheme.electricBlue,
              ),
              hintText: 'Search events',
              hintStyle: TextStyle(color: Colors.white60, fontSize: 15),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
