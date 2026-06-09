import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// --- PROVIDERS ---

// Provider to fetch pending organizers
final pendingOrganizersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name, email, avatar_url, role, is_verified, created_at')
          .eq('role', 'organizer')
          .eq('is_verified', false)
          .order('full_name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    });

// Provider to fetch all users
final allUsersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .order('role', ascending: true)
          .order('full_name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    });

// Provider to fetch all events
final allEventsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final response = await Supabase.instance.client
          .from('events')
          .select('*, profiles:organizer_id(full_name, email)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    });

// Provider to fetch admin dashboard statistics
final adminStatsProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
      final client = Supabase.instance.client;
      final usersRes = await client.from('profiles').select('id');
      final pendingRes = await client
          .from('profiles')
          .select('id')
          .eq('role', 'organizer')
          .eq('is_verified', false);
      final eventsRes = await client.from('events').select('id');
      final ticketsRes = await client.from('tickets').select('id');

      return {
        'totalUsers': (usersRes as List).length,
        'pendingOrganizers': (pendingRes as List).length,
        'totalEvents': (eventsRes as List).length,
        'totalTickets': (ticketsRes as List).length,
      };
    });

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _userSearchQuery = '';
  String _eventSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Refresh all dashboard data
  Future<void> _refreshAllData() async {
    ref.invalidate(pendingOrganizersProvider);
    ref.invalidate(allUsersProvider);
    ref.invalidate(allEventsProvider);
    ref.invalidate(adminStatsProvider);
  }

  // Approve Organizer
  Future<void> _approveOrganizer(BuildContext context, String userId) async {
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'is_verified': true})
          .eq('id', userId);

      await _refreshAllData();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Organizer Successfully Approved!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to approve: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  // Toggle Organizer Verification Status (Approve/Revoke)
  Future<void> _toggleOrganizerVerification(
    BuildContext context,
    String userId,
    bool currentStatus,
  ) async {
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'is_verified': !currentStatus})
          .eq('id', userId);

      await _refreshAllData();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentStatus ? 'Verification revoked!' : 'Organizer verified!',
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update verification: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  // Delete User Profile
  Future<void> _deleteUser(BuildContext context, String userId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete User: $name',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this user? This action is permanent and will remove all associated events and tickets.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client.from('profiles').delete().eq('id', userId);
      await _refreshAllData();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User successfully deleted!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  // Toggle Event Publication Status
  Future<void> _toggleEventPublish(
    BuildContext context,
    String eventId,
    bool currentStatus,
  ) async {
    try {
      await Supabase.instance.client
          .from('events')
          .update({'is_published': !currentStatus})
          .eq('id', eventId);

      await _refreshAllData();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentStatus ? 'Event unpublished!' : 'Event published!',
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update event status: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  // Delete Event
  Future<void> _deleteEvent(BuildContext context, String eventId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Event: $title',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this event? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client.from('events').delete().eq('id', eventId);
      await _refreshAllData();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event successfully deleted!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete event: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);
    final pendingAsync = ref.watch(pendingOrganizersProvider);
    final usersAsync = ref.watch(allUsersProvider);
    final eventsAsync = ref.watch(allEventsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Super Admin Panel',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            tooltip: 'Sign Out',
            onPressed: () => ref
                .read(authControllerProvider.notifier)
                .logout(onError: (e) {}),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF3B4FEB),
        backgroundColor: const Color(0xFF1E293B),
        onRefresh: _refreshAllData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // --- STATS SECTION ---
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: statsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Color(0xFF3B4FEB)),
                    ),
                  ),
                  error: (err, _) => Center(
                    child: Text(
                      'Stats error: $err',
                      style: const TextStyle(color: Color(0xFFEF4444)),
                    ),
                  ),
                  data: (stats) {
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      childAspectRatio: 2.2,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          title: 'Total Users',
                          value: '${stats['totalUsers']}',
                          icon: Icons.people_alt_rounded,
                          color: const Color(0xFF3B4FEB), // Indigo
                        ),
                        StatCard(
                          title: 'Pending Organizers',
                          value: '${stats['pendingOrganizers']}',
                          icon: Icons.pending_actions_rounded,
                          color: const Color(0xFFF59E0B), // Amber
                        ),
                        StatCard(
                          title: 'Total Events',
                          value: '${stats['totalEvents']}',
                          icon: Icons.event_available_rounded,
                          color: const Color(0xFF10B981), // Emerald
                        ),
                        StatCard(
                          title: 'Tickets Booked',
                          value: '${stats['totalTickets']}',
                          icon: Icons.confirmation_number_rounded,
                          color: const Color(0xFFEC4899), // Pink
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // --- TAB CONTROLLER HEADER ---
            SliverAppBar(
              backgroundColor: const Color(0xFF0F172A),
              pinned: true,
              toolbarHeight: 0,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF3B4FEB),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.feedback_rounded, size: 18),
                        const SizedBox(width: 8),
                        const Text('Pending'),
                        pendingAsync.when(
                          data: (list) => list.isNotEmpty
                              ? Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${list.length}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox.shrink(),
                          error: (err, stack) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.supervised_user_circle_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Users'),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Events'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- TAB VIEWS CONTENT ---
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. PENDING TAB
                  _buildPendingTab(pendingAsync),

                  // 2. USERS TAB
                  _buildUsersTab(usersAsync, _userSearchQuery),

                  // 3. EVENTS TAB
                  _buildEventsTab(eventsAsync, _eventSearchQuery),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PENDING TAB BUILDER ---
  Widget _buildPendingTab(AsyncValue<List<Map<String, dynamic>>> pendingAsync) {
    return pendingAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF3B4FEB)),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Failed to load pending organizers: $err\n\nEnsure database policies are applied!',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (organizers) {
        if (organizers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 64,
                  color: Color(0xFF10B981),
                ),
                SizedBox(height: 16),
                Text(
                  'All Caught Up!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'No pending organizers require verification.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: organizers.length,
          itemBuilder: (context, index) {
            final org = organizers[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF3B4FEB).withValues(alpha: 0.1),
                    radius: 24,
                    child: const Icon(Icons.business_rounded, color: Color(0xFF3B4FEB)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          org['full_name'] ?? 'Unknown Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          org['email'] ?? 'No email',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _approveOrganizer(context, org['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- USERS TAB BUILDER ---
  Widget _buildUsersTab(
    AsyncValue<List<Map<String, dynamic>>> usersAsync,
    String query,
  ) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search users by name or email...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (val) {
              setState(() {
                _userSearchQuery = val;
              });
            },
          ),
        ),

        Expanded(
          child: usersAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B4FEB)),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Failed to load users: $err\n\nEnsure database policies are applied!',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (users) {
              final filteredUsers = users.where((u) {
                final name = (u['full_name'] ?? '').toString().toLowerCase();
                final email = (u['email'] ?? '').toString().toLowerCase();
                final term = query.toLowerCase();
                return name.contains(term) || email.contains(term);
              }).toList();

              if (filteredUsers.isEmpty) {
                return const Center(
                  child: Text(
                    'No matching users found.',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final isOrg = user['role'] == 'organizer';
                  final isVerified = user['is_verified'] == true;
                  final isAdmin = user['role'] == 'admin';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isAdmin
                              ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                              : isOrg
                                  ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                                  : const Color(0xFF3B4FEB).withValues(alpha: 0.15),
                          radius: 20,
                          child: Icon(
                            isAdmin
                                ? Icons.admin_panel_settings_rounded
                                : isOrg
                                    ? Icons.business_rounded
                                    : Icons.person_rounded,
                            color: isAdmin
                                ? const Color(0xFFEF4444)
                                : isOrg
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF3B4FEB),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      user['full_name'] ?? 'Unknown Name',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _buildRoleBadge(user['role'] ?? 'attendee'),
                                  if (isOrg && isVerified) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: Color(0xFF10B981),
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user['email'] ?? 'No email',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isOrg) ...[
                          IconButton(
                            icon: Icon(
                              isVerified
                                  ? Icons.verified_user_rounded
                                  : Icons.gpp_maybe_rounded,
                              color: isVerified
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                            tooltip: isVerified
                                ? 'Revoke Verification'
                                : 'Verify Organizer',
                            onPressed: () => _toggleOrganizerVerification(
                              context,
                              user['id'],
                              isVerified,
                            ),
                          ),
                        ],
                        if (!isAdmin) ...[
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFEF4444),
                            ),
                            tooltip: 'Delete User',
                            onPressed: () => _deleteUser(
                              context,
                              user['id'],
                              user['full_name'] ?? 'Unknown',
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- EVENTS TAB BUILDER ---
  Widget _buildEventsTab(
    AsyncValue<List<Map<String, dynamic>>> eventsAsync,
    String query,
  ) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search events by title or category...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (val) {
              setState(() {
                _eventSearchQuery = val;
              });
            },
          ),
        ),

        Expanded(
          child: eventsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B4FEB)),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Failed to load events: $err\n\nEnsure database policies are applied!',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (events) {
              final filteredEvents = events.where((e) {
                final title = (e['title'] ?? '').toString().toLowerCase();
                final category = (e['category'] ?? '').toString().toLowerCase();
                final term = query.toLowerCase();
                return title.contains(term) || category.contains(term);
              }).toList();

              if (filteredEvents.isEmpty) {
                return const Center(
                  child: Text(
                    'No matching events found.',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  final isPublished = event['is_published'] == true;
                  final organizer = event['profiles'] as Map<String, dynamic>?;
                  final orgName = organizer?['full_name'] ?? 'Unknown Organizer';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        // Event cover image or category icon placeholder
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B4FEB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            image: event['cover_image_url'] != null
                                ? DecorationImage(
                                    image: NetworkImage(event['cover_image_url']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: event['cover_image_url'] == null
                              ? const Icon(
                                  Icons.campaign_rounded,
                                  color: Color(0xFF3B4FEB),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'] ?? 'Untitled Event',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'By: $orgName',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPublished
                                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                          : const Color(0xFF64748B).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isPublished ? 'Published' : 'Draft',
                                      style: TextStyle(
                                        color: isPublished
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF94A3B8),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    event['category'] ?? 'General',
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isPublished
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: isPublished
                                ? const Color(0xFF10B981)
                                : const Color(0xFF64748B),
                          ),
                          tooltip: isPublished
                              ? 'Unpublish Event'
                              : 'Publish Event',
                          onPressed: () => _toggleEventPublish(
                            context,
                            event['id'],
                            isPublished,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFEF4444),
                          ),
                          tooltip: 'Delete Event',
                          onPressed: () => _deleteEvent(
                            context,
                            event['id'],
                            event['title'] ?? 'Untitled',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper widget to construct user role badges
  Widget _buildRoleBadge(String role) {
    Color bg;
    Color fg;
    String text = role.toUpperCase();

    if (role == 'admin') {
      bg = const Color(0xFFEF4444).withValues(alpha: 0.15);
      fg = const Color(0xFFEF4444);
    } else if (role == 'organizer') {
      bg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
      fg = const Color(0xFFF59E0B);
    } else {
      bg = const Color(0xFF3B4FEB).withValues(alpha: 0.15);
      fg = const Color(0xFF3B4FEB);
      text = 'ATTENDEE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// --- STAT CARD UI ---
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
