import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/attendee_theme.dart';
import '../../../discover/presentation/controller/bookmarks_provider.dart';
import '../../../discover/presentation/controller/discover_controller.dart';
import '../../../events/data/models/event_model.dart';
import '../../../explore/presentation/screens/event_details_screen.dart';

class SavedEventsScreen extends ConsumerWidget {
  const SavedEventsScreen({super.key});

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hour:$minutes $amPm';
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _computeStartingPrice(EventModel event) {
    if (event.ticketTiers == null || event.ticketTiers!.isEmpty) {
      return 'Free';
    }
    final minPrice =
        event.ticketTiers!.map((t) => t.price).reduce((a, b) => a < b ? a : b);
    return 'From ${_formatCurrency(minPrice)}+';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedIds = ref.watch(bookmarkedIdsProvider);
    final eventsAsync = ref.watch(discoverEventsProvider);

    return Scaffold(
      backgroundColor: AttendeeTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AttendeeTheme.bgColor,
        elevation: 0,
        title: const Text(
          'Saved Events',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: eventsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AttendeeTheme.electricBlue),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.white)),
        ),
        data: (allEvents) {
          final saved = allEvents.where((e) => bookmarkedIds.contains(e.id)).toList();

          if (saved.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No saved events yet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bookmark events from the Discover tab to see them here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: saved.length,
            itemBuilder: (context, index) {
              final ev = saved[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(event: ev),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AttendeeTheme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          ev.coverImageUrl ??
                              'https://ui-avatars.com/api/?name=Event&background=161C2D&color=fff&size=400',
                          height: 80,
                          width: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 80,
                            width: 90,
                            color: AttendeeTheme.cardColor,
                            child: const Center(
                              child: Icon(Icons.image_outlined, color: Colors.white24, size: 24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ev.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
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
                                  _formatDate(ev.startDate),
                                  style: const TextStyle(
                                    color: AttendeeTheme.electricBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.access_time_rounded, size: 11, color: AttendeeTheme.electricBlue),
                                const SizedBox(width: 3),
                                Text(
                                  _formatTime(ev.startDate),
                                  style: const TextStyle(
                                    color: AttendeeTheme.electricBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded, size: 12, color: Colors.grey.shade500),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    ev.venueName,
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AttendeeTheme.neonPink.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    ev.category,
                                    style: const TextStyle(
                                      color: AttendeeTheme.neonPink,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _computeStartingPrice(ev),
                                  style: const TextStyle(
                                    color: AttendeeTheme.neonOrange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
