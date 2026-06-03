import 'package:flutter/material.dart';
import '../../domain/models/event_sales_summary.dart';

class EventListItem extends StatelessWidget {
  final EventSalesSummary summary;
  final VoidCallback onTap;

  EventListItem({super.key, required this.summary, required this.onTap});

  final Map<String, String> _categoryImages = {
    'Festival':
        'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?auto=format&fit=crop&w=150&q=80',
    'Concert':
        'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=150&q=80',
    'Conference':
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=150&q=80',
    'Workshop':
        'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=150&q=80',
    'Exhibition':
        'https://images.unsplash.com/photo-1531058020387-3be344559767?auto=format&fit=crop&w=150&q=80',
  };

  String _getEventImage(String category) {
    return _categoryImages[category] ??
        'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?auto=format&fit=crop&w=150&q=80';
  }

  String _getMonthName(int monthNum) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (monthNum >= 1 && monthNum <= 12) return months[monthNum - 1];
    return '';
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = summary.event;
    final sold = summary.totalSold;
    final capacity = summary.totalCapacity;
    final double progress = capacity == 0
        ? 0.0
        : (sold / capacity).clamp(0.0, 1.0);

    final startMonth = _getMonthName(event.startDate.month);
    final endMonth = _getMonthName(event.endDate.month);
    String dateStr = '';
    if (event.startDate.year == event.endDate.year &&
        event.startDate.month == event.endDate.month &&
        event.startDate.day == event.endDate.day) {
      dateStr = '$startMonth ${event.startDate.day}, ${event.startDate.year}';
    } else if (event.startDate.year == event.endDate.year &&
        event.startDate.month == event.endDate.month) {
      dateStr =
          '$startMonth ${event.startDate.day}–${event.endDate.day}, ${event.startDate.year}';
    } else {
      dateStr =
          '$startMonth ${event.startDate.day} – $endMonth ${event.endDate.day}, ${event.startDate.year}';
    }

    Widget statusBadge;
    if (!event.isPublished) {
      statusBadge = _buildBadge(
        'Draft',
        const Color(0xFFF1F5F9),
        const Color(0xFF64748B),
      );
    } else if (event.endDate.isBefore(DateTime.now())) {
      statusBadge = _buildBadge(
        'Ended',
        const Color(0xFFF1F5F9),
        const Color(0xFF64748B),
      );
    } else if (capacity > 0 && sold >= capacity) {
      statusBadge = _buildBadge(
        'Sold out',
        const Color(0xFFFEE2E2),
        const Color(0xFFEF4444),
      );
    } else if (capacity > 0 && (capacity - sold) <= (capacity * 0.15)) {
      statusBadge = _buildBadge(
        'Low stock',
        const Color(0xFFFEF3C7),
        const Color(0xFFD97706),
      );
    } else {
      statusBadge = _buildBadge(
        'Live',
        const Color(0xFFD1FAE5),
        const Color(0xFF10B981),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _getEventImage(event.category),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: const Color(0xFF3B4FEB).withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.festival_rounded,
                      color: Color(0xFF3B4FEB),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        statusBadge,
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: Color(0xFF717F8C),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$sold / $capacity sold',
                          style: const TextStyle(
                            color: Color(0xFF717F8C),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFF45E65),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF717F8C),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
