import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/organizer_attendee_entity.dart';
import '../../../tickets/data/repositories/ticket_repository_provider.dart';

void showAttendeeDetailsSheet(
  BuildContext context,{
  required OrganizerAttendeeEntity attendee,
  required String eventId,
  required String eventTitle,
  }
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => AttendeeDetailsSheet(
      attendee: attendee,
      eventTitle: eventTitle,
      eventId: eventId,
    ),
  );
}

class AttendeeDetailsSheet extends ConsumerWidget {
  final OrganizerAttendeeEntity attendee;
  final String eventTitle;
  final String eventId;

  const AttendeeDetailsSheet({
    super.key,
    required this.attendee,
    required this.eventTitle,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: SafeArea(
        top: false,
        child: Wrap(
          runSpacing: 14,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE0E7FF),
                  child: Text(
                    attendee.name.substring(0, 1),
                    style: const TextStyle(
                      color: Color(0xFF3B4FEB),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attendee.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        attendee.email,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            DetailRow(label: 'Event', value: eventTitle),
            DetailRow(label: 'Ticket type', value: attendee.ticketType),
            DetailRow(label: 'Order code', value: attendee.orderCode),
            DetailRow(
              label: 'Status',
              value: attendee.checkedIn ? 'Checked in' : 'Pending',
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF334155),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: attendee.checkedIn
                        ? null
                        : () async {
                            Navigator.pop(context);
                            try {
                              final repository = ref.read(
                                getTicketRepositoryProvider,
                              );
                              await repository.checkInTicket(attendee.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${attendee.name} checked in!',
                                    ),
                                    backgroundColor:
                                        const Color(0xFF16A34A),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error: ${e.toString().replaceAll('Exception: ', '')}',
                                    ),
                                    backgroundColor:
                                        const Color(0xFFEF4444),
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B4FEB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      elevation: 0,
                    ),
                    child: Text(
                      attendee.checkedIn ? 'Already checked in' : 'Check in',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
