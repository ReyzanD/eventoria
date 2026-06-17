import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../notifications/presentation/controller/notifications_provider.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../events/data/models/event_model.dart';
import '../../../explore/presentation/screens/event_details_screen.dart';
import '../../../discover/presentation/screens/attendee_search_screen.dart';
import '../../../../core/theme/attendee_theme.dart';
import '../controller/discover_controller.dart';
import '../controller/bookmarks_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/glass_search_bar.dart';
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

  static const _categoryEmojis = {
    'Conference': '💼',
    'Festival': '🎉',
    'Workshop': '🔧',
    'Concert': '🎵',
    'Exhibition': '🎨',
  };

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

  bool _isThisWeekend(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);
    final diff = eventDate.difference(today).inDays;

    if (diff < 0 || diff > 10) return false;

    return eventDate.weekday == DateTime.friday ||
        eventDate.weekday == DateTime.saturday ||
        eventDate.weekday == DateTime.sunday;
  }

  List<String> _buildCategories(List<EventModel> events) {
    final unique = events.map((e) => e.category).toSet().toList()..sort();
    return ['All', ...unique];
  }

  String _categoryLabel(String category, int index) {
    if (index == 0) return 'All';
    final emoji = _categoryEmojis[category];
    return emoji != null ? '$emoji $category' : category;
  }

  List<EventModel> _filterByCategory(List<EventModel> events, String category) {
    if (category == 'All') return events;
    return events
        .where((e) => e.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsyncValue = ref.watch(discoverEventsProvider);
    final profileAsyncValue = ref.watch(authControllerProvider);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AttendeeTheme.bgColor,
      ),
      child: Scaffold(
        backgroundColor: AttendeeTheme.bgColor,
        body: eventsAsyncValue.when(
          loading: () => const Center(
            child:
                CircularProgressIndicator(color: AttendeeTheme.electricBlue),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Error: $err',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (allEvents) {
            final categories = _buildCategories(allEvents);
            final selectedCategory =
                _selectedCategoryIndex == 0
                    ? 'All'
                    : categories[_selectedCategoryIndex];

            final catFilteredEvents =
                _filterByCategory(allEvents, selectedCategory);

            if (allEvents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy_rounded,
                        size: 64,
                        color: AttendeeTheme.neonPink.withValues(alpha: 0.5)),
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

            final featuredEvent = catFilteredEvents.first;
            final weekendEvents = catFilteredEvents
                .where((e) => _isThisWeekend(e.startDate))
                .toList();
            final nearYouEvents = catFilteredEvents
                .where((e) => e.id != featuredEvent.id)
                .toList();

            final bookmarkedIds = ref.watch(bookmarkedIdsProvider);
            final unreadCount = ref.watch(unreadNotificationCountProvider).asData?.value ?? 0;
            final profile = profileAsyncValue.asData?.value;
            final isDesktop = context.isDesktop;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1200 : double.infinity,
                ),
                child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Hi, ${profile?.fullName.split(' ').firstOrNull ?? 'Guest'} 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Stack(
                              children: [
                                const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white,
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AttendeeTheme.neonPink,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AttendeeTheme.cardColor,
                            backgroundImage: profile?.avatarUrl != null
                                ? NetworkImage(profile!.avatarUrl!)
                                : null,
                            child: profile?.avatarUrl == null
                                ? Text(
                                    (profile?.fullName.isNotEmpty == true
                                            ? profile!.fullName[0]
                                            : '?')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: const GlassSearchBar(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _buildHeroCard(featuredEvent),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 46,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) => CategoryChip(
                              label:
                                  _categoryLabel(categories[index], index),
                              isSelected:
                                  _selectedCategoryIndex == index,
                              onTap: () => setState(
                                  () => _selectedCategoryIndex = index),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (weekendEvents.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'This weekend',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AttendeeSearchScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'See all >',
                                  style: TextStyle(
                                    color:
                                        AttendeeTheme.neonPink.withValues(alpha: 0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 270,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: weekendEvents.length,
                              itemBuilder: (context, index) {
                                final ev = weekendEvents[index];
                                return WeekendEventCard(
                                  title: ev.title,
                                  imageUrl: ev.coverImageUrl,
                                  date: _formatDate(ev.startDate),
                                  time: _formatTime(ev.startDate),
                                  location: ev.venueName,
                                  price: _computeStartingPrice(ev),
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
                        ],
                      ),
                    ),
                  ),
                if (nearYouEvents.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Near you',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AttendeeSearchScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'See all >',
                              style: TextStyle(
                                color: AttendeeTheme.neonPink.withValues(alpha: 0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ev = nearYouEvents[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          index == 0 ? 14 : 0,
                          20,
                          index == nearYouEvents.length - 1 ? 24 : 0,
                        ),
                        child: NearYouRowItem(
                          title: ev.title,
                          imageUrl: ev.coverImageUrl,
                          date: _formatDate(ev.startDate),
                          time: _formatTime(ev.startDate),
                          location: ev.venueName,
                          category: ev.category,
                          price: _computeStartingPrice(ev),
                          isBookmarked: bookmarkedIds.contains(ev.id),
                          onBookmark: () => ref
                              .read(bookmarkedIdsProvider.notifier)
                              .toggle(ev.id),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    EventDetailsScreen(event: ev),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: nearYouEvents.length,
                  ),
                ),
              ],
            ),
          ),
        );
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard(EventModel event) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 200,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                event.coverImageUrl ??
                    'https://ui-avatars.com/api/?name=Event&background=161C2D&color=fff&size=800',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AttendeeTheme.cardColor,
                  child: const Center(
                    child: Icon(Icons.image_outlined,
                        color: Colors.white24, size: 48),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                    stops: [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 14, color: AttendeeTheme.electricBlue),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(event.startDate),
                          style: const TextStyle(
                            color: AttendeeTheme.electricBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time_rounded,
                            size: 14, color: AttendeeTheme.electricBlue),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(event.startDate),
                          style: const TextStyle(
                            color: AttendeeTheme.electricBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
