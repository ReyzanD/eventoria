import 'package:flutter/material.dart';
import '../../../../core/theme/attendee_theme.dart';

class NearYouRowItem extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String date;
  final String time;
  final String location;
  final String category;
  final String price;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;

  const NearYouRowItem({
    super.key,
    required this.title,
    this.imageUrl,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    required this.price,
    this.isBookmarked = false,
    this.onTap,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AttendeeTheme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl ?? 'https://ui-avatars.com/api/?name=Event&background=161C2D&color=fff&size=400',
                height: 100,
                width: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  width: 110,
                  color: AttendeeTheme.cardColor,
                  child: const Center(
                    child: Icon(Icons.image_outlined, color: Colors.white24, size: 28),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onBookmark,
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 18,
                            color: isBookmarked
                                ? AttendeeTheme.neonPink
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 12, color: AttendeeTheme.electricBlue),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            color: AttendeeTheme.electricBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time_rounded, size: 12, color: AttendeeTheme.electricBlue),
                        const SizedBox(width: 3),
                        Text(
                          time,
                          style: const TextStyle(
                            color: AttendeeTheme.electricBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AttendeeTheme.neonPink.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: AttendeeTheme.neonPink,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          price,
                          style: const TextStyle(
                            color: AttendeeTheme.neonOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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
