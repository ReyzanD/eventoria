import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/organizer_all_attendees_provider.dart';

class OrganizerAllAttendeesScreen extends ConsumerStatefulWidget {
  const OrganizerAllAttendeesScreen({super.key});

  @override
  ConsumerState<OrganizerAllAttendeesScreen> createState() =>
      _OrganizerAllAttendeesScreenState();
}

class _OrganizerAllAttendeesScreenState
    extends ConsumerState<OrganizerAllAttendeesScreen> {
  String selectedEventTitle = 'All events';
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(organizerAllAttendeesControllerProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(organizerAllAttendeesControllerProvider.notifier)
              .refresh();
        },
        child: itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error loading attendees:\n$error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          data: (items) {
            final eventTitles = <String>{
              'All events',
              ...items.map((item) => item.eventTitle),
            }.toList();

            if (!eventTitles.contains(selectedEventTitle)) {
              selectedEventTitle = 'All events';
            }

            final query = searchController.text.trim().toLowerCase();

            final filteredItems = items.where((item) {
              final matchesEvent =
                  selectedEventTitle == 'All events' ||
                  item.eventTitle == selectedEventTitle;

              final matchesSearch =
                  query.isEmpty ||
                  item.attendee.name.toLowerCase().contains(query) ||
                  item.attendee.email.toLowerCase().contains(query) ||
                  item.attendee.ticketType.toLowerCase().contains(query) ||
                  item.attendee.orderCode.toLowerCase().contains(query) ||
                  item.eventTitle.toLowerCase().contains(query);

              return matchesEvent && matchesSearch;
            }).toList();

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  value: selectedEventTitle,
                  decoration: const InputDecoration(
                    labelText: 'Filter by event',
                    border: OutlineInputBorder(),
                  ),
                  items: eventTitles
                      .map(
                        (title) => DropdownMenuItem<String>(
                          value: title,
                          child: Text(title),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedEventTitle = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search attendees',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                if (filteredItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Center(
                      child: Text(
                        items.isEmpty
                            ? 'No attendees found across all events.'
                            : 'No attendees match your filters.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...filteredItems.map((item) {
                    final attendee = item.attendee;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFE2E8F0),
                            child: Text(
                              attendee.name.isNotEmpty
                                  ? attendee.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  attendee.email,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.eventTitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF3B4FEB),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: attendee.checkedIn
                                            ? const Color(0xFFD1FAE5)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        attendee.checkedIn
                                            ? 'Checked In'
                                            : 'Pending',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ),
                                    if (attendee.isVip)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE3F2),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: const Text(
                                          'VIP',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF9333EA),
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        attendee.ticketType,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Order: ${attendee.orderCode}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}
