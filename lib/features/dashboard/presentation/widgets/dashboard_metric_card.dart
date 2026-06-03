import 'package:flutter/material.dart';

class DashboardMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final bool hasTrend;

  const DashboardMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.hasTrend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF717F8C),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasTrend)
                const Icon(
                  Icons.north_east_rounded,
                  color: Color(0xFF10B981),
                  size: 14,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
