import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../events/data/models/event_model.dart';

final attendeeEventsProvider = AsyncNotifierProvider<AttendeeEventsController, List<EventModel>>((){
  return AttendeeEventsController();
});

class AttendeeEventsController extends AsyncNotifier<List<EventModel>> {
  final _client = Supabase.instance.client;

  @override 
  Future<List<EventModel>> build() async{
    final response = await _client
    .from('events')
    .select()
    .eq('is_published', true)
    .gte('start_date', DateTime.now().toIso8601String())
    .order('start_date', ascending: true);

    return (response as List).map((json) => EventModel.fromJson(json)).toList();
  }

  Future<void> refresh() async{
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}