import 'package:eventoria/features/auth/presentation/providers/auth_provider.dart';
import 'package:eventoria/features/dashboard/presentation/controller/organizer_dashboard_controller.dart';
import 'package:eventoria/features/dashboard/presentation/screens/create_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/framework.dart';

import '../../domain/models/dashboard_view_state.dart';
import '../../domain/models/event_sales_summary.dart';

import '../widgets/dashboard_metric_card.dart';
import '../widgets/dashboard_tab_item.dart';
import '../widgets/next_event_banner.dart';
import '../widgets/event_list_item.dart';

class OrganizerDashboardScreen extends ConsumerStatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  ConsumerState<OrganizerDashboardScreen> createState() =>
      _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState
    extends ConsumerState<OrganizerDashboardScreen> {
  int _activeTabIndex = 0;
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(organizerDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My events',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text(
                'New',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF45E65),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF717F8C)),
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
      body: _bottomNavIndex == 0
          ? RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(
                  organizerDashboardProvider.future as ProviderOrFamily,
                );
                try {
                  await ref.read(organizerDashboardProvider.future);
                } catch (_) {}
              },
              child: dashboardState.when(
                data: (state) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: _buildDashboardContent(state),
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3B4FEB)),
                ),
                error: (err, stack) =>
                    Center(child: Text('Error loading dashboard: $err')),
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: _buildPlaceholderTab(),
              ),
            ),
      floatingActionButton: _bottomNavIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Scan QR Code feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: const Color(0xFF3B4FEB),
              shape: const CircleBorder(),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 28,
              ),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (index) => setState(() => _bottomNavIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3B4FEB),
          unselectedItemColor: const Color(0xFF717F8C),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              label: 'Attendees',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_rounded),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab() {
    final titles = [
      'Events',
      'Attendees',
      'Scan QR Code',
      'Analytics',
      'Profile Settings',
    ];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _bottomNavIndex == 1
                ? Icons.people_outline_rounded
                : _bottomNavIndex == 2
                ? Icons.qr_code_rounded
                : _bottomNavIndex == 3
                ? Icons.bar_chart_rounded
                : Icons.person_outline_rounded,
            size: 80,
            color: const Color(0xFF717F8C).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            titles[_bottomNavIndex],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This tab is under development.',
            style: TextStyle(color: Color(0xFF717F8C)),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(DashboardViewState state) {
    List<EventSalesSummary> currentList = _activeTabIndex == 0
        ? state.liveEvents
        : _activeTabIndex == 1
        ? state.draftEvents
        : state.pastEvents;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardMetricCard(
                label: 'Revenue',
                value:
                    '\$${(state.totalRevenue >= 1000 ? '${(state.totalRevenue / 1000).toStringAsFixed(1)}k' : state.totalRevenue.toStringAsFixed(0))}',
                hasTrend: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DashboardMetricCard(
                label: 'Tickets sold',
                value: '${state.totalTicketsSold}',
                hasTrend: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DashboardMetricCard(
                label: 'Conversion',
                value: '${state.conversionRate.toStringAsFixed(1)}%',
                hasTrend: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            DashboardTabItem(
              label: 'Live',
              isSelected: _activeTabIndex == 0,
              onTap: () => setState(() => _activeTabIndex = 0),
            ),
            DashboardTabItem(
              label: 'Drafts',
              isSelected: _activeTabIndex == 1,
              onTap: () => setState(() => _activeTabIndex = 1),
            ),
            DashboardTabItem(
              label: 'Past',
              isSelected: _activeTabIndex == 2,
              onTap: () => setState(() => _activeTabIndex = 2),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (currentList.isEmpty)
          _buildEmptyListState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentList.length,
            itemBuilder: (context, index) {
              return EventListItem(summary: currentList[index], onTap: () {});
            },
          ),

        const SizedBox(height: 16),
        if (state.nextEvent != null) NextEventBanner(event: state.nextEvent!),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildEmptyListState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.event_busy_outlined, size: 48, color: Color(0xFF717F8C)),
            SizedBox(height: 12),
            Text(
              'No events found',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Create a new event to show up here.',
              style: TextStyle(color: Color(0xFF717F8C), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
