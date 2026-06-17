import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/theme/attendee_theme.dart';
import '../../../discover/presentation/screens/attendee_discover_screen.dart';
import '../../../discover/presentation/screens/attendee_search_screen.dart';
import '../../../tickets/presentation/screens/attendee_tickets_screen.dart';
import '../../../auth/presentation/screens/attendee_profile_screen.dart';

class AttendeeDashboardScreen extends ConsumerStatefulWidget {
  const AttendeeDashboardScreen({super.key});

  @override
  ConsumerState<AttendeeDashboardScreen> createState() =>
      _AttendeeDashboardScreenState();
}

class _AttendeeDashboardScreenState
    extends ConsumerState<AttendeeDashboardScreen> {
  int _navIndex = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.blur_on_rounded),
      label: 'Discover',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_rounded),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.confirmation_number_outlined),
      label: 'Tickets',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AttendeeTheme.bgColor,
      ),
      child: AdaptiveScaffold(
        selectedIndex: _navIndex,
        onIndexChanged: (i) => setState(() => _navIndex = i),
        pages: const [
          AttendeeDiscoverScreen(),
          AttendeeSearchScreen(),
          AttendeeTicketsScreen(),
          ProfileScreen(),
        ],
        destinations: _destinations,
        backgroundColor: AttendeeTheme.bgColor,
        railBackgroundColor: AttendeeTheme.cardColor,
        selectedIconColor: AttendeeTheme.neonPink,
        unselectedIconColor: Colors.grey,
        indicatorColor: AttendeeTheme.neonPink.withValues(alpha: 0.15),
      ),
    );
  }
}
