import 'package:eventoria/features/events/data/models/event_model.dart';
import 'package:eventoria/features/tickets/presentation/controller/ticket_booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/mini_event_map.dart';

class EventDetailsScreen extends ConsumerWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(ticketBookingProvider);
    final isBooking = bookingState is AsyncLoading;
    final tiersAsync = ref.watch(eventTiersProvider(event.id));
    final monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final dateStr =
        '${monthNames[event.startDate.month - 1]} ${event.startDate.day}, ${event.startDate.year}';
    final timeStr =
        '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Text(
          'Event Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double horizontalPadding = constraints.maxWidth > 700
                ? (constraints.maxWidth - 650) / 2
                : 16.0;
            return ListView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              children: [
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.festival_rounded,
                      color: Colors.white24,
                      size: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2563EB,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event.category.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1e293b),
                          ),
                        ),
                        const Divider(height: 32),

                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xfff1f5f9),
                            child: Icon(
                              Icons.calendar_month,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          title: Text(
                            dateStr,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Start At $timeStr Local Time'),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xfff1f5f9),
                            child: Icon(
                              Icons.place_rounded,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          title: Text(
                            event.venueName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Verified Venue Location'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About Event',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          event.description ??
                              'No extra description provided by the host organizer.',
                          style: const TextStyle(
                            color: Color(0xff475569),
                            height: 1.5,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Venue Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        MiniEventMap(
                          latitude: event.latitude,
                          longitude: event.longitude,
                          venueName: event.venueName,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 5. TICKET TIERS SELECTION & BOOKING
                const Text(
                  'Available Tickets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1e293b),
                  ),
                ),
                const SizedBox(height: 16),

                tiersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error loading tickets: $err'),
                  data: (tiers) {
                    if (tiers.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No tickets available for this event yet.',
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: tiers.map((tier) {
                        final isSoldOut =
                            tier.ticketsSold >= tier.totalCapacity;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSoldOut
                                  ? Colors.red.withValues(alpha: 0.3)
                                  : const Color(
                                      0xFF2563EB,
                                    ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              tier.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${tier.totalCapacity - tier.ticketsSold} tickets remaining',
                            ),
                            trailing: ElevatedButton(
                              onPressed: isSoldOut || isBooking
                                  ? null
                                  : () async {
                                      final success = await ref
                                          .read(ticketBookingProvider.notifier)
                                          .bookTicket(event.id, tier.id);

                                      if (!context.mounted) return;

                                      if (success) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Ticket Booked Successfully! 🎉',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Failed to book ticket.',
                                            ),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSoldOut
                                    ? Colors.grey
                                    : const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                              ),
                              child: isBooking
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      tier.price == 0
                                          ? 'FREE'
                                          : '\$${tier.price.toStringAsFixed(2)}',
                                    ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}
