import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/attendee_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
  int _bottomNavIndex = 0;
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

  void _showSignOutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AttendeeTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AttendeeTheme.neonPink.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AttendeeTheme.neonPink,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign Out?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You will be returned to the sign-in screen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ref
                          .read(authControllerProvider.notifier)
                          .logout(
                            onError: (err) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sign out failed: $err'),
                                  backgroundColor: AttendeeTheme.neonPink,
                                ),
                              );
                            },
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AttendeeTheme.neonPink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    final profile = ref.watch(authControllerProvider).asData?.value;
    final displayName = profile?.fullName ?? 'Attendee';
    final email = profile?.email ?? '';
    final initials = displayName
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 60),
          // Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AttendeeTheme.electricBlue, AttendeeTheme.neonPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AttendeeTheme.electricBlue.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials.isEmpty ? '?' : initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (email.isNotEmpty) ...
            [
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AttendeeTheme.electricBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AttendeeTheme.electricBlue.withValues(alpha: 0.3),
              ),
            ),
            child: const Text(
              'Attendee',
              style: TextStyle(
                color: AttendeeTheme.electricBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Menu items
          _buildProfileMenuItem(
            icon: Icons.confirmation_number_outlined,
            label: 'My Tickets',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.favorite_border_rounded,
            label: 'Saved Events',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),

          // Sign Out button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showSignOutConfirmation(context),
              icon: const Icon(
                Icons.logout_rounded,
                color: AttendeeTheme.neonPink,
                size: 20,
              ),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  color: AttendeeTheme.neonPink,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: AttendeeTheme.neonPink.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.white30,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsyncValue = ref.watch(discoverEventsProvider);

    // Show Profile tab when index 3 is selected
    if (_bottomNavIndex == 3) {
      return Theme(
        data: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AttendeeTheme.bgColor,
        ),
        child: Scaffold(
          backgroundColor: AttendeeTheme.bgColor,
          body: _buildProfileTab(),
          bottomNavigationBar: _buildBottomNav(),
        ),
      );
    }

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AttendeeTheme.bgColor,
      ),
      child: Scaffold(
        backgroundColor: AttendeeTheme.bgColor,
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
                  title: const Text(
                    'Hi, Sam 👋',
                    style: TextStyle(
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
                        onPressed: () {},
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

        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white10, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AttendeeTheme.cardColor,
        selectedItemColor: AttendeeTheme.neonPink,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.blur_on_rounded),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
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
