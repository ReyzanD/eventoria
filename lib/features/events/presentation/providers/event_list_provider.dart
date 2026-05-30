import 'package:eventoria/features/events/data/repositories/event_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/event_entity.dart';

part 'event_list_provider.g.dart';

@riverpod
EventRepositoryImpl eventRepository(Ref ref) {
  return EventRepositoryImpl(Supabase.instance.client);
}

@riverpod
Future<List<EventEntity>> getPublishedEvents(Ref ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  final result = await repo.fetchPublishedEvents();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (events) => events,
  );
}
