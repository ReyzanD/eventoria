import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../events/data/models/event_model.dart';

final discoverEventsProvider = FutureProvider.autoDispose<List<EventModel>>((
  ref,
) async {
  final client = Supabase.instance.client;

  final now = DateTime.now().toIso8601String();

  final response = await client
      .from('events')
      .select('*, ticket_tiers(*)')
      .eq('is_published', true)
      .gte('end_date', now)
      .order('start_date', ascending: true);

  return (response as List).map((json) => EventModel.fromJson(json)).toList();
});
