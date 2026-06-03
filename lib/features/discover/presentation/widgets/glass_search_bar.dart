import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/attendee_theme.dart';

class GlassSearchBar extends StatelessWidget {
  const GlassSearchBar({super.key});

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
          child: const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: Icon(
                Icons.search_rounded,
                color: AttendeeTheme.electricBlue,
              ),
              hintText: 'Search events, artists, or venues...',
              hintStyle: TextStyle(color: Colors.white60, fontSize: 15),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
