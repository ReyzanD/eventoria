import 'package:flutter/material.dart';
import '../../../../core/theme/attendee_theme.dart';

class WeekendEventCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String date;
  final String time;
  final String location;
  final String price;
  final VoidCallback? onTap;

  const WeekendEventCard({
    super.key,
    required this.title,
    this.imageUrl,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AttendeeTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl ?? 'https://ui-avatars.com/api/?name=Event&background=161C2D&color=fff&size=400',
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 130,
                  color: AttendeeTheme.cardColor,
                  child: const Center(
                    child: Icon(Icons.image_outlined, color: Colors.white24, size: 32),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 11, color: AttendeeTheme.electricBlue),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            color: AttendeeTheme.electricBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.access_time_rounded, size: 11, color: AttendeeTheme.electricBlue),
                        const SizedBox(width: 3),
                        Text(
                          time,
                          style: const TextStyle(
                            color: AttendeeTheme.electricBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      price,
                      style: const TextStyle(
                        color: AttendeeTheme.neonOrange,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
