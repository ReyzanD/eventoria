import 'package:eventoria/features/events/data/models/ticket_model.dart';
import 'package:flutter/foundation.dart';
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
        .select('*, ticket_tiers(*)')
        .eq('organizer_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) => EventModel.fromJson(json)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchOrganizerEvents());
  }


  Future<bool> createEvent(
    EventModel newEvent,
    List<TicketModel> tiers,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final payload = newEvent.toJson();

      // Let Postgres generate the UUID, but manually attach the Organizer ID
      payload.remove('id');
      payload['organizer_id'] = user.id;

      // 2. Insert the Event AND return the generated row so we can grab the new ID
      final eventResponse = await _client
          .from('events')
          .insert(payload)
          .select()
          .single();

      final generatedEventId = eventResponse['id'];

      // 3. Prepare the Ticket Tiers payload by attaching the new event ID
      if (tiers.isNotEmpty) {
        final tiersPayload = tiers.map((tier) {
          final tierJson = tier.toJson();
          tierJson.remove('id'); // Let Postgres generate the tier UUID
          tierJson['event_id'] = generatedEventId; // Link it to the event!
          tierJson.remove('tickets_sold'); // Database defaults this to 0
          return tierJson;
        }).toList();

        // 4. Bulk insert all ticket tiers in one shot
        await _client.from('ticket_tiers').insert(tiersPayload);
      }

      await refresh();
      return true;
    } catch (e) {
      assert(() {
        debugPrint('Error creating event and tiers: $e');
        return true;
      }());
      return false;
    }
  }
}
