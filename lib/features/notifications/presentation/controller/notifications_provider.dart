import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_config.dart';

final unreadNotificationCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final client = ref.watch(supabaseProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return 0;

  final count = await client
      .from('notifications')
      .count()
      .eq('user_id', userId)
      .eq('is_read', false);

  return count;
});

final notificationsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];

  final response = await client
      .from('notifications')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(50);

  return (response as List).cast<Map<String, dynamic>>();
});
