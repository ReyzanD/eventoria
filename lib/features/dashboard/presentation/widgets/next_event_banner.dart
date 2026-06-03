import 'package:flutter/material.dart';
import '../../../events/data/models/event_model.dart';

class NextEventBanner extends StatelessWidget {
  final EventModel event;

  const NextEventBanner({super.key, required this.event});

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

  @override
  Widget build(BuildContext context) {
    final days = event.startDate.difference(DateTime.now()).inDays;
    final String countdownText = days == 0
        ? 'Your next event is today'
        : days == 1
        ? 'Your next event is tomorrow'
        : 'Your next event is in $days days';

    final startMonth = _getMonthName(event.startDate.month);
    final String timeStr =
        '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}';
    final dateDetail =
        '${event.title} starts on $startMonth ${event.startDate.day}, ${event.startDate.year} at $timeStr';

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B4FEB).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B4FEB).withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF3B4FEB),
                  size: 20,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF45E65),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  countdownText,
                  style: const TextStyle(
                    color: Color(0xFF3B4FEB),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateDetail,
                  style: const TextStyle(
                    color: Color(0xFF717F8C),
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF3B4FEB),
            size: 24,
          ),
        ],
      ),
    );
  }
}
