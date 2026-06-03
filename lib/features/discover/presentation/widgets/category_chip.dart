import 'package:flutter/material.dart';
import '../../../../core/theme/attendee_theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AttendeeTheme.neonPink, AttendeeTheme.neonOrange],
                )
              : null,
          color: isSelected ? null : AttendeeTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AttendeeTheme.neonPink.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
