import '../entities/organizer_attendee_entity.dart';

abstract class AttendeeRepository {
  Future<List<OrganizerAttendeeEntity>> getEventAttendees(String eventId);
}
