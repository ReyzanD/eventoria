import 'dart:io';

import 'package:eventoria/features/analytics/presentation/screens/organizer_analytics_screen.dart';
import 'package:eventoria/features/auth/presentation/providers/auth_provider.dart';
import 'package:eventoria/features/auth/presentation/screens/organizer_profile_screen.dart';
import 'package:eventoria/features/dashboard/presentation/controller/organizer_dashboard_controller.dart';
import 'package:eventoria/features/dashboard/presentation/screens/create_event_screen.dart';
import 'package:eventoria/features/dashboard/presentation/screens/organizer_event_details_screen.dart';
import 'package:eventoria/features/payments/presentation/screens/organizer_payments_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../attendees/presentation/providers/organizer_all_attendees_provider.dart';
import '../../../attendees/presentation/screens/organizer_all_attendees_screen.dart';
import '../../domain/models/dashboard_view_state.dart';
import '../../domain/models/event_sales_summary.dart';
import 'organizer_scanner_screen.dart';

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
  int _navIndex = 0;

  final _navDestinations = <NavigationRailDestination>[
    const NavigationRailDestination(
      icon: Icon(Icons.calendar_month_rounded),
      selectedIcon: Icon(Icons.calendar_month_rounded, color: Color(0xFF3B4FEB)),
      label: Text('Events'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.people_outline_rounded),
      selectedIcon: Icon(Icons.people_rounded, color: Color(0xFF3B4FEB)),
      label: Text('Attendees'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.payment_rounded),
      selectedIcon: Icon(Icons.payment_rounded, color: Color(0xFF3B4FEB)),
      label: Text('Payments'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.qr_code_rounded),
      selectedIcon: Icon(Icons.qr_code_rounded, color: Color(0xFF3B4FEB)),
      label: Text('Scan'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.bar_chart_rounded),
      selectedIcon: Icon(Icons.bar_chart_rounded, color: Color(0xFF3B4FEB)),
      label: Text('Analytics'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF3B4FEB)),
      label: Text('Profile'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(organizerDashboardProvider);
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          switch (_navIndex) {
            0 => 'My Events',
            1 => 'All Attendees',
            2 => 'Payments',
            3 => 'Scan QR Code',
            4 => 'Analytics',
            _ => 'Profile',
          },
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (_navIndex == 0)
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
          if (_navIndex == 1)
            IconButton(
              icon: const Icon(
                Icons.download_rounded,
                color: Color(0xFF3B4FEB),
              ),
              tooltip: 'Export CSV',
              onPressed: () async {
                final items = ref
                    .read(organizerAllAttendeesControllerProvider)
                    .value;
                if (items == null || items.isEmpty) return;

                final rows = <List<String>>[];
                rows.add([
                  'Order Number',
                  'Event Name',
                  'Attendee Name',
                  'Email',
                  'Ticket Tier',
                  'Status',
                ]);
                for (final item in items) {
                  rows.add([
                    item.attendee.orderCode,
                    item.eventTitle,
                    item.attendee.name,
                    item.attendee.email,
                    item.attendee.ticketType,
                    item.attendee.checkedIn ? 'Checked In' : 'Not Scanned',
                  ]);
                }

                final csvData = rows
                    .map((row) => row
                        .map((cell) {
                          final str = cell.toString();
                          if (str.contains(',') ||
                              str.contains('"') ||
                              str.contains('\n')) {
                            return '"${str.replaceAll('"', '""')}"';
                          }
                          return str;
                        })
                        .join(','))
                    .join('\n');

                final directory = await getTemporaryDirectory();
                final path = '${directory.path}/guestlist_export.csv';
                final file = File(path);
                await file.writeAsString(csvData);

                if (context.mounted) {
                  final box = context.findRenderObject() as RenderBox?;
                  await Share.shareXFiles(
                    [XFile(path)],
                    text: 'Here is the exported guest list.',
                    sharePositionOrigin:
                        box!.localToGlobal(Offset.zero) & box.size,
                  );
                }
              },
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
      body: _buildBody(dashboardState, isDesktop),
      floatingActionButton: _navIndex == 0 && !isDesktop
          ? FloatingActionButton(
              onPressed: () {
                setState(() => _navIndex = 3);
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
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
              ),
              child: NavigationBar(
                selectedIndex: _navIndex,
                onDestinationSelected: (i) => setState(() => _navIndex = i),
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xFF3B4FEB).withValues(alpha: 0.1),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF3B4FEB),
                    );
                  }
                  return const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF717F8C),
                  );
                }),
                destinations: _navDestinations
                    .map((d) => NavigationDestination(
                          icon: d.icon,
                          selectedIcon: d.selectedIcon,
                          label: (d.label as Text).data ?? '',
                        ))
                    .toList(),
              ),
            ),
    );
  }

  Widget _buildBody(
      AsyncValue<DashboardViewState> dashboardState, bool isDesktop) {
    final bodyContent = switch (_navIndex) {
      0 => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(organizerDashboardProvider);
            try {
              await ref.read(organizerDashboardProvider.future);
            } catch (_) {}
          },
          child: dashboardState.when(
            data: (state) => Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : 800),
                child: _buildDashboardContent(state),
              ),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B4FEB)),
            ),
            error: (err, stack) =>
                Center(child: Text('Error loading dashboard: $err')),
          ),
        ),
      1 => const OrganizerAllAttendeesScreen(),
      2 => const OrganizerPaymentsScreen(),
      3 => const OrganizerScannerScreen(),
      4 => const OrganizerAnalyticsScreen(),
      5 => const OrganizerProfileScreen(),
      _ => const OrganizerProfileScreen(),
    };

    if (!isDesktop) return bodyContent;

    return Row(
      children: [
        NavigationRail(
          selectedIndex: _navIndex,
          onDestinationSelected: (i) => setState(() => _navIndex = i),
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF3B4FEB).withValues(alpha: 0.12),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Icon(Icons.event_rounded,
                    size: 32, color: const Color(0xFF3B4FEB)),
                const SizedBox(height: 4),
                Text('Eventoria',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B4FEB))),
              ],
            ),
          ),
          labelType: NavigationRailLabelType.all,
          destinations: _navDestinations,
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(child: bodyContent),
      ],
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
                    'Rp ${(state.totalRevenue >= 1000 ? '${(state.totalRevenue / 1000).toStringAsFixed(1)}k' : state.totalRevenue.toStringAsFixed(0))}',
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
              final summaryItem = currentList[index];
              return EventListItem(
                summary: summaryItem,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          OrganizerEventDetailsScreen(summary: summaryItem),
                    ),
                  );
                },
              );
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
