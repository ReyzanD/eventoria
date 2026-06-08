import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendees_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/attendee_card.dart';
import '../widgets/attendee_details_sheet.dart';

class OrganizerAttendeesScreen extends ConsumerStatefulWidget {
  final String eventId;
  final String eventTitle;

  const OrganizerAttendeesScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  ConsumerState<OrganizerAttendeesScreen> createState() =>
      _OrganizerAttendeesScreenState();
}

class _OrganizerAttendeesScreenState
    extends ConsumerState<OrganizerAttendeesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = const ['All', 'Checked in', 'Pending', 'VIP'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendeesState = ref.watch(
      attendeesControllerProvider(widget.eventId),
    );

    final attendees = attendeesState.filteredAttendees;
    final allAttendees = attendeesState.allAttendees;

    final totalCount = allAttendees.length;
    final checkedInCount = allAttendees.where((e) => e.checkedIn).length;
    final pendingCount = allAttendees.where((e) => !e.checkedIn).length;
    final vipCount = allAttendees.where((e) => e.isVip).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1E293B)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendee Guestlist',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.eventTitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF717F8C),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: attendeesState.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B4FEB)),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: 'Total attendees',
                          value: '$totalCount',
                          icon: Icons.people_alt_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricCard(
                          label: 'Checked in',
                          value: '$checkedInCount',
                          icon: Icons.verified_outlined,
                          accent: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: 'Pending',
                          value: '$pendingCount',
                          icon: Icons.schedule_outlined,
                          accent: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricCard(
                          label: 'VIP',
                          value: '$vipCount',
                          icon: Icons.workspace_premium_outlined,
                          accent: const Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => ref
                          .read(
                            attendeesControllerProvider(
                              widget.eventId,
                            ).notifier,
                          )
                          .setSearchQuery(val),
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.search_rounded,
                          color: Color(0xFF717F8C),
                        ),
                        hintText: 'Search attendees, event, ticket, order...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final isSelected =
                            attendeesState.selectedFilterIndex == index;

                        return GestureDetector(
                          onTap: () => ref
                              .read(
                                attendeesControllerProvider(
                                  widget.eventId,
                                ).notifier,
                              )
                              .setFilterIndex(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF3B4FEB)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF3B4FEB)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _filters[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF334155),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemCount: _filters.length,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (attendees.isEmpty)
                    _buildEmptyState()
                  else
                    ...attendees.map(
                      (attendee) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AttendeeCard(
                          attendee: attendee,
                          onTap: () => showAttendeeDetailsSheet(
                            context,
                            attendee: attendee,
                            eventId: widget.eventId,
                            eventTitle: widget.eventTitle,
                          ),
                          onCheckIn: attendee.checkedIn
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Check-in flow for ${attendee.name} comes next.',
                                      ),
                                    ),
                                  );
                                },
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 48,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 12),
          Text(
            'No attendees found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try changing your search or selected filter.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
