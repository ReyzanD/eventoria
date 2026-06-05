import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/attendee_repository.dart';
import '../../domain/entities/organizer_attendee_entity.dart';
import '../models/organizer_attendee_model.dart';

class AttendeeRepositoryImpl implements AttendeeRepository {
  final SupabaseClient _supabase;

  AttendeeRepositoryImpl(this._supabase);

  @override
  Future<List<OrganizerAttendeeEntity>> getEventAttendees(
    String eventId,
  ) async {
    // Use implicit FK resolution (no explicit constraint hints) so the query
    // works regardless of the exact constraint name Supabase assigned.
    // The `events` join is omitted — the event title is already known from
    // context (widget parameter / OrganizerAllAttendeeItem.eventTitle).
    final response = await _supabase
        .from('tickets')
        .select(
          'id, '
          'order_number, '
          'is_checked_in, '
          'profiles(full_name, email, avatar_url), '
          'ticket_tiers(name)',
        )
        .eq('event_id', eventId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map(
          (row) =>
              OrganizerAttendeeModel.fromJson(row as Map<String, dynamic>),
        )
        .toList();
  }
}
