import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/attendee_theme.dart';
import '../../../discover/presentation/controller/bookmarks_provider.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../tickets/presentation/screens/attendee_tickets_screen.dart';
import '../providers/auth_provider.dart';
import 'saved_events_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AttendeeTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Help & Support',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            _helpRow(Icons.email_outlined, 'support@eventoria.app'),
            const SizedBox(height: 12),
            _helpRow(Icons.info_outline_rounded, 'Version 1.0.0'),
            const SizedBox(height: 12),
            _helpRow(Icons.description_outlined, 'Terms of Service'),
            const SizedBox(height: 12),
            _helpRow(Icons.shield_outlined, 'Privacy Policy'),
          ],
        ),
      ),
    );
  }

  Widget _helpRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.5)),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showSignOutConfirmation(BuildContext context, WidgetRef ref) {
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
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white30),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authControllerProvider).asData?.value;
    final bookmarkedCount = ref.watch(bookmarkedIdsProvider).length;
    final displayName = profile?.fullName ?? 'Attendee';
    final email = profile?.email ?? '';
    final initials = displayName
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AttendeeTheme.bgColor,
      ),
      child: Scaffold(
        backgroundColor: AttendeeTheme.bgColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 80),
              // Avatar
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: profile?.avatarUrl != null
                      ? null
                      : const LinearGradient(
                          colors: [
                            AttendeeTheme.electricBlue,
                            AttendeeTheme.neonPink,
                          ],
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
                  image: profile?.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(profile!.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profile?.avatarUrl == null
                    ? Center(
                        child: Text(
                          initials.isEmpty ? '?' : initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      )
                    : null,
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
              if (email.isNotEmpty) ...[
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
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

              // My Tickets
              _buildProfileMenuItem(
                icon: Icons.confirmation_number_outlined,
                label: 'My Tickets',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AttendeeTicketsScreen(),
                    ),
                  );
                },
              ),
              // Saved Events
              _buildProfileMenuItem(
                icon: Icons.favorite_border_rounded,
                label: bookmarkedCount > 0
                    ? 'Saved Events ($bookmarkedCount)'
                    : 'Saved Events',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SavedEventsScreen(),
                    ),
                  );
                },
              ),
              // Notifications
              _buildProfileMenuItem(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              // Help & Support
              _buildProfileMenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                onTap: () => _showHelpSheet(context),
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),

              // Sign Out
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showSignOutConfirmation(context, ref),
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
        ),
      ),
    );
  }
}
