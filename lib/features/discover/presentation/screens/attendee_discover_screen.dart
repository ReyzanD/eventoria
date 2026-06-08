import 'package:eventoria/features/auth/presentation/providers/auth_provider.dart';
import 'package:eventoria/features/explore/presentation/screens/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/attendee_theme.dart';
import '../../../events/data/models/event_model.dart';
import '../controller/discover_controller.dart';
import '../widgets/glass_search_bar.dart';
import '../widgets/category_chip.dart';
import '../widgets/weekend_event_card.dart';
import '../widgets/near_you_row_item.dart';

class AttendeeDiscoverScreen extends ConsumerStatefulWidget {
  const AttendeeDiscoverScreen({super.key});

  @override
  ConsumerState<AttendeeDiscoverScreen> createState() =>
      _AttendeeDiscoverScreenState();
}

class _AttendeeDiscoverScreenState
    extends ConsumerState<AttendeeDiscoverScreen> {
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'All',
    '🎵 Music',
    '💻 Tech',
    '🌮 Food',
    '🎨 Art',
    '🏀 Sports',
  ];

  String _formatDate(DateTime date) {
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minutes = date.minute.toString().padLeft(2, '0');

    return '$dayName, $monthName ${date.day} • $hour:$minutes $amPm';
  }

  String _getEventImage(EventModel event) {
    final category = event.category.toLowerCase();
    if (category.contains('music') ||
        category.contains('concert') ||
        category.contains('festival')) {
      return 'https://ui-avatars.com/api/?name=Attendee&background=3B4FEB&color=fff';
    }
    if (category.contains('tech') ||
        category.contains('conference') ||
        category.contains('workshop')) {
      return 'https://ui-avatars.com/api/?name=Attendee&background=3B4FEB&color=fff';
    }
    return 'https://ui-avatars.com/api/?name=Attendee&background=3B4FEB&color=fff';
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsyncValue = ref.watch(discoverEventsProvider);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AttendeeTheme.bgColor,
      ),
      child: Scaffold(
        backgroundColor: AttendeeTheme.bgColor,
        // NO MORE BOTTOM NAVIGATION BAR HERE!
        body: eventsAsyncValue.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AttendeeTheme.electricBlue),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Error: $err',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (allEvents) {
            List<EventModel> displayEvents = allEvents;
            if (_selectedCategoryIndex != 0) {
              final selectedCat = _categories[_selectedCategoryIndex].substring(
                3,
              );
              displayEvents = allEvents
                  .where((e) => e.category == selectedCat)
                  .toList();
            }

            if (displayEvents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: 64,
                      color: AttendeeTheme.neonPink.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No events found",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Check back later for new concert and festival updates!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final heroEvent = displayEvents.first;
            final weekendEvents = displayEvents.length > 1
                ? displayEvents.sublist(1).take(3).toList()
                : <EventModel>[];
            final nearYouEvents = displayEvents.length > 4
                ? displayEvents.sublist(4).toList()
                : <EventModel>[];

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 390,
                  pinned: true,
                  backgroundColor: AttendeeTheme.bgColor,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://ui-avatars.com/api/?name=Attendee&background=3B4FEB&color=fff',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF1F5F9),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: Color(0xFF94A3B8),
                                size: 32,
                              ),
                            );
                          },
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black,
                                Colors.transparent,
                                AttendeeTheme.bgColor,
                              ],
                              stops: [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 30,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                heroEvent.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(heroEvent.startDate),
                                style: const TextStyle(
                                  color: AttendeeTheme.electricBlue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const GlassSearchBar(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    'Hi, ${ref.watch(authControllerProvider).value?.fullName.split(' ')[0] ?? 'Guest'} 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifications coming soon!'),
                              backgroundColor: AttendeeTheme.electricBlue,
                            ),
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFE2E8F0),
                        foregroundImage: NetworkImage(
                          'https://ui-avatars.com/api/?name=Attendee&background=3B4FEB&color=fff',
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: Color(0xFF717F8C),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 46,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) => CategoryChip(
                              label: _categories[index],
                              isSelected: _selectedCategoryIndex == index,
                              onTap: () => setState(
                                () => _selectedCategoryIndex = index,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (weekendEvents.isNotEmpty) ...[
                          _buildSectionHeader('Upcoming'),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 245,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: weekendEvents.length,
                              itemBuilder: (context, index) {
                                final ev = weekendEvents[index];
                                return WeekendEventCard(
                                  title: ev.title,
                                  imageUtl: _getEventImage(ev),
                                  date: _formatDate(ev.startDate),
                                  location: ev.venueName,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EventDetailsScreen(event: ev),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                        if (nearYouEvents.isNotEmpty) ...[
                          _buildSectionHeader('More Events'),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: nearYouEvents.length,
                            itemBuilder: (context, index) {
                              final ev = nearYouEvents[index];
                              return NearYouRowItem(
                                title: ev.title,
                                imageUrl: _getEventImage(ev),
                                date: _formatDate(ev.startDate),
                                location: ev.venueName,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EventDetailsScreen(event: ev),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const Text(
          'See all',
          style: TextStyle(
            color: AttendeeTheme.electricBlue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
