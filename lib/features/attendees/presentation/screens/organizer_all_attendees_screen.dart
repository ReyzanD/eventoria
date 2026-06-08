import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/organizer_all_attendees_provider.dart';
import '../widgets/attendee_card.dart';
import '../widgets/attendee_details_sheet.dart';
import '../../../../core/widgets/shared_app_bar.dart';

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

  // --- PURE DART EXPORT FUNCTION ---
  Future<void> _exportToCsv(List<dynamic> items) async {
    try {
      List<List<dynamic>> rows = [];
      // 1. Spreadsheet Headers
      rows.add([
        'Order Number',
        'Event Name',
        'Attendee Name',
        'Email',
        'Ticket Tier',
        'Status',
      ]);

      // 2. Data Rows (Mapping your custom items)
      for (var item in items) {
        rows.add([
          item.attendee.orderCode,
          item.eventTitle,
          item.attendee.name,
          item.attendee.email,
          item.attendee.ticketType,
          item.attendee.checkedIn ? 'Checked In' : 'Not Scanned',
        ]);
      }

      // 3. Convert to CSV string manually (No package needed!)
      String csvData = rows
          .map((row) {
            return row
                .map((cell) {
                  String str = cell.toString();
                  // Escape strings that contain commas or quotes
                  if (str.contains(',') ||
                      str.contains('"') ||
                      str.contains('\n')) {
                    return '"${str.replaceAll('"', '""')}"';
                  }
                  return str;
                })
                .join(',');
          })
          .join('\n');

      // 4. Save file temporarily
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/guestlist_export.csv';
      final file = File(path);
      await file.writeAsString(csvData);

      // 5. Trigger Share Sheet
      if (mounted) {
        final box = context.findRenderObject() as RenderBox?;
        await Share.shareXFiles(
          [XFile(path)],
          text: 'Here is the exported guest list.',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(organizerAllAttendeesControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: SharedAppBar(
        title: 'All Attendees',
        titleFontSize: 24,
        titleLetterSpacing: -0.5,
        actions: [
          // --- THE DOWNLOAD BUTTON ---
          if (itemsAsync.hasValue && itemsAsync.value != null)
            IconButton(
              icon: const Icon(
                Icons.download_rounded,
                color: Color(0xFF3B4FEB),
              ),
              tooltip: 'Export CSV',
              onPressed: () {
                final items = itemsAsync.value!;
                final query = searchController.text.trim().toLowerCase();

                // Export only what matches the current filter
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

                _exportToCsv(filteredItems);
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF3B4FEB),
        onRefresh: () async {
          await ref
              .read(organizerAllAttendeesControllerProvider.notifier)
              .refresh();
        },
        child: itemsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF3B4FEB)),
          ),
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

            final totalNetwork = items.length;
            final totalCheckIns = items
                .where((i) => i.attendee.checkedIn)
                .length;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        label: 'Total Network',
                        value: '$totalNetwork',
                        icon: Icons.people_alt_rounded,
                        color: const Color(0xFF3B4FEB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        label: 'Total Check-ins',
                        value: '$totalCheckIns',
                        icon: Icons.how_to_reg_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  value: selectedEventTitle,
                  decoration: InputDecoration(
                    labelText: 'Filter by event',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: eventTitles
                      .map(
                        (title) => DropdownMenuItem<String>(
                          value: title,
                          child: Text(title, overflow: TextOverflow.ellipsis),
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
                  decoration: InputDecoration(
                    hintText: 'Search attendees',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  )
                else
                  ...filteredItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AttendeeCard(
                        attendee: item.attendee,
                        onTap: () {
                          showAttendeeDetailsSheet(
                            context,
                            attendee: item.attendee,
                            eventId: item.eventId,
                            eventTitle: item.eventTitle,
                          );
                        },
                        onCheckIn: item.attendee.checkedIn
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Check in for ${item.attendee.name} coming next!',
                                    ),
                                  ),
                                );
                              },
                      ),
                    );
                  }),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
