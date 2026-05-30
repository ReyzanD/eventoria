import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/event_repository.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final supabase.SupabaseClient _client;

  EventRepositoryImpl(this._client);
  @override
  Future<Either<Failure, List<EventModel>>> fetchPublishedEvents() async {
    try {
      final response = await _client
          .from('events')
          .select('*, ticket_tiers(*)')
          .eq('is_published', true);

      final data = response as List<dynamic>;
      final events = data.map((json) => EventModel.fromJson(json)).toList();
      return Right(events);
    } on supabase.PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<EventModel>> streamOrganizerEventsRealtime(String organizerId) {
    return _client
        .from('events')
        .stream(primaryKey: ['id'])
        .eq('organizer_id', organizerId)
        .map((maps) => maps.map((map) => EventModel.fromJson(map)).toList());
  }
}
