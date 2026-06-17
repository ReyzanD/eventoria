import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/attendee_theme.dart';
import '../controller/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconForType(String type) {
    switch (type) {
      case 'payment_confirmed':
        return Icons.check_circle_rounded;
      case 'payment_pending':
        return Icons.access_time_rounded;
      case 'event_reminder':
        return Icons.notifications_active_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'payment_confirmed':
        return Colors.greenAccent;
      case 'payment_pending':
        return AttendeeTheme.neonOrange;
      case 'event_reminder':
        return AttendeeTheme.electricBlue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AttendeeTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AttendeeTheme.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: notificationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AttendeeTheme.electricBlue),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.white)),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll let you know when something new happens.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              final type = (n['type'] as String?) ?? 'general';
              final isRead = n['is_read'] as bool? ?? false;
              final title = n['title'] as String? ?? '';
              final body = n['body'] as String? ?? '';

              return GestureDetector(
                onTap: () async {
                  if (!isRead) {
                    await Supabase.instance.client
                        .from('notifications')
                        .update({'is_read': true})
                        .eq('id', n['id']);
                    ref.invalidate(notificationsProvider);
                    ref.invalidate(unreadNotificationCountProvider);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isRead
                        ? AttendeeTheme.cardColor
                        : AttendeeTheme.cardColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isRead
                          ? Colors.white.withValues(alpha: 0.04)
                          : _colorForType(type).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _colorForType(type).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _iconForType(type),
                          color: _colorForType(type),
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
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isRead
                                          ? FontWeight.w600
                                          : FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AttendeeTheme.neonPink,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              body,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
