import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/attendee_theme.dart';
import '../../../discover/presentation/screens/attendee_discover_screen.dart';
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
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AttendeeTheme.bgColor,
      ),
      child: Scaffold(
        backgroundColor: AttendeeTheme.bgColor,
        // --- THE MAGIC SWITCHER ---
        // This swaps the screens instantly based on the tab you tap
        body: switch (_bottomNavIndex) {
          0 => const AttendeeDiscoverScreen(),
          1 => const Center(
            child: Text(
              'Search Screen Coming Soon',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          2 => const AttendeeTicketsScreen(), // <-- Your new QR Tickets list!
          3 => const ProfileScreen(), // <-- The separated profile screen
          _ => const Center(child: Text('Tab under construction')),
        },

        // --- YOUR ORIGINAL BOTTOM NAV ---
        bottomNavigationBar: Container(
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
        ),
      ),
    );
  }
}
