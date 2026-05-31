import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../events/data/models/event_model.dart';

final organizerEventsProvider =
    AsyncNotifierProvider<OrganizerEventsController, List<EventModel>>(() {
      return OrganizerEventsController();
    });

class OrganizerEventsController extends AsyncNotifier<List<EventModel>> {
  final _client = Supabase.instance.client;

  @override
  Future<List<EventModel>> build() async {
    return _fetchOrganizerEvents();
  }

  Future<List<EventModel>> _fetchOrganizerEvents() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('events')
        .select()
        .eq('organizer_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) => EventModel.fromJson(json)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchOrganizerEvents());
  }

  Future<bool> createEvent(EventModel newEvent) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final payload = newEvent.toJson();

      payload.remove('id');
      payload['organizer_id'] = user.id;

      await _client.from('events').insert(payload);

      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }
}
