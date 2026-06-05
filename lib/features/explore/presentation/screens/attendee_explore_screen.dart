import 'package:eventoria/features/auth/presentation/providers/auth_provider.dart';
import 'package:eventoria/features/explore/presentation/screens/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/attendee_events_controller.dart';
import '../../../events/data/models/event_model.dart';

class AttendeeExploreScreen extends ConsumerStatefulWidget {
  const AttendeeExploreScreen({super.key});

  @override
  ConsumerState<AttendeeExploreScreen> createState() =>
      _AttendeeExploreScreenState();
}

class _AttendeeExploreScreenState extends ConsumerState<AttendeeExploreScreen> {
  // We can use this later to filter the UI list locally!
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Conference',
    'Festival',
    'Workshop',
    'Concert',
    'Exhibition',
  ];

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(attendeeEventsProvider);

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Text(
          'Discover Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Sign Out',
            onPressed: () {
              ref
                  .read(authControllerProvider.notifier)
                  .logout(
                    onError: (err) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Logout failed: $err'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    },
                  );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(attendeeEventsProvider.notifier).refresh(),
              child: eventsState.when(
                data: (events) {
                  // Apply local category filtering
                  final filteredEvents = _selectedCategory == 'All'
                      ? events
                      : events
                            .where((e) => e.category == _selectedCategory)
                            .toList();

                  if (filteredEvents.isEmpty) return _buildEmptyState();
                  return _buildEventFeed(filteredEvents);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                ),
                error: (err, stack) =>
                    Center(child: Text('Error loading feed: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCategory = category);
              },
              selectedColor: const Color(0xFF2563EB),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.grey.withValues(alpha: 0.1),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventFeed(List<EventModel> events) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(event: event),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2563EB).withValues(alpha: 0.8),
                    const Color(0xFF4F46E5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.confirmation_number_outlined,
                  color: Colors.white54,
                  size: 60,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.category.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1e293b),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venueName,
                          style: const TextStyle(
                            color: Color(0xff64748b),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Events Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff1e293b),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later or try a different category.',
            style: TextStyle(color: Color(0xff64748b)),
          ),
        ],
      ),
    );
  }
}
